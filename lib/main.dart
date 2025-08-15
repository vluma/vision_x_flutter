import 'package:flutter/material.dart';
import 'package:vision_x_flutter/app_router.dart';
import 'package:vision_x_flutter/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vision X',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system, // 根据系统设置自动切换主题
      routerConfig: router,
    );
  }
}