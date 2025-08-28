import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HLS 解析器服务 - 集成 Better Player HLS 解析器
class HlsParserService {
  static final HlsParserService _instance = HlsParserService._internal();
  factory HlsParserService() => _instance;
  HlsParserService._internal();

  final Dio _dio = Dio();
  
  // 广告过滤设置
  bool _adFilterByMetadata = true; // 合并码率和不连续标记检测
  bool _adFilterByResolution = true;

  /// 广告检测规则
  static const Map<String, dynamic> _adDetectionRules = {
    'keywords': [
      'ad',
      'ads',
      'advertisement',
      'commercial',
      'sponsor',
      'promo',
      '广告',
      '赞助',
      '推广',
      '商业',
      '宣传'
    ],
    'durationThreshold': 30, // 广告片段通常较短（秒）
    'patternThreshold': 0.8, // 相似度阈值
  };

  /// 加载广告过滤设置
  Future<void> _loadAdFilterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _adFilterByMetadata = prefs.getBool('ad_filter_by_metadata') ?? true;
    _adFilterByResolution = prefs.getBool('ad_filter_by_resolution') ?? true;
  }

  /// 解析主播放列表 - 使用 Dio 获取内容
  Future<HlsMasterPlaylist> parseMasterPlaylist(String url) async {
    try {
      final response = await _dio.get(url);
      final data = response.data as String;
      debugPrint('主播放列表解析元数据: $data');
      return _parseMasterPlaylistContent(data, url);
    } catch (e) {
      throw HlsParserException('解析主播放列表失败: $e');
    }
  }

  /// 解析媒体播放列表 - 使用 Dio 获取内容
  Future<HlsMediaPlaylist> parseMediaPlaylist(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final data = response.data as String;
      debugPrint('视频解析元数据: $data');
      final result = _parseMediaPlaylistContent(data, url);
      debugPrint('媒体播放列表解析成功: ${result.segments.length} 个片段');
      return result;
    } catch (e, stackTrace) {
      debugPrint('媒体播放列表解析失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      throw HlsParserException('解析媒体播放列表失败: $e');
    }
  }

  /// 获取 HLS 文件内容（通用方法）
  Future<String> fetchHlsContent(String url) async {
    try {
      final response = await _dio.get(url);
      return response.data as String;
    } catch (e) {
      throw HlsParserException('获取 HLS 内容失败: $e');
    }
  }

  /// 过滤广告并重新构建播放列表
  Future<String> filterAdsAndRebuild(String originalUrl) async {
    try {
      // 加载最新的广告过滤设置
      await _loadAdFilterSettings();
      
      // 解析主播放列表
      final masterPlaylist = await parseMasterPlaylist(originalUrl);
      debugPrint('主播放列表解析成功: ${masterPlaylist.variants.length} 个流');
      // 选择最佳质量的流
      final bestVariant = _selectBestVariant(masterPlaylist.variants);
      if (bestVariant == null) {
        throw HlsParserException('没有找到可用的视频流');
      }

      // 解析媒体播放列表
      final mediaPlaylist = await parseMediaPlaylist(bestVariant.url);

      // 检测和过滤广告片段
      final filteredSegments = await _detectAndFilterAds(mediaPlaylist, bestVariant);

      // 重新构建播放列表
      return _rebuildPlaylist(mediaPlaylist, filteredSegments, bestVariant.url);
    } catch (e) {
      throw HlsParserException('过滤广告失败: $e');
    }
  }

  /// 解析主播放列表内容
  HlsMasterPlaylist _parseMasterPlaylistContent(String data, String baseUrl) {
    final lines = data.split('\n');
    final variants = <HlsVariant>[];
    final audios = <HlsAudio>[];
    final subtitles = <HlsSubtitle>[];

    // 检查是否真的是主播放列表（应该包含#EXT-X-STREAM-INF标签）
    bool hasStreamInf = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXT-X-STREAM-INF:')) {
        hasStreamInf = true;
        final attributes = _parseAttributes(line);
        if (i + 1 < lines.length) {
          final url = _resolveUrl(lines[i + 1].trim(), baseUrl);
          variants.add(HlsVariant(
            url: url,
            bandwidth: int.tryParse(attributes['BANDWIDTH'] ?? '0') ?? 0,
            resolution: attributes['RESOLUTION'],
            codecs: attributes['CODECS'],
            frameRate: double.tryParse(attributes['FRAME-RATE'] ?? '0') ?? 0,
          ));
        }
      } else if (line.startsWith('#EXT-X-MEDIA:')) {
        final attributes = _parseAttributes(line);
        final type = attributes['TYPE'];
        final url = _resolveUrl(attributes['URI'] ?? '', baseUrl);

        if (type == 'AUDIO') {
          audios.add(HlsAudio(
            url: url,
            language: attributes['LANGUAGE'],
            name: attributes['NAME'],
            groupId: attributes['GROUP-ID'],
          ));
        } else if (type == 'SUBTITLES') {
          subtitles.add(HlsSubtitle(
            url: url,
            language: attributes['LANGUAGE'],
            name: attributes['NAME'],
            groupId: attributes['GROUP-ID'],
          ));
        }
      }
    }

    // 如果没有找到任何流信息，抛出异常提示这可能是媒体播放列表
    if (!hasStreamInf && variants.isEmpty) {
      throw HlsParserException('这看起来是媒体播放列表而不是主播放列表，请使用parseMediaPlaylist方法');
    }

    return HlsMasterPlaylist(
      variants: variants,
      audios: audios,
      subtitles: subtitles,
    );
  }

  /// 解析媒体播放列表内容（增强版，支持检测不连续标记）
  HlsMediaPlaylist _parseMediaPlaylistContent(String data, String baseUrl) {
    final lines = data.split('\n');
    final segments = <HlsSegment>[];
    int targetDuration = 0;
    bool isLive = false;
    double currentDuration = 0.0;
    String? currentTitle;
    bool hasDiscontinuity = false;
    int discontinuityGroup = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXTM3U')) {
        // 播放列表头部
        continue;
      } else if (line.startsWith('#EXT-X-TARGETDURATION:')) {
        targetDuration = int.tryParse(line.split(':')[1]) ?? 0;
        debugPrint('发现目标时长: $targetDuration');
      } else if (line.startsWith('#EXT-X-MEDIA-SEQUENCE')) {
        final sequence = int.tryParse(line.split(':')[1]) ?? 0;
        debugPrint('发现媒体序列: $sequence');
      } else if (line.startsWith('#EXT-X-ENDLIST')) {
        isLive = false;
        debugPrint('发现播放列表结束标记');
      } else if (line.startsWith('#EXT-X-DISCONTINUITY')) {
        // 标记下一个片段有不连续标记
        hasDiscontinuity = true;
        discontinuityGroup++;
        debugPrint('发现不连续标记，当前组: $discontinuityGroup');
      } else if (line.startsWith('#EXTINF:')) {
        currentDuration = _parseDuration(line);
        currentTitle = _parseSegmentTitle(line);
        debugPrint('发现 EXTINF: 时长=$currentDuration, 标题=$currentTitle');

        // 查找下一个非空非注释行作为URL
        for (int j = i + 1; j < lines.length; j++) {
          final nextLine = lines[j].trim();
          if (!nextLine.startsWith('#') && nextLine.isNotEmpty) {
            final url = _resolveUrl(nextLine, baseUrl);
            segments.add(HlsSegment(
              url: url,
              duration: currentDuration,
              title: currentTitle,
              hasDiscontinuity: hasDiscontinuity, // 传递不连续标记状态
              discontinuityGroup: discontinuityGroup, // 分组信息
            ));
            debugPrint('添加片段: URL=$url, 时长=$currentDuration, 不连续=$hasDiscontinuity, 组=$discontinuityGroup');
            hasDiscontinuity = false; // 重置不连续标记
            i = j; // 跳过已经处理过的行
            break;
          }
        }
      } else if (!line.startsWith('#') && line.isNotEmpty) {
        // 这可能是一个独立的URL行（没有EXTINF的情况）
        debugPrint('发现独立URL行: $line');
        final url = _resolveUrl(line, baseUrl);
        segments.add(HlsSegment(
          url: url,
          duration:
              currentDuration > 0 ? currentDuration : 0.0, // 使用上一个EXTINF的时长或0
          title: currentTitle,
          hasDiscontinuity: hasDiscontinuity, // 传递不连续标记状态
          discontinuityGroup: discontinuityGroup, // 分组信息
        ));
        debugPrint('添加片段: URL=$url, 时长=$currentDuration, 不连续=$hasDiscontinuity, 组=$discontinuityGroup');
        hasDiscontinuity = false; // 重置不连续标记
      }
    }

    debugPrint('媒体播放列表解析完成: 共 ${segments.length} 个片段');
    for (int i = 0; i < segments.length && i < 10; i++) {
      debugPrint(
          '  片段 ${i + 1}: ${segments[i].url} (${segments[i].duration}s) 不连续=${segments[i].hasDiscontinuity} 组=${segments[i].discontinuityGroup}');
    }
    if (segments.length > 10) {
      debugPrint('  ... 还有 ${segments.length - 10} 个片段');
    }

    return HlsMediaPlaylist(
      segments: segments,
      targetDuration: targetDuration,
      isLive: isLive,
    );
  }

  /// 检测和过滤广告片段
  Future<List<HlsSegment>> _detectAndFilterAds(
      HlsMediaPlaylist playlist, HlsVariant bestVariant) async {
    // 如果没有启用元数据过滤，则返回所有片段
    if (!_adFilterByMetadata) {
      return playlist.segments;
    }

    // 按不连续组分组片段
    final groups = <int, List<HlsSegment>>{};
    for (final segment in playlist.segments) {
      final group = segment.discontinuityGroup;
      if (!groups.containsKey(group)) {
        groups[group] = [];
      }
      groups[group]!.add(segment);
    }

    debugPrint('检测到 ${groups.length} 个片段组');

    // 获取主播放列表中的码率信息
    final mainBandwidthPattern = _extractBandwidthFromUrl(bestVariant.url);
    debugPrint('主播放列表码率模式: $mainBandwidthPattern');

    // 存储非广告片段
    final filteredSegments = <HlsSegment>[];

    // 检查每个组
    groups.forEach((groupIndex, segmentsInGroup) {
      debugPrint('检查组 $groupIndex，包含 ${segmentsInGroup.length} 个片段');

      // 如果组中有片段包含主码率模式，则认为是正片
      bool isMainContent = false;
      for (final segment in segmentsInGroup) {
        final segmentBandwidthPattern = _extractBandwidthFromUrl(segment.url);
        debugPrint('  片段URL: ${segment.url}, 码率模式: $segmentBandwidthPattern');
        
        if (segmentBandwidthPattern != null && 
            mainBandwidthPattern != null && 
            segmentBandwidthPattern == mainBandwidthPattern) {
          isMainContent = true;
          debugPrint('  找到匹配主码率的片段，确认为正片');
          break;
        }
      }

      // 如果是主内容或第一组（通常第一组是正片），则保留
      if (isMainContent || groupIndex == 0) {
        debugPrint('  保留组 $groupIndex 的片段');
        filteredSegments.addAll(segmentsInGroup);
      } else {
        debugPrint('  过滤掉组 $groupIndex 的片段（识别为广告）');
      }
    });

    return filteredSegments;
  }

  /// 从URL中提取码率模式
  String? _extractBandwidthFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      for (final segment in uri.pathSegments) {
        // 查找类似 "2000kb" 或 "8997kb" 的模式
        if (RegExp(r'\d+kb').hasMatch(segment)) {
          return segment;
        }
      }
    } catch (e) {
      debugPrint('解析URL码率信息失败: $e');
    }
    return null;
  }

  /// 判断是否为广告片段（增强版）
  Future<bool> _isAdSegment(HlsSegment segment, HlsVariant bestVariant) async {
    debugPrint('检查片段是否为广告: ${segment.url}');
    debugPrint('  片段时长: ${segment.duration}');
    debugPrint('  片段标题: ${segment.title}');
    debugPrint('  片段不连续标记: ${segment.hasDiscontinuity}');

    // 1. 通过元数据检测广告（包括码率和不连续标记）
    if (_adFilterByMetadata) {
      // 1.1 通过不连续标记检测广告
      if (segment.hasDiscontinuity) {
        debugPrint('  广告检测: 片段有不连续标记');
        return true;
      }
      
      // 1.2 通过码率检测广告
      // 提取URL中的码率信息
      final uri = Uri.parse(segment.url);
      final pathSegments = uri.pathSegments;
      
      // 查找码率相关路径段（例如 2000kb）
      bool hasBandwidthInPath = false;
      String? bandwidthSegment;
      for (final pathSegment in pathSegments) {
        if (pathSegment.contains('kb')) {
          hasBandwidthInPath = true;
          bandwidthSegment = pathSegment;
          break;
        }
      }
      
      // 如果主播放列表的最佳变体URL中也包含码率信息，则比较它们
      if (hasBandwidthInPath && bestVariant.url.isNotEmpty) {
        final bestUri = Uri.parse(bestVariant.url);
        final bestPathSegments = bestUri.pathSegments;
        String? bestBandwidthSegment;
        for (final pathSegment in bestPathSegments) {
          if (pathSegment.contains('kb')) {
            bestBandwidthSegment = pathSegment;
            break;
          }
        }
        
        // 如果片段的码率与主播放列表的码率不一致，则可能是广告
        if (bandwidthSegment != null && 
            bestBandwidthSegment != null && 
            bandwidthSegment != bestBandwidthSegment) {
          debugPrint('  广告检测: 片段码率($bandwidthSegment)与主播放列表码率($bestBandwidthSegment)不一致');
          return true;
        }
      }
    }

    // 2. 通过分辨率检测广告
    if (_adFilterByResolution && bestVariant.resolution != null) {
      // 这个检测需要更复杂的实现，因为需要分析片段内容才能知道实际分辨率
      // 在当前实现中，我们暂时跳过此检测
    }

    // 3. 检查时长（广告通常较短）
    if (segment.duration <= _adDetectionRules['durationThreshold']) {
      debugPrint('  广告检测: 片段时长过短 (${segment.duration}s < ${_adDetectionRules['durationThreshold']}s)');
      return true;
    }

    // 4. 检查URL中的关键词
    final url = segment.url.toLowerCase();
    for (final keyword in _adDetectionRules['keywords']) {
      if (url.contains(keyword.toLowerCase())) {
        debugPrint('  广告检测: URL包含关键词 "$keyword"');
        return true;
      }
    }

    // 5. 检查标题中的关键词
    if (segment.title != null) {
      final title = segment.title!.toLowerCase();
      for (final keyword in _adDetectionRules['keywords']) {
        if (title.contains(keyword.toLowerCase())) {
          debugPrint('  广告检测: 标题包含关键词 "$keyword"');
          return true;
        }
      }
    }

    // 6. 检查内容特征（可选，需要下载片段头部进行分析）
    // 这里可以添加更复杂的检测逻辑，比如检查视频编码参数等

    debugPrint('  广告检测: 未检测到广告特征');
    return false;
  }

  /// 重新构建播放列表
  String _rebuildPlaylist(HlsMediaPlaylist original,
      List<HlsSegment> filteredSegments, String baseUrl) {
    final buffer = StringBuffer();

    // 添加播放列表头部
    buffer.writeln('#EXTM3U');
    buffer.writeln('#EXT-X-VERSION:3');
    buffer.writeln('#EXT-X-TARGETDURATION:${original.targetDuration}');
    buffer.writeln('#EXT-X-MEDIA-SEQUENCE:0');

    // 添加过滤后的片段（不添加不连续标记，避免播放器错误）
    for (final segment in filteredSegments) {
      buffer.writeln('#EXTINF:${segment.duration},${segment.title ?? ''}');
      buffer.writeln(segment.url);
    }

    // 添加播放列表结束标记
    buffer.writeln('#EXT-X-ENDLIST');

    return buffer.toString();
  }

  /// 选择最佳质量的视频流
  HlsVariant? _selectBestVariant(List<HlsVariant> variants) {
    if (variants.isEmpty) return null;

    // 按带宽排序，选择最高质量的流
    variants.sort((a, b) => b.bandwidth.compareTo(a.bandwidth));
    return variants.first;
  }

  /// 解析属性
  Map<String, String> _parseAttributes(String line) {
    final attributes = <String, String>{};
    final content = line.substring(line.indexOf(':') + 1);

    final pairs = content.split(',');
    for (final pair in pairs) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        attributes[parts[0].trim()] = parts[1].trim().replaceAll('"', '');
      }
    }

    return attributes;
  }

  /// 解析时长
  double _parseDuration(String line) {
    final match = RegExp(r'#EXTINF:([\d.]+)').firstMatch(line);
    return match != null ? double.tryParse(match.group(1)!) ?? 0.0 : 0.0;
  }

  /// 解析片段标题
  String? _parseSegmentTitle(String line) {
    final match = RegExp(r'#EXTINF:[\d.]+,(.+)').firstMatch(line);
    return match?.group(1);
  }

  /// 解析URL
  String _resolveUrl(String url, String baseUrl) {
    // 如果已经是完整URL，直接返回
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    final baseUri = Uri.parse(baseUrl);

    // 处理绝对路径（以/开头）
    if (url.startsWith('/')) {
      return '${baseUri.scheme}://${baseUri.host}$url';
    }

    // 处理相对路径
    final pathSegments = List<String>.from(baseUri.pathSegments);

    // 移除空的路径段
    pathSegments.removeWhere((element) => element.isEmpty);

    // 移除最后一级文件名，准备添加相对路径
    if (pathSegments.isNotEmpty) {
      pathSegments.removeLast();
    }

    // 分割并添加相对URL路径
    final relativeSegments =
        url.split('/').where((element) => element.isNotEmpty).toList();
    pathSegments.addAll(relativeSegments);

    return '${baseUri.scheme}://${baseUri.host}/${pathSegments.join('/')}';
  }
}

/// 数据模型
class HlsMasterPlaylist {
  final List<HlsVariant> variants;
  final List<HlsAudio> audios;
  final List<HlsSubtitle> subtitles;

  HlsMasterPlaylist({
    required this.variants,
    required this.audios,
    required this.subtitles,
  });
}

class HlsVariant {
  final String url;
  final int bandwidth;
  final String? resolution;
  final String? codecs;
  final double frameRate;

  HlsVariant({
    required this.url,
    required this.bandwidth,
    this.resolution,
    this.codecs,
    required this.frameRate,
  });
}

class HlsAudio {
  final String url;
  final String? language;
  final String? name;
  final String? groupId;

  HlsAudio({
    required this.url,
    this.language,
    this.name,
    this.groupId,
  });
}

class HlsSubtitle {
  final String url;
  final String? language;
  final String? name;
  final String? groupId;

  HlsSubtitle({
    required this.url,
    this.language,
    this.name,
    this.groupId,
  });
}

class HlsMediaPlaylist {
  final List<HlsSegment> segments;
  final int targetDuration;
  final bool isLive;

  HlsMediaPlaylist({
    required this.segments,
    required this.targetDuration,
    required this.isLive,
  });
}

class HlsSegment {
  final String url;
  final double duration;
  final String? title;
  final bool hasDiscontinuity; // 标记是否有不连续标记
  final int discontinuityGroup; // 不连续组编号

  HlsSegment({
    required this.url,
    required this.duration,
    this.title,
    this.hasDiscontinuity = false, // 默认为false
    this.discontinuityGroup = 0, // 默认为0组
  });
}

class HlsParserException implements Exception {
  final String message;

  HlsParserException(this.message);

  @override
  String toString() => 'HlsParserException: $message';
}