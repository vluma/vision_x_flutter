import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as vp;

/// 视频控制组件常量
class VideoControlConstants {
  // 尺寸
  static const double backButtonSize = 24.0;
  static const double playButtonSize = 24.0;
  static const double pauseIconSize = 64.0;
  static const double lockButtonSize = 24.0;
  static const double controlButtonSize = 24.0;
  
  // 颜色
  static const Color iconColor = Colors.white;
  static const Color progressBackgroundColor = Colors.white24;
  static const Color progressBufferedColor = Colors.white38;
  static const Color progressPlayedColor = Colors.white;
  
  // 样式
  static const TextStyle timeStyle = TextStyle(
    color: Colors.white,
    fontSize: 12.0,
  );
  
  // 渐变背景
  static const BoxDecoration gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.black54, Colors.transparent],
    ),
  );
  
  // 进度条颜色
  static const VideoProgressColors progressColors = VideoProgressColors(
    backgroundColor: progressBackgroundColor,
    bufferedColor: progressBufferedColor,
    playedColor: progressPlayedColor,
  );
}

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
        color: color.withOpacity(0.7),
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

/// 进度条颜色
class VideoProgressColors {
  final Color backgroundColor;
  final Color bufferedColor;
  final Color playedColor;

  const VideoProgressColors({
    required this.backgroundColor,
    required this.bufferedColor,
    required this.playedColor,
  });
}

/// 进度条组件
class VideoProgressBar extends StatefulWidget {
  final vp.VideoPlayerController controller;
  final VideoProgressColors colors;
  final double height;
  final double? expandedHeight;
  final ValueChanged<double>? onSeek;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const VideoProgressBar({
    super.key,
    required this.controller,
    this.colors = VideoControlConstants.progressColors,
    this.height = 4.0,
    this.expandedHeight,
    this.onSeek,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  bool _isDragging = false;
  late vp.VideoPlayerController _controller;

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
          onDragStart: () {
            _onDragStart();
            widget.onDragStart?.call();
          },
          onDragEnd: () {
            _onDragEnd();
            widget.onDragEnd?.call();
          },
          onSeek: widget.onSeek,
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
  final vp.VideoPlayerController controller;
  final VideoProgressColors colors;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final ValueChanged<double>? onSeek;

  const _CustomVideoProgressIndicator({
    required this.controller,
    required this.colors,
    required this.onDragStart,
    required this.onDragEnd,
    this.onSeek,
  });

  @override
  State<_CustomVideoProgressIndicator> createState() => _CustomVideoProgressIndicatorState();
}

class _CustomVideoProgressIndicatorState extends State<_CustomVideoProgressIndicator> {
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
    widget.controller.addListener(listener);
  }

  @override
  void deactivate() {
    widget.controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    vp.VideoPlayerController controller = widget.controller;

    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject() as RenderBox;
      final offset = box.globalToLocal(globalPosition);
      final double relative = (offset.dx / box.size.width).clamp(0.0, 1.0);
      
      if (widget.onSeek != null) {
        widget.onSeek!(relative);
      } else {
        controller.seekTo(
          Duration(
            milliseconds:
                (controller.value.duration.inMilliseconds * relative).round(),
          ),
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        widget.onDragStart();
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        widget.onDragEnd();
      },
      onTapDown: (TapDownDetails details) {
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
  final vp.VideoPlayerController controller;
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
    if (value.isInitialized && value.buffered.isNotEmpty) {
      final double bufferedEnd = value.buffered.last.end.inMilliseconds /
          value.duration.inMilliseconds;
      
      paint.color = colors.bufferedColor;
      canvas.drawRect(
        Offset.zero & Size(size.width * bufferedEnd, size.height),
        paint,
      );
    }

    // Draw played part
    if (value.isInitialized && value.duration.inMilliseconds > 0) {
      paint.color = colors.playedColor;
      final double playedPart = value.position.inMilliseconds / 
          value.duration.inMilliseconds;
      
      canvas.drawRect(
        Offset.zero & Size(size.width * playedPart, size.height),
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