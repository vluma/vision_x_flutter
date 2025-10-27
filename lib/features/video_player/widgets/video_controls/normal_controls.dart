import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_control_constants.dart';
import 'video_control_models.dart';
import 'video_control_widgets.dart' as custom_widgets;

/// 普通模式控制组件（支持全屏模式）
class NormalControls extends StatefulWidget {
  final VideoPlayerController controller;
  final UIState uiState;
  final String? title;
  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final VoidCallback? onToggleFullScreen;
  final VoidCallback? onToggleLock;
  final ValueChanged<double>? onSeek;
  final VoidCallback? onShowEpisodeSelector; // 添加剧集选择回调
  final ValueChanged<double>? onSpeedChanged; // 添加倍速选择回调
  final List<double> playbackSpeeds; // 添加播放速度选项
  final double currentSpeed; // 添加当前播放速度

  const NormalControls({
    super.key,
    required this.controller,
    required this.uiState,
    this.title,
    this.onPlayPause,
    this.onBack,
    this.onToggleFullScreen,
    this.onToggleLock,
    this.onSeek,
    this.onShowEpisodeSelector, // 初始化剧集选择回调
    this.onSpeedChanged, // 初始化倍速选择回调
    this.playbackSpeeds = const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0], // 默认播放速度选项
    this.currentSpeed = 1.0, // 默认播放速度
  });

  @override
  State<NormalControls> createState() => _NormalControlsState();
}

class _NormalControlsState extends State<NormalControls> {
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
          // 顶部标题栏 (仅在非加速模式且未锁定状态下显示)
          if (widget.uiState.controlsVisible &&
              !_isSpeedUpMode &&
              !widget.uiState.isLocked)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(context),
            ),

          // 中央播放按钮 (仅在非加速模式且未锁定状态下显示)
          if (widget.uiState.showBigPlayButton &&
              !_isSpeedUpMode &&
              !widget.uiState.isLocked)
            Center(
              child: custom_widgets.BigPlayButton(
                isPlaying: widget.controller.value.isPlaying,
                onPressed: widget.onPlayPause,
              ),
            ),

          // 锁定控件 (仅在全屏模式下显示，锁定状态下始终显示解锁按钮)
          if (widget.uiState.isFullScreen && widget.uiState.controlsVisible && !_isSpeedUpMode)
            Positioned(
              top: 0,
              bottom: 0,
              right: 20,
              child: Center(
                child: custom_widgets.ControlButton(
                  icon: widget.uiState.isLocked ? Icons.lock_open : Icons.lock,
                  onPressed: widget.onToggleLock,
                  tooltip: widget.uiState.isLocked ? '解锁屏幕' : '锁定屏幕',
                ),
              ),
            ),

          // 底部控制栏 (仅在非加速模式且未锁定状态下显示)
          if (widget.uiState.controlsVisible &&
              !_isSpeedUpMode &&
              !widget.uiState.isLocked)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(context),
            ),

          // 快进/快退指示器 (仅在非加速模式且未锁定状态下显示)
          if (widget.uiState.showSeekIndicator &&
              !_isSpeedUpMode &&
              !widget.uiState.isLocked)
            Center(child: _buildSeekIndicator()),

          // 速度指示器 (仅在非加速模式且未锁定状态下显示)
          if (widget.uiState.showSpeedIndicator &&
              !_isSpeedUpMode &&
              !widget.uiState.isLocked)
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
    // 检查Widget是否仍然挂载
    if (!mounted) return;
    
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
    // 检查Widget是否仍然挂载
    if (!mounted) return;
    
    setState(() {
      _isSpeedUpMode = false;
    });
    widget.controller.setPlaybackSpeed(1.0);
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    // 检查Widget是否仍然挂载
    if (!mounted) return;
    // 可以添加更多手势处理逻辑
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: VideoControlConstants.topPadding +
            (widget.uiState.isFullScreen ? MediaQuery.of(context).padding.top : 0),
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
    // 获取ChewieController状态以确定是否处于全屏模式
    final isFullScreen = widget.uiState.isFullScreen;

    return Container(
      padding: EdgeInsets.only(
        bottom: (isFullScreen ? MediaQuery.of(context).padding.bottom : 0) + 15,
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

              // 添加倍速选择按钮（仅在全屏模式下显示）
              if (isFullScreen && widget.onSpeedChanged != null) _buildSpeedButton(),
              // 添加剧集选择按钮（仅在全屏模式下显示，带滑出动画）
              if (isFullScreen && widget.onShowEpisodeSelector != null)
                _buildEpisodeSelectorButton(),
              custom_widgets.ControlButton(
                icon: isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                onPressed: widget.onToggleFullScreen,
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
      text: '${widget.uiState.currentSpeed.toStringAsFixed(1)}x',
      icon: Icons.speed,
    );
  }

  /// 构建剧集选择按钮（带动画效果）
  Widget _buildEpisodeSelectorButton() {
    return AnimatedSwitcher(
      duration: VideoControlConstants.animationDuration,
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInBack,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: custom_widgets.ControlButton(
        key: const ValueKey('episode_button'),
        icon: Icons.video_library,
        onPressed: widget.onShowEpisodeSelector,
        tooltip: '选择剧集',
      ),
    );
  }

  /// 构建倍速选择按钮
  Widget _buildSpeedButton() {
    return PopupMenuButton<double>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '${widget.currentSpeed.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
      tooltip: '播放速度',
      color: VideoControlConstants.cardBackgroundColor, // 修改弹窗背景色
      onSelected: widget.onSpeedChanged,
      itemBuilder: (context) {
        return widget.playbackSpeeds.map((speed) {
          return PopupMenuItem<double>(
            value: speed,
            child: Row(
              children: [
                if (speed == widget.currentSpeed)
                  Icon(Icons.check,
                      size: 18, color: VideoControlConstants.primaryColor)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(
                  '${speed}x',
                  style: TextStyle(
                    color: speed == widget.currentSpeed
                        ? VideoControlConstants.primaryColor // 使用主题主色
                        : VideoControlConstants.textColor, // 使用文本颜色
                    fontWeight: speed == widget.currentSpeed
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
