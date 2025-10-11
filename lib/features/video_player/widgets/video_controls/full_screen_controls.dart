import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_control_constants.dart';
import 'video_control_models.dart';
import 'video_control_widgets.dart' as custom_widgets;

/// 全屏模式控制组件
class FullScreenControls extends StatefulWidget {
  final VideoPlayerController controller;
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
    required this.uiState,
    this.title,
    this.onPlayPause,
    this.onBack,
    this.onToggleFullScreen,
    this.onToggleLock,
    this.onSeek,
  });

  @override
  State<FullScreenControls> createState() => _FullScreenControlsState();
}

class _FullScreenControlsState extends State<FullScreenControls> {
  bool _isSpeedUpMode = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: _handleLongPressStart,
      onLongPressEnd: _handleLongPressEnd,
      onLongPressMoveUpdate: _handleLongPressMoveUpdate,
      child: Stack(
        children: [
          // 顶部标题栏 (仅在非加速模式下显示)
          if (widget.uiState.controlsVisible && !_isSpeedUpMode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(context),
            ),

          // 中央播放按钮 (仅在非加速模式下显示)
          if (widget.uiState.showBigPlayButton && !_isSpeedUpMode)
            Center(
              child: custom_widgets.BigPlayButton(
                isPlaying: widget.controller.value.isPlaying,
                onPressed: widget.onPlayPause,
              ),
            ),

          // 锁定控件 (仅在非加速模式下显示)
          if (widget.uiState.controlsVisible && !_isSpeedUpMode)
            Positioned(
              top: 0,
              bottom: 0,
              right: 20,
              child: Center(
                child: custom_widgets.ControlButton(
                  icon: widget.uiState.isLocked ? Icons.lock : Icons.lock_open,
                  onPressed: widget.onToggleLock,
                  tooltip: widget.uiState.isLocked ? '解锁屏幕' : '锁定屏幕',
                ),
              ),
            ),

          // 底部控制栏 (仅在非加速模式下显示)
          if (widget.uiState.controlsVisible && !_isSpeedUpMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(context),
            ),

          // 快进/快退指示器 (仅在非加速模式下显示)
          if (widget.uiState.showSeekIndicator && !_isSpeedUpMode)
            Center(child: _buildSeekIndicator()),

          // 速度指示器 (仅在非加速模式下显示)
          if (widget.uiState.showSpeedIndicator && !_isSpeedUpMode)
            Center(child: _buildSpeedIndicator()),

          // 2倍速指示器 (仅在加速模式下显示，位于顶部居中)
          if (_isSpeedUpMode)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '2.0x',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
      if (!widget.controller.value.isPlaying) {
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
          custom_widgets.BackButton(
            onPressed: widget.onBack,
          ),
          const SizedBox(width: 16.0),
          if (widget.title != null)
            Expanded(
              child: Text(
                widget.title!,
                style: VideoControlConstants.titleStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 15,
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
            controller: widget.controller,
            onSeek: widget.onSeek,
          ),
          const SizedBox(height: 8.0),
          // 控制按钮
          Row(
            children: [
              custom_widgets.PlayPauseButton(
                isPlaying: widget.controller.value.isPlaying,
                onPressed: widget.onPlayPause,
              ),
              const SizedBox(width: 16.0),
              custom_widgets.TimeDisplay(
                currentTime: _formatDuration(widget.controller.value.position),
                totalTime: _formatDuration(widget.controller.value.duration),
              ),
              const Spacer(),
              custom_widgets.ControlButton(
                icon: Icons.fullscreen_exit,
                onPressed: widget.onToggleFullScreen,
                tooltip: '退出全屏',
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
      text: '${widget.uiState.currentSpeed.toStringAsFixed(1)}x',
      icon: Icons.speed,
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
