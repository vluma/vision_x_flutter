import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'video_control_constants.dart';
import 'video_control_models.dart';
import 'video_control_widgets.dart' as custom_widgets;

/// 短剧模式控制组件
class ShortDramaControls extends StatefulWidget {
  final VideoPlayerController controller;
  final UIState uiState;
  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final ValueChanged<double>? onSeek;

  const ShortDramaControls({
    super.key,
    required this.controller,
    required this.uiState,
    this.onPlayPause,
    this.onBack,
    this.onSeek,
  });

  @override
  State<ShortDramaControls> createState() => _ShortDramaControlsState();
}

// 定义一套更浅的白灰色调进度条颜色
const _subtleProgressColors = VideoProgressColors(
  playedColor: Color(0xFFEEEEEE), // 已播放部分使用非常浅的灰色
  bufferedColor: Color(0xFFDDDDDD), // 缓冲部分使用浅灰色
  backgroundColor: Color(0xFFCCCCCC), // 背景使用更浅的灰色
);

class _ShortDramaControlsState extends State<ShortDramaControls> {
  bool _isSpeedUpMode = false;
  bool _isDraggingProgress = false;

  @override
  void initState() {
    super.initState();
    // 监听播放器状态变化
    widget.controller.addListener(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  void _onPlayerStateChanged() {
    // 强制重建UI以响应播放状态变化
    if (mounted) {
      setState(() {});
    }
  }

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
          // 添加半透明黑色背景（只在拖动进度条时显示）
          if (_isDraggingProgress)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 300,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

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

          // 中央播放按钮 - 只在暂停状态且控制栏可见时显示
          if (!widget.controller.value.isPlaying &&
              widget.uiState.controlsVisible)
            Center(
              child: custom_widgets.BigPlayButton(
                isPlaying: widget.controller.value.isPlaying,
                onPressed: widget.onPlayPause,
              ),
            ),

          // 底部控制栏 - 始终显示进度条和时间
          Positioned(
            bottom: VideoControlConstants.bottomPadding,
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            child: _buildBottomControls(),
          ),

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

  Widget _buildBottomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 添加时间显示（只在拖动进度条时显示）
        if (_isDraggingProgress)
          Text(
            '${_formatDuration(widget.controller.value.position)} / ${_formatDuration(widget.controller.value.duration)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        if (_isDraggingProgress) const SizedBox(height: 20),
        custom_widgets.VideoProgressBar(
          controller: widget.controller,
          onSeek: widget.onSeek,
          height: 2,
          expandedHeight: 6,
          colors: _subtleProgressColors,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildSpeedIndicator() {
    return custom_widgets.Indicator(
      text: '${widget.controller.value.playbackSpeed.toStringAsFixed(1)}x',
      icon: Icons.speed,
    );
  }
}
