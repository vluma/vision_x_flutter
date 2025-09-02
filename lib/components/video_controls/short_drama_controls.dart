import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_control_constants.dart';
import 'video_control_models.dart';
import 'video_control_widgets.dart' as custom_widgets;

/// 短剧模式控制组件
class ShortDramaControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VideoPlayState playState;
  final UIState uiState;
  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final ValueChanged<double>? onSeek;

  const ShortDramaControls({
    super.key,
    required this.controller,
    required this.playState,
    required this.uiState,
    this.onPlayPause,
    this.onBack,
    this.onSeek,
  });

  @override
  State<ShortDramaControls> createState() => _ShortDramaControlsState();
}

class _ShortDramaControlsState extends State<ShortDramaControls> {
  bool _isSpeedUpMode = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      onLongPressStart: _handleLongPressStart,
      onLongPressEnd: _handleLongPressEnd,
      onLongPressMoveUpdate: _handleLongPressMoveUpdate,
      child: Stack(
        children: [
          // 顶部返回按钮
          if (widget.uiState.controlsVisible)
            Positioned(
              top: VideoControlConstants.topPadding,
              left: VideoControlConstants.sidePadding,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onBack,
                ),
              ),
            ),

          // 中央播放按钮 - 只在暂停状态显示
          if (!widget.playState.isPlaying)
            Center(
              child: custom_widgets.BigPlayButton(
                isPlaying: widget.playState.isPlaying,
                onPressed: widget.onPlayPause,
              ),
            ),

          // 底部控制栏 - 始终显示进度条和时间
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),

          // 快进/快退指示器
          if (widget.uiState.showSeekIndicator)
            Center(child: _buildSeekIndicator()),

          // 速度指示器
          if (_isSpeedUpMode)
            Center(
              child: _buildSpeedIndicator(),
            ),
        ],
      ),
    );
  }

  void _handleTap() {
    if (widget.onPlayPause != null) {
      widget.onPlayPause!();
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.localPosition.dx;
    
    // 右半部分长按
    if (tapPosition > screenWidth / 2) {
      setState(() {
        _isSpeedUpMode = true;
      });
      
      // 如果暂停状态，先开始播放
      if (!widget.playState.isPlaying) {
        widget.controller.play();
      }
      
      widget.controller.setPlaybackSpeed(2.0);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isSpeedUpMode = false;
    });
    widget.controller.setPlaybackSpeed(1.0);
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    // 可以添加更多手势处理逻辑
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VideoControlConstants.sidePadding,
        vertical: 16.0,
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
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 进度条 - 始终显示
            custom_widgets.VideoProgressBar(
              controller: widget.controller,
              onSeek: widget.onSeek,
            ),
            const SizedBox(height: 8.0),
            // 时间和播放按钮 - 始终显示
            Row(
              children: [
                custom_widgets.TimeDisplay(
                  currentTime: widget.playState.formattedCurrentTime,
                  totalTime: widget.playState.formattedTotalTime,
                ),
                const Spacer(),
                custom_widgets.PlayPauseButton(
                  isPlaying: widget.playState.isPlaying,
                  onPressed: widget.onPlayPause,
                ),
              ],
            ),
          ],
        ),
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
      text: '${widget.playState.playbackSpeed.toStringAsFixed(1)}x',
      icon: Icons.speed,
    );
  }
}