import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'hls_parser_service.dart';

/// 增强的视频服务 - 集成广告检测和过滤
class EnhancedVideoService {
  static final EnhancedVideoService _instance = EnhancedVideoService._internal();
  factory EnhancedVideoService() => _instance;
  EnhancedVideoService._internal();

  final HlsParserService _hlsParser = HlsParserService();

  // 缓存
  final Map<String, String> _playlistCache = {};

  /// 处理视频URL，自动检测和过滤广告
  Future<ProcessedVideoResult> processVideoUrl(String originalUrl) async {
    try {
      // 检查缓存
      if (_playlistCache.containsKey(originalUrl)) {
        return ProcessedVideoResult(
          originalUrl: originalUrl,
          processedUrl: _playlistCache[originalUrl]!,
          isProcessed: true,
        );
      }

      // 判断是否为HLS流
      if (_isHlsStream(originalUrl)) {
        return await _processHlsStream(originalUrl);
      } else {
        // 非HLS流，直接返回原URL
        return ProcessedVideoResult(
          originalUrl: originalUrl,
          processedUrl: originalUrl,
          isProcessed: false,
        );
      }
    } catch (e) {
      // 处理失败，返回原URL
      return ProcessedVideoResult(
        originalUrl: originalUrl,
        processedUrl: originalUrl,
        isProcessed: false,
        error: e.toString(),
      );
    }
  }

  /// 判断是否为HLS流
  bool _isHlsStream(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.m3u8') || 
           lowerUrl.contains('application/vnd.apple.mpegurl') ||
           lowerUrl.contains('application/x-mpegurl');
  }

  /// 处理HLS流
  Future<ProcessedVideoResult> _processHlsStream(String originalUrl) async {
    try {
      // 使用HLS解析器的内置广告过滤功能
      final processedPlaylist = await _hlsParser.filterAdsAndRebuild(originalUrl);
      
      // 保存到本地服务器或缓存
      final processedUrl = await _saveProcessedPlaylist(processedPlaylist, originalUrl);
      
      // 缓存结果
      _playlistCache[originalUrl] = processedUrl;

      return ProcessedVideoResult(
        originalUrl: originalUrl,
        processedUrl: processedUrl,
        isProcessed: true,
      );
    } catch (e) {
      throw Exception('处理HLS流失败: $e');
    }
  }

  /// 保存处理后的播放列表
  Future<String> _saveProcessedPlaylist(String playlist, String originalUrl) async {
    // 为了简化，直接返回原始URL
    // 在实际应用中，这里应该保存到本地文件或云存储
    return originalUrl;
  }

  /// 清理缓存
  Future<void> clearCache() async {
    _playlistCache.clear();
    
    // 清理文件缓存
    final cacheDir = await _getCacheDirectory();
    final dir = Directory(cacheDir);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
      dir.createSync();
    }
  }

  /// 获取缓存目录
  Future<String> _getCacheDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheDir = prefs.getString('video_cache_dir');
    
    if (cacheDir != null && Directory(cacheDir).existsSync()) {
      return cacheDir;
    }
    
    // 使用默认缓存目录
    final defaultDir = '${Directory.current.path}/cache/video';
    final dir = Directory(defaultDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    
    await prefs.setString('video_cache_dir', defaultDir);
    return defaultDir;
  }

  /// 获取缓存统计
  Map<String, dynamic> getCacheStats() {
    return {
      'playlist_cache_size': _playlistCache.length,
      'cached_urls': _playlistCache.keys.toList(),
    };
  }

  /// 获取处理历史
  List<String> getProcessedUrls() {
    return _playlistCache.keys.toList();
  }
}

/// 处理结果
class ProcessedVideoResult {
  final String originalUrl;
  final String processedUrl;
  final bool isProcessed;
  final String? error;

  ProcessedVideoResult({
    required this.originalUrl,
    required this.processedUrl,
    required this.isProcessed,
    this.error,
  });

  @override
  String toString() {
    return 'ProcessedVideoResult('
        'original: $originalUrl, '
        'processed: $processedUrl, '
        'isProcessed: $isProcessed)';
  }
}
