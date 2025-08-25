import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  /// 是否显示背景色，默认为false（透明背景）
  final bool showBackground;

  /// 背景色，默认为灰色
  final Color backgroundColor;

  /// 加载动画颜色，默认使用彩色
  final Color? color;

  /// 加载动画大小，相对于容器的比例，默认0.3
  final double sizeRatio;

  const LoadingAnimation({
    super.key,
    this.showBackground = false,
    this.backgroundColor = Colors.grey,
    this.color,
    this.sizeRatio = 0.3,
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingPainter extends CustomPainter {
  final double progress;
  final Color? color;

  _LoadingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // 绘制多个旋转的圆弧形成加载动画
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 15
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final rotation = (progress * 2 * 3.14159) - (i * 1.25);
      final radius = maxRadius * (0.2 + (i * 0.2));
      final startAngle = rotation;
      const sweepAngle = 1.5;

      if (color != null) {
        // 使用指定颜色
        paint.color = color!;
      } else {
        // 使用HSV色彩空间创建渐变色效果
        final hue = (progress * 360 + i * 30) % 360;
        paint.color = HSVColor.fromAHSV(1.0, hue, 0.8, 0.9).toColor();
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // 绘制中心圆点，使用半透明白色以适应不同背景
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withValues(alpha: 0.8);
    canvas.drawCircle(center, size.width / 15, paint);

    if (color != null) {
      paint.color = color!;
    } else {
      paint.color = HSVColor.fromAHSV(1.0, progress * 360, 0.8, 0.9).toColor();
    }
    canvas.drawCircle(center, size.width / 25, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        color:
            widget.showBackground ? widget.backgroundColor : Colors.transparent,
        child: Center(
          child: SizedBox(
            width: constraints.maxWidth * widget.sizeRatio,
            height: constraints.maxWidth * widget.sizeRatio,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _LoadingPainter(_animation.value, widget.color),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
