import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';
import 'package:vision_x_flutter/core/themes/app_theme.dart';
import 'package:vision_x_flutter/core/themes/theme_provider.dart';
import 'package:vision_x_flutter/core/utils/startup_manager.dart';

class VisionXApp extends StatefulWidget {
  const VisionXApp({super.key});

  @override
  State<VisionXApp> createState() => _VisionXAppState();
}

class _VisionXAppState extends State<VisionXApp> {
  int _selectedTheme = 0; // 0: system, 1: light, 2: dark
  bool _startupUpdateChecked = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在依赖改变后检查更新（确保在首页加载后执行）
    if (!_startupUpdateChecked) {
      // 延迟执行更新检查，确保首页完全加载
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          StartupManager.checkForUpdates(context);
        }
      });
      _startupUpdateChecked = true;
    }
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

/// 路由观察器，用于检测首页出现
class AppNavigatorObserver extends NavigatorObserver {
  final VoidCallback onHomePageAppeared;

  AppNavigatorObserver({required this.onHomePageAppeared});

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _checkRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _checkRoute(newRoute);
    }
  }

  void _checkRoute(Route route) {
    // 检查是否是首页路由
    if (route.settings.name == '/' || 
        route.settings.name == null ||
        route.settings.name == '') {
      onHomePageAppeared();
    }
  }
}