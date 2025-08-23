import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.elevation,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: margin ?? const EdgeInsets.all(8.0),
      elevation: elevation ?? 2,
      color: color ?? (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Container(
        padding: padding,
        child: child,
      ),
    );
  }
}