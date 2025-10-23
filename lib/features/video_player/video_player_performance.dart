import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// 视频播放性能优化管理器
class VideoPlayerPerformance {
  /// 预加载管理器
  static final Map<String, VideoPlayerController> _preloadedEpisodes = {};

  /// 预加载剧集
  static Future<void> preloadEpisode(String episodeUrl) async {
    // 检查是否已经预加载
    if (_preloadedEpisodes.containsKey(episodeUrl)) {
      return;
    }

    try {
      // 创建视频播放控制器并初始化
      final controller = VideoPlayerController.networkUrl(Uri.parse(episodeUrl));
      await controller.initialize();
      
      // 保存控制器以便后续使用
      _preloadedEpisodes[episodeUrl] = controller;
      
      if (kDebugMode) {
        print('预加载剧集成功: $episodeUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('预加载剧集失败: $episodeUrl, 错误: $e');
      }
    }
  }

  /// 获取预加载的视频控制器
  static VideoPlayerController? getPreloadedController(String episodeUrl) {
    return _preloadedEpisodes[episodeUrl];
  }

  /// 清理预加载缓存
  static void clearPreloadCache() {
    // 释放所有预加载的控制器
    for (final controller in _preloadedEpisodes.values) {
      controller.dispose();
    }
    _preloadedEpisodes.clear();
    
    if (kDebugMode) {
      print('清理预加载缓存');
    }
  }

  /// 检查是否已预加载
  static bool isPreloaded(String episodeUrl) {
    return _preloadedEpisodes.containsKey(episodeUrl);
  }

  /// 批量预加载
  static Future<void> preloadMultiple(List<String> episodeUrls) async {
    for (final url in episodeUrls) {
      await preloadEpisode(url);
      // 添加小延迟避免同时加载过多资源
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
