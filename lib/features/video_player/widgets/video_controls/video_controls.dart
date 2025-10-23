import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_control_models.dart';
import 'short_drama_controls.dart';
import 'full_screen_controls.dart';
import 'normal_controls.dart';

/// 统一的视频控制器，根据模式自动选择合适的控制界面
class UnifiedVideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final UIState uiState;
  final String? title;
  final String? episodeTitle;
  final int currentEpisodeIndex;
  final int totalEpisodes;
  final ControlMode controlMode;

  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final VoidCallback? onToggleFullScreen;
  final VoidCallback? onToggleLock;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onPrevEpisode;
  final ValueChanged<double>? onSeek;
  final ValueChanged<double>? onSpeedChanged;
  final VoidCallback? onShowEpisodeSelector; // 添加剧集选择回调

  const UnifiedVideoControls({
    super.key,
    required this.controller,
    required this.uiState,
    this.title,
    this.episodeTitle,
    this.currentEpisodeIndex = 0,
    this.totalEpisodes = 0,
    this.controlMode = ControlMode.normal,
    this.onPlayPause,
    this.onBack,
    this.onToggleFullScreen,
    this.onToggleLock,
    this.onNextEpisode,
    this.onPrevEpisode,
    this.onSeek,
    this.onSpeedChanged,
    this.onShowEpisodeSelector, // 初始化剧集选择回调
  });

  @override
  Widget build(BuildContext context) {
    // 根据全屏状态和控制界面可见性决定是否隐藏鼠标指针
    final shouldHideCursor = uiState.isFullScreen && !uiState.controlsVisible;

    Widget controlsWidget;

    switch (controlMode) {
      case ControlMode.shortDrama:
        controlsWidget = ShortDramaControls(
          controller: controller,
          uiState: uiState,
          onPlayPause: onPlayPause,
          onBack: onBack,
          onSeek: onSeek,
        );

      case ControlMode.fullScreen:
        controlsWidget = FullScreenControls(
          controller: controller,
          uiState: uiState,
          title: title,
          onPlayPause: onPlayPause,
          onBack: onBack,
          onToggleFullScreen: onToggleFullScreen,
          onToggleLock: onToggleLock,
          onSeek: onSeek,
          onShowEpisodeSelector: onShowEpisodeSelector, // 传递剧集选择回调
          onSpeedChanged: onSpeedChanged, // 传递倍速选择回调
          currentSpeed: uiState.currentSpeed, // 传递当前播放速度
        );

      case ControlMode.normal:
        controlsWidget = NormalControls(
          controller: controller,
          uiState: uiState,
          title: title,
          onPlayPause: onPlayPause,
          onBack: onBack,
          onToggleFullScreen: onToggleFullScreen,
          onSeek: onSeek,
        );
    }

    // 只在全屏且控制界面隐藏时隐藏鼠标指针
    if (shouldHideCursor) {
      return MouseRegion(
        cursor: SystemMouseCursors.none, // 隐藏鼠标指针
        child: controlsWidget,
      );
    }

    return controlsWidget;
  }
}

/// 控制器模式枚举
enum ControlMode {
  normal, // 普通模式
  shortDrama, // 短剧模式
  fullScreen, // 全屏模式
}

/// 简化的控制器配置类
class VideoControlsConfig {
  final ControlMode mode;
  final bool showTitle;
  final bool showLockButton;
  final bool showEpisodeControls;
  final bool showSpeedControls;
  final Duration autoHideDelay;
  final Color themeColor;

  const VideoControlsConfig({
    this.mode = ControlMode.normal,
    this.showTitle = true,
    this.showLockButton = false,
    this.showEpisodeControls = false,
    this.showSpeedControls = true,
    this.autoHideDelay = const Duration(seconds: 3),
    this.themeColor = const Color(0xFF00D4FF),
  });

  VideoControlsConfig copyWith({
    ControlMode? mode,
    bool? showTitle,
    bool? showLockButton,
    bool? showEpisodeControls,
    bool? showSpeedControls,
    Duration? autoHideDelay,
    Color? themeColor,
  }) {
    return VideoControlsConfig(
      mode: mode ?? this.mode,
      showTitle: showTitle ?? this.showTitle,
      showLockButton: showLockButton ?? this.showLockButton,
      showEpisodeControls: showEpisodeControls ?? this.showEpisodeControls,
      showSpeedControls: showSpeedControls ?? this.showSpeedControls,
      autoHideDelay: autoHideDelay ?? this.autoHideDelay,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}

/// 简化的状态管理器
class VideoControlsState extends ChangeNotifier {
  UIState _uiState = const UIState();
  VideoControlsConfig _config = const VideoControlsConfig();

  UIState get uiState => _uiState;
  VideoControlsConfig get config => _config;

  void updateUIState(UIState newState) {
    _uiState = newState;
    notifyListeners();
  }

  void updateConfig(VideoControlsConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void toggleControlsVisibility() {
    _uiState = _uiState.copyWith(controlsVisible: !_uiState.controlsVisible);
    notifyListeners();
  }

  void toggleLock() {
    _uiState = _uiState.copyWith(isLocked: !_uiState.isLocked);
    notifyListeners();
  }
}

