import 'package:flutter/material.dart';

class ThemeProvider extends InheritedWidget {
  final int selectedTheme;
  final Function(int) updateTheme;

  const ThemeProvider({
    super.key,
    required this.selectedTheme,
    required this.updateTheme,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return selectedTheme != oldWidget.selectedTheme;
  }
}