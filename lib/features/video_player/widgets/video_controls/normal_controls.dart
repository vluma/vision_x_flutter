import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_control_constants.dart';
import 'video_control_models.dart';
import 'video_control_widgets.dart' as custom_widgets;

/// 普通模式控制组件
class NormalControls extends StatelessWidget {
  final VideoPlayerController controller;
  final UIState uiState;
  final String? title;
  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final VoidCallback? onToggleFullScreen;
  final ValueChanged<double>? onSeek;

  const NormalControls({
    super.key,
    required this.controller,
    required this.uiState,
    this.title,
    this.onPlayPause,
    this.onBack,
    this.onToggleFullScreen,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 顶部标题栏
        if (uiState.controlsVisible)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

        // 中央播放按钮
        if (uiState.showBigPlayButton)
          Center(
            child: custom_widgets.BigPlayButton(
              isPlaying: controller.value.isPlaying,
              onPressed: onPlayPause,
            ),
          ),

        // 底部控制栏
        if (uiState.controlsVisible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(context),
          ),

        // 快进/快退指示器
        if (uiState.showSeekIndicator) Center(child: _buildSeekIndicator()),

        // 速度指示器
        if (uiState.showSpeedIndicator) Center(child: _buildSpeedIndicator()),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(
        top: VideoControlConstants.topPadding,
        left: VideoControlConstants.sidePadding,
        right: VideoControlConstants.sidePadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: VideoControlConstants.iconColor),
            onPressed: onBack,
          ),
          const SizedBox(width: 16.0),
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: VideoControlConstants.titleStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    // 获取ChewieController状态以确定是否处于全屏模式
    final isFullScreen = uiState.isFullScreen;
    
    return Container(
      height: VideoControlConstants.bottomPadding,
      padding: const EdgeInsets.symmetric(
        horizontal: VideoControlConstants.sidePadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 进度条
          custom_widgets.VideoProgressBar(
            controller: controller,
            onSeek: onSeek,
          ),
          // 控制按钮
          Row(
            children: [
              custom_widgets.PlayPauseButton(
                isPlaying: controller.value.isPlaying,
                onPressed: onPlayPause,
              ),
              const SizedBox(width: 16.0),
              custom_widgets.TimeDisplay(
                currentTime: _formatDuration(controller.value.position),
                totalTime: _formatDuration(controller.value.duration),
              ),
              const Spacer(),
              custom_widgets.ControlButton(
                icon: isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                onPressed: onToggleFullScreen,
                tooltip: isFullScreen ? '退出全屏' : '全屏',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeekIndicator() {
    return const custom_widgets.Indicator(
      text: '快进',
      icon: Icons.fast_forward,
    );
  }

  Widget _buildSpeedIndicator() {
    return custom_widgets.Indicator(
      text: '${uiState.currentSpeed.toStringAsFixed(1)}x',
      icon: Icons.speed,
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}