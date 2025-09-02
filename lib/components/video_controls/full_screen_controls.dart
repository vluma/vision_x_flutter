import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_control_constants.dart';
import 'video_control_models.dart';
import 'video_control_widgets.dart' as custom_widgets;

/// 全屏模式控制组件
class FullScreenControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VideoPlayState playState;
  final UIState uiState;
  final String? title;
  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final VoidCallback? onToggleFullScreen;
  final VoidCallback? onToggleLock;
  final ValueChanged<double>? onSeek;

  const FullScreenControls({
    super.key,
    required this.controller,
    required this.playState,
    required this.uiState,
    this.title,
    this.onPlayPause,
    this.onBack,
    this.onToggleFullScreen,
    this.onToggleLock,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    if (uiState.isLocked) {
      return _buildLockedControls(context);
    }

    return Stack(
      children: [
        // 顶部标题栏
        if (uiState.controlsVisible)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(context),
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
            child: _buildBottomControls(context),
          ),

        // 右侧控制按钮
        if (uiState.controlsVisible)
          Positioned(
            right: VideoControlConstants.sidePadding,
            top: MediaQuery.of(context).size.height / 2 - 50,
            child: _buildRightControls(),
          ),

        // 快进/快退指示器
        if (uiState.showSeekIndicator) Center(child: _buildSeekIndicator()),

        // 速度指示器
        if (uiState.showSpeedIndicator) Center(child: _buildSpeedIndicator()),
      ],
    );
  }

  Widget _buildLockedControls(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: VideoControlConstants.sidePadding,
          top: MediaQuery.of(context).size.height / 2 - 15,
          child: custom_widgets.LockButton(
            isLocked: uiState.isLocked,
            onPressed: onToggleLock,
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: VideoControlConstants.topPadding +
            MediaQuery.of(context).padding.top,
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
          custom_widgets.LockButton(
            isLocked: uiState.isLocked,
            onPressed: onToggleLock,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: VideoControlConstants.bottomPadding +
            MediaQuery.of(context).padding.bottom,
        left: VideoControlConstants.sidePadding,
        right: VideoControlConstants.sidePadding,
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
        mainAxisSize: MainAxisSize.min,
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
                icon: Icons.fullscreen_exit,
                onPressed: onToggleFullScreen,
                tooltip: '退出全屏',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        custom_widgets.ControlButton(
          icon: Icons.fast_rewind,
          onPressed: () {},
          tooltip: '快退10秒',
        ),
        const SizedBox(height: 16.0),
        custom_widgets.ControlButton(
          icon: Icons.fast_forward,
          onPressed: () {},
          tooltip: '快进10秒',
        ),
      ],
    );
  }

  Widget _buildSeekIndicator() {
    return custom_widgets.Indicator(
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
