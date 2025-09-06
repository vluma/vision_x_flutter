import 'package:flutter/material.dart';

/// 主题提供者
/// 用于在应用中切换主题
class ThemeProvider extends InheritedWidget {
  final int selectedTheme;
  final Function(int) updateTheme;

  const ThemeProvider({
    super.key,
    required this.selectedTheme,
    required this.updateTheme,
    required super.child,
  });

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return selectedTheme != oldWidget.selectedTheme;
  }

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }
}