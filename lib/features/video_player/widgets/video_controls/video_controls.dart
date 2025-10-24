import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_control_models.dart';
import 'short_drama_controls.dart';
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
    return MouseRegion(
      cursor: uiState.controlsVisible && !uiState.isFullScreen
          ? SystemMouseCursors.click
          : SystemMouseCursors.none,
      child: _buildControlsByMode(),
    );
  }

  Widget _buildControlsByMode() {
    switch (controlMode) {
      case ControlMode.shortDrama:
        return ShortDramaControls(
          controller: controller,
          uiState: uiState,
          onPlayPause: onPlayPause,
          onBack: onBack,
          onSeek: onSeek,
        );
      case ControlMode.fullScreen:
        return NormalControls(
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
          playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0], // 传递播放速度选项
          currentSpeed: controller.value.playbackSpeed, // 传递当前播放速度
        );
      case ControlMode.normal:
        return NormalControls(
          controller: controller,
          uiState: uiState,
          title: title,
          onPlayPause: onPlayPause,
          onBack: onBack,
          onToggleFullScreen: onToggleFullScreen,
          onToggleLock: onToggleLock,
          onSeek: onSeek,
        );
    }
  }
}