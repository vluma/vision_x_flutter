import 'package:flutter/material.dart';

/// 视频控制器配置模型
class VideoControlConfig {
  final bool isShortDramaMode;
  final bool isFullScreen;
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onToggleFullScreen;
  final bool showLockButton;
  final bool isLocked;
  final VoidCallback? onToggleLock;

  const VideoControlConfig({
    this.isShortDramaMode = false,
    this.isFullScreen = false,
    this.title,
    this.onBack,
    this.onToggleFullScreen,
    this.showLockButton = false,
    this.isLocked = false,
    this.onToggleLock,
  });

  VideoControlConfig copyWith({
    bool? isShortDramaMode,
    bool? isFullScreen,
    String? title,
    VoidCallback? onBack,
    VoidCallback? onToggleFullScreen,
    bool? showLockButton,
    bool? isLocked,
    VoidCallback? onToggleLock,
  }) {
    return VideoControlConfig(
      isShortDramaMode: isShortDramaMode ?? this.isShortDramaMode,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      title: title ?? this.title,
      onBack: onBack ?? this.onBack,
      onToggleFullScreen: onToggleFullScreen ?? this.onToggleFullScreen,
      showLockButton: showLockButton ?? this.showLockButton,
      isLocked: isLocked ?? this.isLocked,
      onToggleLock: onToggleLock ?? this.onToggleLock,
    );
  }
}

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

/// 手势状态模型
class GestureState {
  final bool isDragging;
  final bool isSeeking;
  final double seekSpeedMultiplier;
  final Duration dragStartPosition;
  final double dragStartX;

  const GestureState({
    this.isDragging = false,
    this.isSeeking = false,
    this.seekSpeedMultiplier = 1.0,
    this.dragStartPosition = Duration.zero,
    this.dragStartX = 0.0,
  });

  GestureState copyWith({
    bool? isDragging,
    bool? isSeeking,
    double? seekSpeedMultiplier,
    Duration? dragStartPosition,
    double? dragStartX,
  }) {
    return GestureState(
      isDragging: isDragging ?? this.isDragging,
      isSeeking: isSeeking ?? this.isSeeking,
      seekSpeedMultiplier: seekSpeedMultiplier ?? this.seekSpeedMultiplier,
      dragStartPosition: dragStartPosition ?? this.dragStartPosition,
      dragStartX: dragStartX ?? this.dragStartX,
    );
  }
}

/// UI状态模型
class UIState {
  final bool controlsVisible;
  final bool isLocked;
  final bool showBigPlayButton;
  final bool showSeekIndicator;
  final bool showSpeedIndicator;
  final double currentSpeed;

  const UIState({
    this.controlsVisible = true,
    this.isLocked = false,
    this.showBigPlayButton = false,
    this.showSeekIndicator = false,
    this.showSpeedIndicator = false,
    this.currentSpeed = 1.0,
  });

  UIState copyWith({
    bool? controlsVisible,
    bool? isLocked,
    bool? showBigPlayButton,
    bool? showSeekIndicator,
    bool? showSpeedIndicator,
    double? currentSpeed,
  }) {
    return UIState(
      controlsVisible: controlsVisible ?? this.controlsVisible,
      isLocked: isLocked ?? this.isLocked,
      showBigPlayButton: showBigPlayButton ?? this.showBigPlayButton,
      showSeekIndicator: showSeekIndicator ?? this.showSeekIndicator,
      showSpeedIndicator: showSpeedIndicator ?? this.showSpeedIndicator,
      currentSpeed: currentSpeed ?? this.currentSpeed,
    );
  }
}
