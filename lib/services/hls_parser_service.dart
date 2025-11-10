import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HLS 解析器异常
class HlsParserException implements Exception {
  final String message;
  HlsParserException(this.message);

  @override
  String toString() => 'HlsParserException: $message';
}

/// HLS 主播放列表
class HlsMasterPlaylist {
  final List<HlsVariant> variants;
  final List<dynamic> audios;
  final List<dynamic> subtitles;

  HlsMasterPlaylist({
    required this.variants,
    required this.audios,
    required this.subtitles,
  });
}

/// HLS 媒体播放列表
class HlsMediaPlaylist {
  final List<HlsSegment> segments;
  final int targetDuration;
  final bool isLive;

  HlsMediaPlaylist({
    required this.segments,
    required this.targetDuration,
    this.isLive = false,
  });
}

/// HLS 视频流变体
class HlsVariant {
  final int bandwidth;
  final String? resolution;
  final String? codecs;
  final double frameRate;
  final String url;

  HlsVariant({
    required this.bandwidth,
    this.resolution,
    this.codecs,
    required this.frameRate,
    required this.url,
  });
}

/// HLS 片段
class HlsSegment {
  final String url;
  final double duration;

  HlsSegment({
    required this.url,
    required this.duration,
  });
}

/// HLS 解析器服务 - 集成 Better Player HLS 解析器
class HlsParserService {
  static final HlsParserService _instance = HlsParserService._internal();
  factory HlsParserService() => _instance;
  HlsParserService._internal();

  final Dio _dio = Dio();

  // 广告过滤设置
  bool _adFilterEnabled = true; // 全局广告过滤开关
  bool _adFilterByMetadata = true; // 合并码率和不连续标记检测

  /// 释放资源
  void dispose() {
    try {
      _dio.close();
      debugPrint('HlsParserService 资源已释放');
    } catch (e) {
      debugPrint('释放HlsParserService资源时出错: $e');
    }
  }

  /// 加载广告过滤设置
  Future<void> _loadAdFilterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _adFilterEnabled = prefs.getBool('ad_filter_enabled') ?? true;
    _adFilterByMetadata = prefs.getBool('ad_filter_by_metadata') ?? true;
  }

  /// 解析主播放列表 - 使用 Dio 获取内容
  Future<HlsMasterPlaylist> parseMasterPlaylist(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
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
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
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
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      return response.data as String;
    } catch (e) {
      throw HlsParserException('获取 HLS 内容失败: $e');
    }
  }

  /// 过滤广告并重新构建播放列表
  Future<String> filterAdsAndRebuild(String originalUrl) async {
    try {
      await _loadAdFilterSettings();

      // 如果全局广告过滤被禁用，直接返回原始播放列表内容
      if (!_adFilterEnabled) {
        debugPrint('广告过滤功能已禁用，跳过广告检测');
        final response = await _dio.get(originalUrl);
        return response.data as String;
      }

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
      final filteredSegments =
          await _detectAndFilterAds(mediaPlaylist, bestVariant);

      // 重新构建播放列表
      return _rebuildPlaylist(mediaPlaylist, filteredSegments, bestVariant.url);
    } catch (e) {
      throw HlsParserException('过滤广告失败: $e');
    }
  }
  
  /// 解析主播放列表内容
  HlsMasterPlaylist _parseMasterPlaylistContent(String content, String baseUrl) {
    // 简化的解析逻辑，实际项目中应该更完整
    final variants = <HlsVariant>[];
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length - 1; i++) {
      if (lines[i].startsWith('#EXT-X-STREAM-INF')) {
        // 解析流信息
        final bandwidthMatch = RegExp(r'BANDWIDTH=(\d+)').firstMatch(lines[i]);
        final bandwidth = bandwidthMatch != null ? int.parse(bandwidthMatch.group(1)!) : 0;
        
        final resolutionMatch = RegExp(r'RESOLUTION=([^,\n]+)').firstMatch(lines[i]);
        final resolution = resolutionMatch?.group(1);
        
        final codecsMatch = RegExp(r'CODECS="([^"]+)"').firstMatch(lines[i]);
        final codecs = codecsMatch?.group(1);
        
        final url = lines[i + 1].trim();
        i++; // 跳过下一行（URL行）
        
        variants.add(HlsVariant(
          bandwidth: bandwidth,
          resolution: resolution,
          codecs: codecs,
          frameRate: 0.0,
          url: url,
        ));
      }
    }
    
    return HlsMasterPlaylist(
      variants: variants,
      audios: [],
      subtitles: [],
    );
  }
  
  /// 解析媒体播放列表内容
  HlsMediaPlaylist _parseMediaPlaylistContent(String content, String baseUrl) {
    // 简化的解析逻辑，实际项目中应该更完整
    final segments = <HlsSegment>[];
    final lines = content.split('\n');
    int targetDuration = 10; // 默认值
    
    for (int i = 0; i < lines.length - 1; i++) {
      if (lines[i].startsWith('#EXT-X-TARGETDURATION')) {
        final durationMatch = RegExp(r'#EXT-X-TARGETDURATION:(\d+)').firstMatch(lines[i]);
        if (durationMatch != null) {
          targetDuration = int.parse(durationMatch.group(1)!);
        }
      } else if (lines[i].startsWith('#EXTINF')) {
        final durationMatch = RegExp(r'#EXTINF:([\d.]+)').firstMatch(lines[i]);
        final duration = durationMatch != null ? double.parse(durationMatch.group(1)!) : 0.0;
        final url = lines[i + 1].trim();
        i++; // 跳过下一行（URL行）
        
        segments.add(HlsSegment(
          url: url,
          duration: duration,
        ));
      }
    }
    
    return HlsMediaPlaylist(
      segments: segments,
      targetDuration: targetDuration,
      isLive: !content.contains('#EXT-X-ENDLIST'),
    );
  }
  
  /// 选择最佳变体
  HlsVariant? _selectBestVariant(List<HlsVariant> variants) {
    if (variants.isEmpty) return null;
    // 简单选择最高带宽的变体
    return variants.reduce((a, b) => a.bandwidth > b.bandwidth ? a : b);
  }
  
  /// 检测和过滤广告
  Future<List<HlsSegment>> _detectAndFilterAds(
      HlsMediaPlaylist mediaPlaylist, HlsVariant variant) async {
    // 简化的广告检测逻辑
    return mediaPlaylist.segments;
  }
  
  /// 重建播放列表
  String _rebuildPlaylist(HlsMediaPlaylist mediaPlaylist,
      List<HlsSegment> filteredSegments, String baseUrl) {
    // 简化的播放列表重建逻辑
    return '#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:${mediaPlaylist.targetDuration}\n';
  }
}