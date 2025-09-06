import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_control_constants.dart';
import 'video_control_models.dart';
import 'video_control_widgets.dart' as custom_widgets;

/// 普通模式控制组件
class NormalControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VideoPlayState playState;
  final UIState uiState;
  final String? title;
  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final VoidCallback? onToggleFullScreen;
  final ValueChanged<double>? onSeek;

  const NormalControls({
    super.key,
    required this.controller,
    required this.playState,
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
              isPlaying: playState.isPlaying,
              onPressed: onPlayPause,
            ),
          ),

        // 底部控制栏
        if (uiState.controlsVisible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
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
            icon: const Icon(Icons.arrow_back),
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

  Widget _buildBottomControls() {
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
          const SizedBox(height: 8.0),
          // 控制按钮
          Row(
            children: [
              custom_widgets.PlayPauseButton(
                isPlaying: playState.isPlaying,
                onPressed: onPlayPause,
              ),
              const SizedBox(width: 16.0),
              custom_widgets.TimeDisplay(
                currentTime: playState.formattedCurrentTime,
                totalTime: playState.formattedTotalTime,
              ),
              const Spacer(),
              custom_widgets.ControlButton(
                icon: Icons.fullscreen,
                onPressed: onToggleFullScreen,
                tooltip: '全屏',
              ),
            ],
          ),
          const SizedBox(height: 8.0),
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
}
