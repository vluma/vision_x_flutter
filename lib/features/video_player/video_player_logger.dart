import 'package:flutter/foundation.dart';

/// 视频播放错误类型
enum VideoPlayerErrorType {
  networkError,
  videoLoadError,
  episodeSwitchError,
  playbackError,
  unknownError,
}

/// 视频播放错误信息
class VideoPlayerError {
  final VideoPlayerErrorType type;
  final String message;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  VideoPlayerError({
    required this.type,
    required this.message,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return '[$timestamp] ${type.name}: $message${stackTrace != null ? '\n$stackTrace' : ''}';
  }
}

/// 视频播放日志记录器
class VideoPlayerLogger {
  static final List<VideoPlayerError> _errorLogs = [];
  static final List<String> _performanceLogs = [];

  /// 记录错误
  static void logError(VideoPlayerError error) {
    _errorLogs.add(error);
    if (kDebugMode) {
      print('❌ 视频播放错误: $error');
    }
  }

  /// 记录性能信息
  static void logPerformance(String message) {
    _performanceLogs.add('${DateTime.now()}: $message');
    if (kDebugMode) {
      print('📊 性能日志: $message');
    }
  }

  /// 获取错误日志
  static List<VideoPlayerError> getErrorLogs() => List.unmodifiable(_errorLogs);

  /// 获取性能日志
  static List<String> getPerformanceLogs() => List.unmodifiable(_performanceLogs);

  /// 清理日志
  static void clearLogs() {
    _errorLogs.clear();
    _performanceLogs.clear();
  }

  /// 记录剧集切换
  static void logEpisodeSwitch(int from, int to, bool success) {
    final message = '剧集切换: $from → $to ${success ? '成功' : '失败'}';
    logPerformance(message);
  }

  /// 记录播放状态
  static void logPlaybackState(String state, int progress, int? duration) {
    final message = '播放状态: $state, 进度: $progress/${duration ?? '未知'}';
    logPerformance(message);
  }
}

/// 错误处理工具
class VideoPlayerErrorHandler {
  /// 处理剧集切换错误
  static void handleEpisodeSwitchError(dynamic error, StackTrace stackTrace) {
    final videoError = VideoPlayerError(
      type: VideoPlayerErrorType.episodeSwitchError,
      message: '剧集切换失败: ${error.toString()}',
      stackTrace: stackTrace,
    );
    VideoPlayerLogger.logError(videoError);
  }

  /// 处理视频加载错误
  static void handleVideoLoadError(dynamic error, StackTrace stackTrace, String url) {
    final videoError = VideoPlayerError(
      type: VideoPlayerErrorType.videoLoadError,
      message: '视频加载失败: $url - ${error.toString()}',
      stackTrace: stackTrace,
    );
    VideoPlayerLogger.logError(videoError);
  }

  /// 处理网络错误
  static void handleNetworkError(dynamic error, StackTrace stackTrace) {
    final videoError = VideoPlayerError(
      type: VideoPlayerErrorType.networkError,
      message: '网络错误: ${error.toString()}',
      stackTrace: stackTrace,
    );
    VideoPlayerLogger.logError(videoError);
  }

  /// 处理播放错误
  static void handlePlaybackError(dynamic error, StackTrace stackTrace) {
    final videoError = VideoPlayerError(
      type: VideoPlayerErrorType.playbackError,
      message: '播放错误: ${error.toString()}',
      stackTrace: stackTrace,
    );
    VideoPlayerLogger.logError(videoError);
  }

  /// 处理未知错误
  static void handleUnknownError(dynamic error, StackTrace stackTrace) {
    final videoError = VideoPlayerError(
      type: VideoPlayerErrorType.unknownError,
      message: '未知错误: ${error.toString()}',
      stackTrace: stackTrace,
    );
    VideoPlayerLogger.logError(videoError);
  }
}

/// 用户行为分析
class VideoPlayerAnalytics {
  /// 记录用户播放行为
  static void logUserAction(String action, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      print('📈 用户行为: $action${parameters != null ? ', 参数: $parameters' : ''}');
    }
    // TODO: 集成实际的分析工具
  }

  /// 记录播放开始
  static void logPlayStart(String mediaId, String episodeId) {
    logUserAction('play_start', parameters: {
      'media_id': mediaId,
      'episode_id': episodeId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 记录播放完成
  static void logPlayComplete(String mediaId, String episodeId, int duration) {
    logUserAction('play_complete', parameters: {
      'media_id': mediaId,
      'episode_id': episodeId,
      'duration': duration,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 记录剧集切换
  static void logEpisodeChange(String mediaId, int fromEpisode, int toEpisode) {
    logUserAction('episode_change', parameters: {
      'media_id': mediaId,
      'from_episode': fromEpisode,
      'to_episode': toEpisode,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 记录播放暂停
  static void logPlayPause(String mediaId, String episodeId, int progress) {
    logUserAction('play_pause', parameters: {
      'media_id': mediaId,
      'episode_id': episodeId,
      'progress': progress,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}