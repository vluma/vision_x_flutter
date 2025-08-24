import 'package:flutter/material.dart';
import 'package:vision_x_flutter/theme/colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final Color? borderColor;

  const CustomCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.elevation,
    this.color,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: margin ?? const EdgeInsets.all(8.0),
      elevation: elevation ?? 2,
      color: color ?? (isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground),
      shadowColor: isDarkMode ? AppColors.darkShadow : AppColors.lightShadow,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        side: BorderSide(
          color: borderColor ?? (isDarkMode ? AppColors.darkBorder : AppColors.lightBorder),
          width: 0.5,
        ),
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}