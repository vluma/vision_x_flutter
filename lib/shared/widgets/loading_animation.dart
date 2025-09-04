import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingAnimation extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        color: showBackground ? backgroundColor : Colors.transparent,
        child: Center(
          child: SizedBox(
            width: constraints.maxWidth * sizeRatio,
            height: constraints.maxWidth * sizeRatio,
            child: _buildAnimatedLoading(),
          ),
        ),
      );
    });
  }

  Widget _buildAnimatedLoading() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 外层旋转圆环
        ...List.generate(5, (index) {
          return CustomPaint(
            size: Size.infinite,
            painter: _LoadingArcPainter(
              color: color,
              index: index,
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).rotate(
            duration: const Duration(seconds: 2),
            begin: 0,
            end: 1,
            curve: Curves.linear,
          );
        }),
        
        // 中心圆点
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color ?? Colors.blue,
            shape: BoxShape.circle,
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).scale(
          duration: const Duration(milliseconds: 800),
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          curve: Curves.easeInOut,
        ).then().scale(
          duration: const Duration(milliseconds: 800),
          begin: const Offset(1.2, 1.2),
          end: const Offset(0.8, 0.8),
          curve: Curves.easeInOut,
        ),
      ],
    );
  }
}

class _LoadingArcPainter extends CustomPainter {
  final Color? color;
  final int index;

  _LoadingArcPainter({this.color, required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final radius = maxRadius * (0.2 + (index * 0.2));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 15
      ..strokeCap = StrokeCap.round;

    if (color != null) {
      paint.color = color!;
    } else {
      // 使用HSV色彩空间创建渐变色效果
      final hue = (index * 30) % 360;
      paint.color = HSVColor.fromAHSV(1.0, hue.toDouble(), 0.8, 0.9).toColor();
    }

    // 绘制圆弧
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      index * 1.25, // 错开每个圆弧的起始角度
      1.5, // 圆弧长度
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
