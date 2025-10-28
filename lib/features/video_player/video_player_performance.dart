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

    // 限制预加载数量，防止内存泄漏
    const maxPreloadCount = 3;
    if (_preloadedEpisodes.length >= maxPreloadCount) {
      clearOldestPreloadCache(maxPreloadCount - 1);
    }

    try {
      // 创建视频播放控制器并初始化
      final controller = VideoPlayerController.networkUrl(Uri.parse(episodeUrl));
      await controller.initialize();
      
      // 保存控制器以便后续使用
      _preloadedEpisodes[episodeUrl] = controller;
      
      if (kDebugMode) {
        print('预加载剧集成功: $episodeUrl (当前缓存数量: ${_preloadedEpisodes.length})');
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
      try {
        controller.dispose();
      } catch (e) {
        if (kDebugMode) {
          print('释放预加载控制器时出错: $e');
        }
      }
    }
    _preloadedEpisodes.clear();
    
    if (kDebugMode) {
      print('清理预加载缓存完成，共清理 ${_preloadedEpisodes.length} 个控制器');
    }
  }

  /// 清理指定数量的预加载缓存（用于内存管理）
  static void clearOldestPreloadCache(int keepCount) {
    if (_preloadedEpisodes.length <= keepCount) return;
    
    final entries = _preloadedEpisodes.entries.toList();
    final toRemove = entries.length - keepCount;
    
    for (int i = 0; i < toRemove; i++) {
      try {
        entries[i].value.dispose();
        _preloadedEpisodes.remove(entries[i].key);
      } catch (e) {
        if (kDebugMode) {
          print('释放旧预加载控制器时出错: $e');
        }
      }
    }
    
    if (kDebugMode) {
      print('清理了 $toRemove 个旧预加载缓存，剩余 ${_preloadedEpisodes.length} 个');
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
