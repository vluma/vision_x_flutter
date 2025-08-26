import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 左滑返回手势组件
/// 用于二级页面的左滑返回功能
class SwipeBackGesture extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  final bool enableSwipeBack;
  final double swipeThreshold; // 滑动阈值，默认屏幕宽度的1/3
  final Duration animationDuration;

  const SwipeBackGesture({
    super.key,
    required this.child,
    this.onBackPressed,
    this.enableSwipeBack = true,
    this.swipeThreshold = 0.33,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SwipeBackGesture> createState() => _SwipeBackGestureState();
}

class _SwipeBackGestureState extends State<SwipeBackGesture> {
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
          final opacity = 1.0 - (value * (_dragDistance / _screenWidth));
          return Transform.translate(
            offset: Offset(_dragDistance * (1 - value), 0.0),
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
    // 只允许从屏幕左边缘开始滑动
    if (details.localPosition.dx > 50) {
      return;
    }
    
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    setState(() {
      _dragDistance = (_dragDistance + details.delta.dx).clamp(0.0, _screenWidth);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    final dragRatio = _dragDistance / _screenWidth;
    final velocity = details.velocity.pixelsPerSecond.dx;
    
    // 判断是否应该触发返回
    bool shouldGoBack = dragRatio > widget.swipeThreshold || 
                       (dragRatio > 0.1 && velocity > 500);
    
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
