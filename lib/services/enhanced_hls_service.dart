import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'hls_parser_service.dart';
import 'ts_segment_analyzer.dart';

/// 增强版 HLS 解析服务 - 集成 Better Player HLS 解析器
class EnhancedHlsService {
  static final EnhancedHlsService _instance = EnhancedHlsService._internal();
  factory EnhancedHlsService() => _instance;
  EnhancedHlsService._internal();

  /// 解析 HLS 内容并返回详细信息
  Future<HlsAnalysisResult> analyzeHls(String url) async {
    try {
      final hlsParser = HlsParserService();

      // 1. 获取 HLS 内容
      debugPrint('正在获取 HLS 内容: $url');
      final content = await hlsParser.fetchHlsContent(url);
      debugPrint('HLS 内容长度: ${content.length} 字符');
      debugPrint('HLS 内容预览:\n${content.substring(0, min(1000, content.length))}');
      debugPrint('完整 HLS 内容:\n$content');

      // 2. 首先尝试解析为主播放列表，如果失败则作为媒体播放列表处理
      debugPrint('正在解析播放列表...');
      HlsMasterPlaylist? masterPlaylist;
      HlsMediaPlaylist? directMediaPlaylist;

      try {
        masterPlaylist = await hlsParser.parseMasterPlaylist(url);
        debugPrint('成功解析为主播放列表: ${masterPlaylist.variants.length} 个视频流');
      } catch (e) {
        debugPrint('主播放列表解析失败，尝试作为媒体播放列表解析: $e');
        try {
          directMediaPlaylist = await hlsParser.parseMediaPlaylist(url);
          debugPrint('成功解析为媒体播放列表: ${directMediaPlaylist.segments.length} 个片段');
        } catch (mediaError) {
          debugPrint('媒体播放列表解析也失败: $mediaError');
          throw HlsParserException('无法解析 HLS 文件: 主播放列表和媒体播放列表都解析失败');
        }
      }

      HlsVariant? bestVariant;
      HlsMediaPlaylist? mediaPlaylist;

      // 3. 处理不同的播放列表类型
      if (masterPlaylist != null) {
        // 这是主播放列表，需要选择最佳流然后解析媒体播放列表
        debugPrint('发现 ${masterPlaylist.variants.length} 个视频流');
        for (var variant in masterPlaylist.variants) {
          debugPrint('  流: 带宽=${variant.bandwidth}, 分辨率=${variant.resolution}, URL=${variant.url}');
        }

        bestVariant = _selectBestVariant(masterPlaylist.variants);
        debugPrint('选择最佳流: 带宽=${bestVariant?.bandwidth}, URL=${bestVariant?.url}');

        // 4. 解析媒体播放列表（如果有最佳流）
        if (bestVariant != null) {
          try {
            debugPrint('正在解析媒体播放列表: ${bestVariant.url}');
            mediaPlaylist = await hlsParser.parseMediaPlaylist(bestVariant.url);
            debugPrint('媒体播放列表解析完成: ${mediaPlaylist.segments.length} 个片段, 目标时长=${mediaPlaylist.targetDuration}秒');
          } catch (e) {
            // 媒体播放列表解析失败，但主播放列表成功，继续处理
            debugPrint('警告：媒体播放列表解析失败: $e');
          }
        }
      } else if (directMediaPlaylist != null) {
        // 这直接就是媒体播放列表
        debugPrint('直接使用媒体播放列表: ${directMediaPlaylist.segments.length} 个片段');
        mediaPlaylist = directMediaPlaylist;

        // 创建一个虚拟的主播放列表信息（用于兼容性）
        masterPlaylist = HlsMasterPlaylist(
          variants: [], // 空列表，因为这是直接的媒体播放列表
          audios: [],
          subtitles: [],
        );
      } else {
        debugPrint('未发现任何有效的播放列表');
        throw HlsParserException('无法识别的 HLS 文件格式');
      }

      // 5. 分析内容特征
      final contentAnalysis = await _analyzeContent(content, url);

      debugPrint('内容分析完成:');
      debugPrint('  内容类型: ${contentAnalysis.contentType}');
      debugPrint('  片段数量: ${contentAnalysis.segmentCount}');
      debugPrint('  总时长: ${contentAnalysis.totalDuration}');
      debugPrint('  是否直播: ${contentAnalysis.isLive}');

      // 6. 分析 TS 片段（如果有媒体播放列表）
      List<EnhancedTsSegmentAnalysis> enhancedTsAnalyses = [];
      if (mediaPlaylist != null && mediaPlaylist.segments.isNotEmpty) {
        debugPrint('开始增强分析 TS 片段...');
        try {
          enhancedTsAnalyses = await _analyzeTsSegmentsEnhanced(mediaPlaylist.segments, url);
          debugPrint('TS 片段增强分析完成，共分析 ${enhancedTsAnalyses.length} 个片段');
        } catch (e) {
          debugPrint('TS 片段增强分析失败: $e');
          enhancedTsAnalyses = []; // 确保始终返回非空列表
        }
      }

      return HlsAnalysisResult(
        url: url,
        content: content,
        masterPlaylist: masterPlaylist,
        mediaPlaylist: mediaPlaylist,
        bestVariant: bestVariant,
        contentAnalysis: contentAnalysis,
        enhancedTsAnalyses: enhancedTsAnalyses,
        parsedAt: DateTime.now(),
      );
    } catch (e) {
      throw HlsParserException('HLS 分析失败: $e');
    }
  }

  /// 选择最佳质量的视频流
  HlsVariant? _selectBestVariant(List<HlsVariant> variants) {
    if (variants.isEmpty) return null;

    // 按带宽排序，选择最高质量的流
    variants.sort((a, b) => b.bandwidth.compareTo(a.bandwidth));
    return variants.first;
  }

  /// 分析 HLS 内容特征
  Future<HlsContentAnalysis> _analyzeContent(String content, String url) async {
    debugPrint('开始详细分析 HLS 内容...');
    final lines = const LineSplitter().convert(content);

    int extTags = 0;
    int streamInfTags = 0;
    int targetDurationTags = 0;
    int mediaSequenceTags = 0;
    int discontinuityTags = 0;
    int endListTags = 0;
    int segmentCount = 0;
    double totalDuration = 0;
    final List<String> uniqueHosts = [];
    final List<String> segmentUrls = [];
    final Map<String, int> tagFrequency = {};

    bool isLive = false;
    bool hasEncryption = false;
    bool hasSubtitles = false;
    bool hasMultipleAudio = false;

    debugPrint('解析 ${lines.length} 行内容...');

    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      debugPrint('行 ${i + 1}: "$trimmed"');

      if (trimmed.startsWith('#EXT')) {
        extTags++;
        final tag = trimmed.split(':')[0];
        tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;

        debugPrint('发现 EXT 标签: $trimmed');

        if (trimmed.startsWith('#EXT-X-STREAM-INF')) {
          streamInfTags++;
        } else if (trimmed.startsWith('#EXT-X-TARGETDURATION')) {
          targetDurationTags++;
        } else if (trimmed.startsWith('#EXT-X-MEDIA-SEQUENCE')) {
          mediaSequenceTags++;
        } else if (trimmed.startsWith('#EXT-X-DISCONTINUITY')) {
          discontinuityTags++;
        } else if (trimmed.startsWith('#EXT-X-ENDLIST')) {
          endListTags++;
          isLive = false;
        } else if (trimmed.startsWith('#EXT-X-KEY')) {
          hasEncryption = true;
        } else if (trimmed.startsWith('#EXT-X-MEDIA') && trimmed.contains('TYPE=SUBTITLES')) {
          hasSubtitles = true;
        } else if (trimmed.startsWith('#EXT-X-MEDIA') && trimmed.contains('TYPE=AUDIO')) {
          hasMultipleAudio = true;
        }
      } else if (!trimmed.startsWith('#') && trimmed.isNotEmpty) {
        // 这是一个 URL 行
        segmentCount++;
        segmentUrls.add(trimmed);
        debugPrint('发现片段 URL [$segmentCount]: $trimmed');

        // 提取主机名
        try {
          final uri = Uri.parse(trimmed);
          if (uri.host.isNotEmpty && !uniqueHosts.contains(uri.host)) {
            uniqueHosts.add(uri.host);
          }
        } catch (_) {
          // 忽略无效 URL
        }
      } else if (trimmed.startsWith('#EXTINF')) {
        // 解析时长
        final durationMatch = RegExp(r'#EXTINF:([\d.]+)').firstMatch(trimmed);
        if (durationMatch != null) {
          final duration = double.tryParse(durationMatch.group(1)!) ?? 0;
          totalDuration += duration;
          debugPrint('EXTINF 时长: $duration, 累计时长: $totalDuration');
        } else {
          debugPrint('无法解析 EXTINF 时长: $trimmed');
        }
      }
    }

    debugPrint('基础分析完成:');
    debugPrint('  - EXT 标签数: $extTags');
    debugPrint('  - 片段 URL 数: $segmentCount');
    debugPrint('  - 累计时长: $totalDuration');
    debugPrint('  - 发现的片段 URLs:');
    for (int i = 0; i < segmentUrls.length; i++) {
      debugPrint('    [${i + 1}] ${segmentUrls[i]}');
    }

    // 如果没有 #EXT-X-ENDLIST 标记，认为是直播
    if (endListTags == 0 && targetDurationTags > 0) {
      isLive = true;
    }

    // 如果没有找到片段但有流信息，可能是主播放列表
    String detectedContentType = _detectContentType(content);
    if (segmentCount == 0 && streamInfTags > 0) {
      detectedContentType = 'Master Playlist';
      debugPrint('检测为主播放列表，包含 $streamInfTags 个视频流');
    } else if (segmentCount > 0) {
      detectedContentType = 'Media Playlist';
      debugPrint('检测为媒体播放列表，包含 $segmentCount 个片段');
    }

    return HlsContentAnalysis(
      totalLines: lines.length,
      extTags: extTags,
      streamInfTags: streamInfTags,
      targetDurationTags: targetDurationTags,
      mediaSequenceTags: mediaSequenceTags,
      discontinuityTags: discontinuityTags,
      endListTags: endListTags,
      segmentCount: segmentCount,
      totalDuration: totalDuration,
      uniqueHosts: uniqueHosts,
      tagFrequency: tagFrequency,
      isLive: isLive,
      hasEncryption: hasEncryption,
      hasSubtitles: hasSubtitles,
      hasMultipleAudio: hasMultipleAudio,
      contentType: detectedContentType,
      version: _extractHlsVersion(content),
    );
  }

  /// 检测内容类型
  String _detectContentType(String content) {
    if (content.contains('#EXT-X-STREAM-INF')) {
      return 'Master Playlist';
    } else if (content.contains('#EXTINF')) {
      return 'Media Playlist';
    } else {
      return 'Unknown';
    }
  }

  /// 提取 HLS 版本
  int _extractHlsVersion(String content) {
    final versionMatch = RegExp(r'#EXT-X-VERSION:(\d+)').firstMatch(content);
    return versionMatch != null ? int.tryParse(versionMatch.group(1)!) ?? 1 : 1;
  }

  /// 生成 HLS 分析报告
  String generateReport(HlsAnalysisResult result) {
    final buffer = StringBuffer();

    buffer.writeln('=== HLS 分析报告 ===');
    buffer.writeln('分析时间: ${result.parsedAt}');
    buffer.writeln('原始 URL: ${result.url}');
    buffer.writeln('');

    // 内容分析
    buffer.writeln('--- 内容分析 ---');
    final analysis = result.contentAnalysis;
    buffer.writeln('内容类型: ${analysis.contentType}');
    buffer.writeln('HLS 版本: ${analysis.version}');
    buffer.writeln('总行数: ${analysis.totalLines}');
    buffer.writeln('EXT 标签数: ${analysis.extTags}');
    buffer.writeln('视频流数: ${analysis.streamInfTags}');
    buffer.writeln('片段总数: ${analysis.segmentCount}');
    buffer.writeln('总时长: ${analysis.totalDuration.toStringAsFixed(2)} 秒');
    buffer.writeln('唯一主机数: ${analysis.uniqueHosts.length}');
    buffer.writeln('是否直播: ${analysis.isLive ? '是' : '否'}');
    buffer.writeln('是否加密: ${analysis.hasEncryption ? '是' : '否'}');
    buffer.writeln('是否字幕: ${analysis.hasSubtitles ? '是' : '否'}');
    buffer.writeln('多音轨: ${analysis.hasMultipleAudio ? '是' : '否'}');
    buffer.writeln('');

    // 主机列表
    if (analysis.uniqueHosts.isNotEmpty) {
      buffer.writeln('--- 主机列表 ---');
      for (final host in analysis.uniqueHosts) {
        buffer.writeln('  - $host');
      }
      buffer.writeln('');
    }

    // 标签频率
    if (analysis.tagFrequency.isNotEmpty) {
      buffer.writeln('--- 标签频率 ---');
      final sortedTags = analysis.tagFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedTags) {
        buffer.writeln('  ${entry.key}: ${entry.value}');
      }
      buffer.writeln('');
    }

    // 主播放列表信息
    if (result.masterPlaylist != null) {
      buffer.writeln('--- 主播放列表 ---');
      buffer.writeln('视频流数: ${result.masterPlaylist!.variants.length}');
      buffer.writeln('音频流数: ${result.masterPlaylist!.audios.length}');
      buffer.writeln('字幕数: ${result.masterPlaylist!.subtitles.length}');
      buffer.writeln('');

      // 最佳流信息
      if (result.bestVariant != null) {
        final variant = result.bestVariant!;
        buffer.writeln('--- 最佳质量流 ---');
        buffer.writeln('带宽: ${variant.bandwidth} bps');
        buffer.writeln('分辨率: ${variant.resolution ?? '未知'}');
        buffer.writeln('编码: ${variant.codecs ?? '未知'}');
        buffer.writeln('帧率: ${variant.frameRate} fps');
        buffer.writeln('URL: ${variant.url}');
        buffer.writeln('');
      }
    }

    // 媒体播放列表信息
    if (result.mediaPlaylist != null) {
      buffer.writeln('--- 媒体播放列表 ---');
      buffer.writeln('片段数: ${result.mediaPlaylist!.segments.length}');
      buffer.writeln('目标时长: ${result.mediaPlaylist!.targetDuration} 秒');
      buffer.writeln('是否直播: ${result.mediaPlaylist!.isLive ? '是' : '否'}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// 分析 TS 片段
  Future<List<TsSegmentAnalysis>> _analyzeTsSegments(List<HlsSegment> segments, String baseUrl) async {
    try {
      final tsAnalyzer = TsSegmentAnalyzer();
      final List<String> tsUrls = [];

      // 收集 TS 文件 URL（限制前5个以节省时间）
      final int maxSegments = min(5, segments.length);
      for (int i = 0; i < maxSegments; i++) {
        final segment = segments[i];
        final tsUrl = _resolveTsUrl(segment.url, baseUrl);
        if (tsUrl.isNotEmpty) {
          tsUrls.add(tsUrl);
        }
      }

      debugPrint('准备分析 ${tsUrls.length} 个 TS 片段:');
      for (int i = 0; i < tsUrls.length; i++) {
        debugPrint('  [${i + 1}] ${tsUrls[i]}');
      }

      // 如果没有有效的 TS URL，返回空列表
      if (tsUrls.isEmpty) {
        debugPrint('没有找到有效的 TS URL');
        return [];
      }

      // 分析 TS 片段
      final analyses = await tsAnalyzer.analyzeSegments(tsUrls, sampleSize: 1024 * 20); // 20KB 采样

      // 输出分析结果
      for (final analysis in analyses) {
        debugPrint('TS 片段分析结果:');
        debugPrint('  URL: ${analysis.url}');
        debugPrint('  大小: ${analysis.dataSize ~/ 1024} KB');
        debugPrint('  包数: ${analysis.packetCount}');
        debugPrint('  有效包: ${analysis.validPackets} (${analysis.packetValidity.toStringAsFixed(1)}%)');
        debugPrint('  PID 数: ${analysis.uniquePids}');
        debugPrint('  流类型: ${analysis.streamType}');
        debugPrint('  估算带宽: ${(analysis.estimatedBandwidth / 1000).toStringAsFixed(1)} Kbps');
      }

      return analyses;
    } catch (e) {
      debugPrint('TS 片段分析过程中出现错误: $e');
      // 返回空列表而不是抛出异常，确保调用方能正常处理
      return [];
    }
  }

  /// 解析 TS URL
  String _resolveTsUrl(String segmentUrl, String baseUrl) {
    if (segmentUrl.startsWith('http://') || segmentUrl.startsWith('https://')) {
      return segmentUrl;
    }

    try {
      final baseUri = Uri.parse(baseUrl);
      final pathSegments = List<String>.from(baseUri.pathSegments);

      if (pathSegments.isNotEmpty) {
        pathSegments.removeLast(); // 移除 m3u8 文件名
      }

      final resolvedPath = '${pathSegments.join('/')}/$segmentUrl';
      final tsUri = baseUri.resolve(resolvedPath);

      return tsUri.toString();
    } catch (e) {
      debugPrint('解析 TS URL 失败: $segmentUrl, 错误: $e');
      return '';
    }
  }

  /// 增强分析 TS 片段（新方法）
  Future<List<EnhancedTsSegmentAnalysis>> _analyzeTsSegmentsEnhanced(List<HlsSegment> segments, String baseUrl) async {
    try {
      final tsAnalyzer = TsSegmentAnalyzer();
      final List<String> tsUrls = [];

      // 收集 TS 文件 URL（限制前5个以节省时间）
      final int maxSegments = min(5, segments.length);
      for (int i = 0; i < maxSegments; i++) {
        final segment = segments[i];
        final tsUrl = _resolveTsUrl(segment.url, baseUrl);
        if (tsUrl.isNotEmpty) {
          tsUrls.add(tsUrl);
        }
      }

      debugPrint('准备增强分析 ${tsUrls.length} 个 TS 片段:');
      for (int i = 0; i < tsUrls.length; i++) {
        debugPrint('  [${i + 1}] ${tsUrls[i]}');
      }

      // 如果没有有效的 TS URL，返回空列表
      if (tsUrls.isEmpty) {
        debugPrint('没有找到有效的 TS URL');
        return [];
      }

      // 使用增强分析方法
      final analyses = await tsAnalyzer.analyzeSegmentsEnhanced(tsUrls, maxSize: 1024 * 1024 * 5); // 5MB 限制

      // 输出增强分析结果
      debugPrint('增强分析结果汇总:');
      for (int i = 0; i < analyses.length; i++) {
        final analysis = analyses[i];
        debugPrint('片段 ${i + 1}: 健康度=${analysis.healthDescription}(${analysis.healthScore.toStringAsFixed(1)}分)');
        debugPrint('  包统计: ${analysis.detailedAnalysis.validPackets}/${analysis.detailedAnalysis.totalPackets}');
        debugPrint('  PID 数量: ${analysis.detailedAnalysis.uniquePids}');
        if (analysis.detailedAnalysis.videoPid != null) {
          debugPrint('  视频 PID: ${analysis.detailedAnalysis.videoPid!.pid} (${analysis.detailedAnalysis.videoPid!.packetCount} 包)');
        }
        if (analysis.detailedAnalysis.audioPid != null) {
          debugPrint('  音频 PID: ${analysis.detailedAnalysis.audioPid!.pid} (${analysis.detailedAnalysis.audioPid!.packetCount} 包)');
        }
      }

      return analyses;
    } catch (e) {
      debugPrint('增强 TS 片段分析过程出现严重错误: $e');
      return [];
    }
  }
}

/// HLS 分析结果
class HlsAnalysisResult {
  final String url;
  final String content;
  final HlsMasterPlaylist? masterPlaylist;
  final HlsMediaPlaylist? mediaPlaylist;
  final HlsVariant? bestVariant;
  final HlsContentAnalysis contentAnalysis;
  final List<EnhancedTsSegmentAnalysis> enhancedTsAnalyses;
  final DateTime parsedAt;

  HlsAnalysisResult({
    required this.url,
    required this.content,
    this.masterPlaylist,
    this.mediaPlaylist,
    this.bestVariant,
    required this.contentAnalysis,
    required this.enhancedTsAnalyses,
    required this.parsedAt,
  });
}

/// HLS 内容分析结果
class HlsContentAnalysis {
  final int totalLines;
  final int extTags;
  final int streamInfTags;
  final int targetDurationTags;
  final int mediaSequenceTags;
  final int discontinuityTags;
  final int endListTags;
  final int segmentCount;
  final double totalDuration;
  final List<String> uniqueHosts;
  final Map<String, int> tagFrequency;
  final bool isLive;
  final bool hasEncryption;
  final bool hasSubtitles;
  final bool hasMultipleAudio;
  final String contentType;
  final int version;

  HlsContentAnalysis({
    required this.totalLines,
    required this.extTags,
    required this.streamInfTags,
    required this.targetDurationTags,
    required this.mediaSequenceTags,
    required this.discontinuityTags,
    required this.endListTags,
    required this.segmentCount,
    required this.totalDuration,
    required this.uniqueHosts,
    required this.tagFrequency,
    required this.isLive,
    required this.hasEncryption,
    required this.hasSubtitles,
    required this.hasMultipleAudio,
    required this.contentType,
    required this.version,
  });
}
