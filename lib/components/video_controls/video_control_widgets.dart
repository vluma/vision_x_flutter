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
class VideoProgressBar extends StatelessWidget {
  final VideoPlayerController controller;
  final VideoProgressColors colors;
  final double height;
  final ValueChanged<double>? onSeek;

  const VideoProgressBar({
    super.key,
    required this.controller,
    this.colors = VideoControlConstants.progressColors,
    this.height = 4.0,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      padding: EdgeInsets.zero,
      colors: colors,
    );
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
