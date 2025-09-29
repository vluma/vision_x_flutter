import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/utils/window_manager.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化窗口管理器（仅在桌面平台）
  debugPrint('Main: Platform.isWindows=${Platform.isWindows}, Platform.isMacOS=${Platform.isMacOS}, Platform.isLinux=${Platform.isLinux}');
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    debugPrint('Main: Initializing WindowManager for desktop platform');
    try {
      await WindowManager.initialize();
      debugPrint('Main: WindowManager initialized successfully');
    } catch (e) {
      debugPrint('Main: Failed to initialize WindowManager: $e');
    }
  } else {
    debugPrint('Main: Not a desktop platform, skipping WindowManager initialization');
  }
  
  runApp(
    const ProviderScope(
      child: VisionXApp(),
    ),
  );
}