import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';
import 'package:vision_x_flutter/core/themes/app_theme.dart';
import 'package:vision_x_flutter/core/themes/theme_provider.dart';

class VisionXApp extends StatefulWidget {
  const VisionXApp({super.key});

  @override
  State<VisionXApp> createState() => _VisionXAppState();
}

class _VisionXAppState extends State<VisionXApp> {
  int _selectedTheme = 0; // 0: system, 1: light, 2: dark

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getInt('selected_theme') ?? 0;
    });
  }

  Future<void> _updateTheme(int themeMode) async {
    setState(() {
      _selectedTheme = themeMode;
    });
    
    // 保存主题选择到 SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_theme', themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      selectedTheme: _selectedTheme,
      updateTheme: _updateTheme,
      child: MaterialApp.router(
        title: 'Vision X',
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: _getThemeMode(),
        routerConfig: router,
      ),
    );
  }

  ThemeMode _getThemeMode() {
    switch (_selectedTheme) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}