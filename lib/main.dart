import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/utils/window_manager.dart';
import 'dart:io'
    show Platform, HttpClient, SecurityContext, X509Certificate, HttpOverrides;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // 在开发阶段允许所有证书，生产环境中应该更严格地验证证书
        debugPrint('Allowing bad certificate for host: $host, port: $port');
        return true;
      };
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 处理 HTTPS 证书验证问题
  HttpOverrides.global = MyHttpOverrides();

  // 初始化窗口管理器（仅在桌面平台）
  debugPrint(
      'Main: kIsWeb=$kIsWeb, Platform.isWindows=${!kIsWeb && (Platform.isWindows)}, Platform.isMacOS=${!kIsWeb && (Platform.isMacOS)}, Platform.isLinux=${!kIsWeb && (Platform.isLinux)}');
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    debugPrint('Main: Initializing WindowManager for desktop platform');
    try {
      await WindowManager.initialize();
      debugPrint('Main: WindowManager initialized successfully');
    } catch (e) {
      debugPrint('Main: Failed to initialize WindowManager: $e');
    }
  } else {
    debugPrint(
        'Main: Not a desktop platform, skipping WindowManager initialization');
  }

  runApp(
    const ProviderScope(
      child: VisionXApp(),
    ),
  );
}