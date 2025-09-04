import 'package:flutter/material.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';

/// 视频播放状态模型
class VideoPlayState {
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isBuffering;
  final double playbackSpeed;

  const VideoPlayState({
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isBuffering = false,
    this.playbackSpeed = 1.0,
  });

  String get formattedCurrentTime {
    final minutes = currentPosition.inMinutes.toString().padLeft(2, '0');
    final seconds = (currentPosition.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedTotalTime {
    final minutes = totalDuration.inMinutes.toString().padLeft(2, '0');
    final seconds = (totalDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }

  VideoPlayState copyWith({
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    bool? isBuffering,
    double? playbackSpeed,
  }) {
    return VideoPlayState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isBuffering: isBuffering ?? this.isBuffering,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

/// UI状态模型
class VideoPlayerUIState {
  final bool controlsVisible;
  final bool isLocked;
  final bool showBigPlayButton;
  final bool showSeekIndicator;
  final bool showSpeedIndicator;
  final double currentSpeed;

  const VideoPlayerUIState({
    this.controlsVisible = true,
    this.isLocked = false,
    this.showBigPlayButton = false,
    this.showSeekIndicator = false,
    this.showSpeedIndicator = false,
    this.currentSpeed = 1.0,
  });

  VideoPlayerUIState copyWith({
    bool? controlsVisible,
    bool? isLocked,
    bool? showBigPlayButton,
    bool? showSeekIndicator,
    bool? showSpeedIndicator,
    double? currentSpeed,
  }) {
    return VideoPlayerUIState(
      controlsVisible: controlsVisible ?? this.controlsVisible,
      isLocked: isLocked ?? this.isLocked,
      showBigPlayButton: showBigPlayButton ?? this.showBigPlayButton,
      showSeekIndicator: showSeekIndicator ?? this.showSeekIndicator,
      showSpeedIndicator: showSpeedIndicator ?? this.showSpeedIndicator,
      currentSpeed: currentSpeed ?? this.currentSpeed,
    );
  }
}

/// 视频播放配置模型
class VideoPlayerConfig {
  final bool isShortDramaMode;
  final bool isFullScreen;
  final String? title;
  final String? episodeTitle;
  final int currentEpisodeIndex;
  final int totalEpisodes;

  // 进度更新间隔
  static const Duration progressUpdateInterval = Duration(seconds: 30);

  // 播放速度选项
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // 预加载阈值（视频播放到90%时开始预加载）
  static const double preloadThreshold = 0.9;

  // 播放完成检测阈值（毫秒）
  static const int completionThresholdMs = 1000;

  const VideoPlayerConfig({
    this.isShortDramaMode = false,
    this.isFullScreen = false,
    this.title,
    this.episodeTitle,
    this.currentEpisodeIndex = 0,
    this.totalEpisodes = 0,
  });

  VideoPlayerConfig copyWith({
    bool? isShortDramaMode,
    bool? isFullScreen,
    String? title,
    String? episodeTitle,
    int? currentEpisodeIndex,
    int? totalEpisodes,
  }) {
    return VideoPlayerConfig(
      isShortDramaMode: isShortDramaMode ?? this.isShortDramaMode,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      title: title ?? this.title,
      episodeTitle: episodeTitle ?? this.episodeTitle,
      currentEpisodeIndex: currentEpisodeIndex ?? this.currentEpisodeIndex,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
    );
  }
}

/// 控制器模式枚举
enum ControlMode {
  normal, // 普通模式
  shortDrama, // 短剧模式
  fullScreen, // 全屏模式
}

/// 视频播放事件模型
class VideoPlayerEvent {
  final VideoPlayerEventType type;
  final dynamic data;

  VideoPlayerEvent({required this.type, this.data});
}

/// 视频播放事件类型
enum VideoPlayerEventType {
  play,
  pause,
  seek,
  complete,
  error,
  bufferingStart,
  bufferingEnd,
  durationReceived,
  progressUpdate,
  nextEpisode,
  prevEpisode,
  toggleFullScreen,
  toggleLock,
  speedChange,
}
