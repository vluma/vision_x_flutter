import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_control_constants.dart';

/// 返回按钮组件
class BackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final Color color;

  const BackButton({
    super.key,
    this.onPressed,
    this.size = VideoControlConstants.backButtonSize,
    this.color = VideoControlConstants.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, size: size, color: color),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

/// 播放/暂停按钮组件
class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onPressed;
  final double size;
  final Color color;

  const PlayPauseButton({
    super.key,
    required this.isPlaying,
    this.onPressed,
    this.size = VideoControlConstants.playButtonSize,
    this.color = VideoControlConstants.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        size: size,
        color: color,
      ),
      onPressed: onPressed,
    );
  }
}

/// 大播放按钮组件
class BigPlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onPressed;
  final double size;
  final Color color;

  const BigPlayButton({
    super.key,
    required this.isPlaying,
    this.onPressed,
    this.size = VideoControlConstants.pauseIconSize,
    this.color = VideoControlConstants.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        size: size,
        color: color.withValues(alpha: 0.7),
      ),
    );
  }
}

/// 锁定按钮组件
class LockButton extends StatelessWidget {
  final bool isLocked;
  final VoidCallback? onPressed;
  final double size;
  final Color color;

  const LockButton({
    super.key,
    required this.isLocked,
    this.onPressed,
    this.size = VideoControlConstants.lockButtonSize,
    this.color = VideoControlConstants.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isLocked ? Icons.lock : Icons.lock_open,
        size: size,
        color: color,
      ),
      onPressed: onPressed,
    );
  }
}

/// 时间显示组件
class TimeDisplay extends StatelessWidget {
  final String currentTime;
  final String totalTime;
  final TextStyle? style;

  const TimeDisplay({
    super.key,
    required this.currentTime,
    required this.totalTime,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$currentTime / $totalTime',
      style: style ?? VideoControlConstants.timeStyle,
    );
  }
}

/// 进度条组件
class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final VideoProgressColors colors;
  final double height;
  final double? expandedHeight;
  final ValueChanged<double>? onSeek;

  const VideoProgressBar({
    super.key,
    required this.controller,
    this.colors = VideoControlConstants.progressColors,
    this.height = 4.0,
    this.expandedHeight,
    this.onSeek,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  bool _isDragging = false;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    final baseHeight = widget.height;
    final currentHeight = _isDragging && widget.expandedHeight != null
        ? widget.expandedHeight!
        : baseHeight;

    return Container(
      height: currentHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(currentHeight / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(currentHeight / 2),
        child: _CustomVideoProgressIndicator(
          controller: _controller,
          colors: widget.colors,
          onDragStart: _onDragStart,
          onDragEnd: _onDragEnd,
        ),
      ),
    );
  }

  void _onDragStart() {
    if (widget.expandedHeight != null) {
      setState(() {
        _isDragging = true;
      });
    }
  }

  void _onDragEnd() {
    if (widget.expandedHeight != null) {
      setState(() {
        _isDragging = false;
      });
    }
  }
}

class _CustomVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  final VideoProgressColors colors;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const _CustomVideoProgressIndicator({
    required this.controller,
    required this.colors,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  State<_CustomVideoProgressIndicator> createState() =>
      _CustomVideoProgressIndicatorState();
}

class _CustomVideoProgressIndicatorState
    extends State<_CustomVideoProgressIndicator> {
  _CustomVideoProgressIndicatorState() {
    listener = () {
      if (!mounted) return;
      setState(() {});
    };
  }

  late VoidCallback listener;

  @override
  void initState() {
    super.initState();
    // 安全地添加监听器，检查控制器是否已被销毁
    try {
      if (mounted) {
        widget.controller.addListener(listener);
      }
    } catch (e) {
      // 如果控制器已被销毁，忽略错误
      debugPrint('Controller already disposed: $e');
    }
  }

  @override
  void deactivate() {
    // 安全地移除监听器
    try {
      widget.controller.removeListener(listener);
    } catch (e) {
      // 如果控制器已被销毁，忽略错误
      debugPrint('Controller already disposed during deactivate: $e');
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    // 检查当前Widget是否仍然挂载
    if (!mounted) {
      // 如果未挂载，返回空的进度条
      return Container(
        height: 4.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.0),
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      );
    }

    VideoPlayerController controller = widget.controller;

    // 检查控制器是否有效
    try {
      controller.value;
    } catch (e) {
      // 如果控制器已被销毁，返回空的进度条
      return Container(
        height: 4.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.0),
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      );
    }

    void seekToRelativePosition(Offset globalPosition) {
      // 检查当前Widget是否仍然挂载
      if (!mounted) return;

      try {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.globalToLocal(globalPosition);
        final double relative = (offset.dx / box.size.width).clamp(0.0, 1.0);
        controller.seekTo(
          Duration(
            milliseconds:
                (controller.value.duration.inMilliseconds * relative).round(),
          ),
        );
      } catch (e) {
        // 如果控制器已被销毁，忽略操作
        debugPrint('Controller disposed during seek: $e');
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!mounted) return;
        widget.onDragStart();
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!mounted) return;
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (!mounted) return;
        widget.onDragEnd();
      },
      onTapDown: (TapDownDetails details) {
        if (!mounted) return;
        seekToRelativePosition(details.globalPosition);
      },
      child: CustomPaint(
        painter: _ProgressBarPainter(
          controller: controller,
          colors: widget.colors,
        ),
        size: const Size(double.infinity, double.infinity),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final VideoPlayerController controller;
  final VideoProgressColors colors;

  _ProgressBarPainter({
    required this.controller,
    required this.colors,
  });

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final value = controller.value;
    final paint = Paint()
      ..color = colors.backgroundColor
      ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(Offset.zero & size, paint);

    // Draw buffered part
    final double? bufferedEnd = value.isInitialized && value.buffered.isNotEmpty
        ? value.buffered.last.end.inMilliseconds / value.duration.inMilliseconds
        : 0.0;
    if (bufferedEnd != null && bufferedEnd > 0) {
      paint.color = colors.bufferedColor;
      canvas.drawRect(
        Offset.zero & Size(size.width * bufferedEnd, size.height),
        paint,
      );
    }

    // Draw played part
    if (value.isInitialized) {
      paint.color = colors.playedColor;
      canvas.drawRect(
        Offset.zero &
            Size(
              size.width *
                  value.position.inMilliseconds /
                  value.duration.inMilliseconds,
              size.height,
            ),
        paint,
      );
    }
  }
}

/// 控制按钮组件
class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color color;
  final String? tooltip;

  const ControlButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = VideoControlConstants.controlButtonSize,
    this.color = VideoControlConstants.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

/// 渐变背景组件
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: VideoControlConstants.gradientDecoration,
      child: child,
    );
  }
}

/// 指示器组件
class Indicator extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const Indicator({
    super.key,
    required this.text,
    required this.icon,
    this.backgroundColor = Colors.black54,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20.0),
          const SizedBox(width: 8.0),
          Text(text, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}
