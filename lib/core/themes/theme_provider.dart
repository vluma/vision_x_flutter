import 'package:flutter/material.dart';

/// 主题提供者
/// 用于在应用中切换主题
class ThemeProvider extends InheritedWidget {
  final int selectedTheme;
  final Function(int) updateTheme;

  const ThemeProvider({
    Key? key,
    required this.selectedTheme,
    required this.updateTheme,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return selectedTheme != oldWidget.selectedTheme;
  }

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }
}