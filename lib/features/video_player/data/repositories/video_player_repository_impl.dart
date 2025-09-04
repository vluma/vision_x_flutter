import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/domain/repositories/video_player_repository.dart';
import 'package:vision_x_flutter/services/history_service.dart';
import 'package:vision_x_flutter/services/hls_parser_service.dart';

/// 视频播放器仓库实现
class VideoPlayerRepositoryImpl implements VideoPlayerRepository {
  final HistoryService _historyService;
  final HlsParserService _hlsParserService;

  VideoPlayerRepositoryImpl({
    HistoryService? historyService,
    HlsParserService? hlsParserService,
  }) : _historyService = historyService ?? HistoryService(),
       _hlsParserService = hlsParserService ?? HlsParserService();

  @override
  Future<String> getVideoUrl(MediaDetail media, Episode episode) async {
    // 获取基础URL用于拼接可能不完整的视频URL
    final baseUrl = media.apiUrl ?? '';
    
    // 处理可能不完整的视频URL
    final resolvedUrl = baseUrl.isNotEmpty
        ? _resolveIncompleteUrl(episode.url, baseUrl)
        : episode.url;
        
    return resolvedUrl;
  }

  @override
  Future<String> processVideoUrl(String url, String baseUrl) async {
    try {
      // 处理可能不完整的视频URL
      final resolvedUrl = baseUrl.isNotEmpty
          ? _resolveIncompleteUrl(url, baseUrl)
          : url;
      
      // 判断是否为HLS流
      if (_isHlsStream(resolvedUrl)) {
        // 检查广告过滤是否启用
        final isAdFilterEnabled = await this.isAdFilterEnabled();

        if (!isAdFilterEnabled) {
          // 广告过滤已禁用，直接使用原始URL
          debugPrint('广告过滤功能已禁用，跳过广告检测');
          return resolvedUrl;
        } else {
          // 广告过滤已启用，执行广告过滤
          try {
            final processedPlaylist =
                await _hlsParserService.filterAdsAndRebuild(resolvedUrl);
            // 将处理后的播放列表保存到本地文件
            final processedUrl =
                await _saveProcessedPlaylist(processedPlaylist);

            // 返回处理后的URL
            debugPrint('HLS解析器处理完成，广告已过滤');
            return processedUrl;
          } catch (e) {
            debugPrint('HLS解析器处理失败: $e');
            // 处理失败时使用解析后的URL
            return resolvedUrl;
          }
        }
      } else {
        // 非HLS流，使用解析后的URL
        return resolvedUrl;
      }
    } catch (e) {
      debugPrint('处理视频URL失败: $e');
      return url;
    }
  }

  @override
  Future<void> savePlayHistory(MediaDetail media, Episode episode, int position, int duration) async {
    try {
      await _historyService.addHistory(media, episode, position, duration);
    } catch (e) {
      debugPrint('保存播放历史失败: $e');
    }
  }

  @override
  Future<void> updatePlayProgress(MediaDetail media, Episode episode, int position, int duration) async {
    try {
      await _historyService.updateHistoryProgress(media, episode, position, duration);
    } catch (e) {
      debugPrint('更新播放进度失败: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPlayerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'ad_filter_enabled': prefs.getBool('ad_filter_enabled') ?? true,
      'auto_next_episode': prefs.getBool('auto_next_episode') ?? true,
      'default_playback_speed': prefs.getDouble('default_playback_speed') ?? 1.0,
    };
  }

  @override
  Future<bool> isAdFilterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ad_filter_enabled') ?? true;
  }

  /// 保存处理后的播放列表到本地文件
  Future<String> _saveProcessedPlaylist(String playlist) async {
    try {
      // 获取文档目录
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'processed_playlist_${DateTime.now().millisecondsSinceEpoch}.m3u8';
      final filePath = '${directory.path}/$fileName';

      // 将播放列表写入文件
      final file = File(filePath);
      await file.writeAsString(playlist);

      // 返回文件URI
      return file.uri.toString();
    } catch (e) {
      debugPrint('保存处理后的播放列表失败: $e');
      rethrow;
    }
  }

  /// 判断是否为HLS流
  bool _isHlsStream(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.m3u8') ||
        lowerUrl.contains('application/vnd.apple.mpegurl') ||
        lowerUrl.contains('application/x-mpegurl');
  }

  /// 处理可能不完整的URL，与源地址拼接
  String _resolveIncompleteUrl(String url, String baseUrl) {
    // 如果URL已经是完整格式，直接返回
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    try {
      // 处理相对路径URL
      final baseUri = Uri.parse(baseUrl);

      // 如果是绝对路径（以/开头）
      if (url.startsWith('/')) {
        return '${baseUri.scheme}://${baseUri.host}$url';
      }

      // 处理相对路径
      final pathSegments = List<String>.from(baseUri.pathSegments);

      // 移除空的路径段
      pathSegments.removeWhere((element) => element.isEmpty);

      // 移除最后一级文件名，准备添加相对路径
      if (pathSegments.isNotEmpty && !baseUri.path.endsWith('/')) {
        pathSegments.removeLast();
      }

      // 分割并添加相对URL路径
      final relativeSegments =
          url.split('/').where((element) => element.isNotEmpty).toList();
      pathSegments.addAll(relativeSegments);

      return '${baseUri.scheme}://${baseUri.host}/${pathSegments.join('/')}';
    } catch (e) {
      debugPrint('URL解析错误: $e');
      // 如果解析失败，返回原始URL
      return url;
    }
  }
}