import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 视频播放页面专用的左滑返回手势组件
/// 避免与视频控制手势冲突
class VideoSwipeBackGesture extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  final bool enableSwipeBack;
  final double swipeThreshold; // 滑动阈值，默认屏幕宽度的1/4
  final Duration animationDuration;

  const VideoSwipeBackGesture({
    super.key,
    required this.child,
    this.onBackPressed,
    this.enableSwipeBack = true,
    this.swipeThreshold = 0.25,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<VideoSwipeBackGesture> createState() => _VideoSwipeBackGestureState();
}

class _VideoSwipeBackGestureState extends State<VideoSwipeBackGesture> {
  double _dragDistance = 0.0;
  bool _isDragging = false;
  bool _isAnimating = false;
  double _screenWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    
    if (!widget.enableSwipeBack) {
      return widget.child;
    }

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.translucent,
      child: widget.child.animate(
        target: _isAnimating ? 1 : 0,
      ).custom(
        duration: widget.animationDuration,
        builder: (context, value, child) {
          final slideOffset = value * _screenWidth;
          final currentOffset = _isDragging ? _dragDistance : slideOffset;
          final opacity = 1.0 - (value * (_dragDistance / _screenWidth));
          
          return Transform.translate(
            offset: Offset(currentOffset, 0.0),
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    // 只允许从屏幕左边缘开始滑动，且必须是水平滑动
    if (details.localPosition.dx > 30) {
      return;
    }
    
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    // 只处理向右的滑动
    if (details.delta.dx < 0) return;
    
    setState(() {
      _dragDistance = (_dragDistance + details.delta.dx).clamp(0.0, _screenWidth * 0.8);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    final dragRatio = _dragDistance / _screenWidth;
    final velocity = details.velocity.pixelsPerSecond.dx;
    
    // 判断是否应该触发返回
    bool shouldGoBack = dragRatio > widget.swipeThreshold || 
                       (dragRatio > 0.15 && velocity > 300);
    
    if (shouldGoBack) {
      _performBackAction();
    } else {
      _resetPosition();
    }
    
    setState(() {
      _isDragging = false;
    });
  }

  void _performBackAction() {
    setState(() {
      _isAnimating = true;
    });
    
    Future.delayed(widget.animationDuration, () {
      if (mounted) {
        widget.onBackPressed?.call();
      }
    });
  }

  void _resetPosition() {
    setState(() {
      _isAnimating = true;
    });
    
    Future.delayed(widget.animationDuration, () {
      if (mounted) {
        setState(() {
          _dragDistance = 0.0;
          _isAnimating = false;
        });
      }
    });
  }
}
