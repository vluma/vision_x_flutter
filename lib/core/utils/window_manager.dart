import 'dart:io' show Platform;
import 'dart:ui' show Size, Offset, Rect;

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

/// 窗口管理类，用于处理桌面端窗口操作
class WindowManager {
  static bool _isInitialized = false;
  static bool _isFullScreen = false; // 标记窗口是否已全屏

  /// 初始化窗口管理器
  static Future<void> initialize() async {
    debugPrint('WindowManager: initialize called, _isInitialized=$_isInitialized, _isDesktop=${_isDesktop}');
    if (_isInitialized) return;
    
    // 只在桌面平台初始化
    if (_isDesktop) {
      try {
        // 桌面平台特定的窗口初始化逻辑
        await windowManager.ensureInitialized();
        
        // 设置窗口选项
        WindowOptions windowOptions = WindowOptions(
          size: const Size(1200, 800),
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.normal,
        );
        
        // 等待窗口准备好显示
        await windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.show();
          await windowManager.focus();
        });
        
        _isInitialized = true;
        debugPrint('窗口管理器初始化完成');
      } catch (e) {
        // 忽略初始化错误
        debugPrint('窗口管理器初始化失败: $e');
      }
    } else {
      debugPrint('WindowManager: Not a desktop platform, skipping initialization');
    }
  }

  /// 检查是否为桌面平台
  static bool get _isDesktop {
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    debugPrint('WindowManager: _isDesktop result: $isDesktop (kIsWeb=$kIsWeb, Platform.isWindows=${Platform.isWindows}, Platform.isMacOS=${Platform.isMacOS}, Platform.isLinux=${Platform.isLinux})');
    return isDesktop;
  }

  /// 切换全屏状态
  static Future<void> toggleFullScreen() async {
    debugPrint('WindowManager: toggleFullScreen called, _isInitialized=$_isInitialized, _isDesktop=${_isDesktop}');
    if (!_isInitialized || !_isDesktop) {
      debugPrint('WindowManager: Not initialized or not desktop, returning early');
      return;
    }
    
    try {
      if (_isFullScreen) {
        // 如果已经全屏，则退出全屏
        debugPrint('窗口当前已全屏，准备退出全屏');
        await exitFullScreen();
      } else {
        // 如果未全屏，则进入全屏
        debugPrint('窗口当前未全屏，准备进入全屏');
        await enterFullScreen();
      }
    } catch (e) {
      debugPrint('切换全屏状态失败: $e');
    }
  }

  /// 设置窗口全屏
  static Future<void> setFullScreen(bool fullScreen) async {
    debugPrint('WindowManager: setFullScreen called with fullScreen=$fullScreen, _isInitialized=$_isInitialized, _isDesktop=${_isDesktop}');
    if (!_isInitialized || !_isDesktop) {
      debugPrint('WindowManager: Not initialized or not desktop, returning early');
      return;
    }
    
    try {
      if (fullScreen) {
        await enterFullScreen();
      } else {
        await exitFullScreen();
      }
    } catch (e) {
      debugPrint('设置全屏状态失败: $e');
    }
  }

  /// 进入全屏模式
  static Future<void> enterFullScreen() async {
    debugPrint('WindowManager: enterFullScreen called, _isInitialized=$_isInitialized, _isDesktop=${_isDesktop}');
    if (!_isInitialized || !_isDesktop) {
      debugPrint('WindowManager: Not initialized or not desktop, returning early');
      return;
    }
    
    try {
      await windowManager.setFullScreen(true);
      _isFullScreen = true;
      debugPrint('窗口已进入全屏模式');
    } catch (e) {
      debugPrint('进入全屏模式失败: $e');
    }
  }

  /// 退出全屏模式
  static Future<void> exitFullScreen() async {
    debugPrint('WindowManager: exitFullScreen called, _isInitialized=$_isInitialized, _isDesktop=${_isDesktop}');
    if (!_isInitialized || !_isDesktop) {
      debugPrint('WindowManager: Not initialized or not desktop, returning early');
      return;
    }
    
    try {
      await windowManager.setFullScreen(false);
      _isFullScreen = false;
      debugPrint('窗口已退出全屏模式');
    } catch (e) {
      debugPrint('退出全屏模式失败: $e');
    }
  }

  /// 检查窗口是否全屏
  static Future<bool> isFullScreen() async {
    if (!_isInitialized || !_isDesktop) return false;
    
    try {
      return await windowManager.isFullScreen();
    } catch (e) {
      debugPrint('检查全屏状态失败: $e');
      return false;
    }
  }

  /// 最大化窗口
  static Future<void> maximize() async {
    debugPrint('WindowManager: maximize called, _isInitialized=$_isInitialized, _isDesktop=${_isDesktop}');
    if (!_isInitialized || !_isDesktop) {
      debugPrint('WindowManager: Not initialized or not desktop, returning early');
      return;
    }
    
    try {
      await windowManager.maximize();
      debugPrint('窗口已最大化');
    } catch (e) {
      debugPrint('最大化窗口失败: $e');
    }
  }

  /// 恢复窗口（取消最大化）
  static Future<void> restore() async {
    debugPrint('WindowManager: restore called, _isInitialized=$_isInitialized, _isDesktop=${_isDesktop}');
    if (!_isInitialized || !_isDesktop) {
      debugPrint('WindowManager: Not initialized or not desktop, returning early');
      return;
    }
    
    try {
      await windowManager.unmaximize();
      debugPrint('窗口已恢复');
    } catch (e) {
      debugPrint('恢复窗口失败: $e');
    }
  }

  /// 设置窗口位置
  static Future<void> setPosition(Offset position) async {
    if (!_isInitialized || !_isDesktop) return;
    
    try {
      // 桌面平台设置窗口位置逻辑
      final currentSize = (await windowManager.getSize());
      final newBounds = Rect.fromLTWH(position.dx, position.dy, currentSize.width, currentSize.height);
      await windowManager.setBounds(newBounds);
      debugPrint('设置窗口位置: (${position.dx}, ${position.dy})');
    } catch (e) {
      debugPrint('设置窗口位置失败: $e');
    }
  }

  /// 将窗口居中
  static Future<void> center() async {
    if (!_isInitialized || !_isDesktop) return;
    
    try {
      // 桌面平台居中窗口逻辑
      final size = await windowManager.getSize();
      final screen = await ScreenRetriever.instance.getPrimaryDisplay();
      
      final screenWidth = screen.size.width;
      final screenHeight = screen.size.height;
      final windowWidth = size.width;
      final windowHeight = size.height;
      
      final x = (screenWidth - windowWidth) / 2 + screen.visiblePosition!.dx;
      final y = (screenHeight - windowHeight) / 2 + screen.visiblePosition!.dy;
      
      final newBounds = Rect.fromLTWH(x, y, windowWidth, windowHeight);
      await windowManager.setBounds(newBounds);
      debugPrint('居中窗口');
    } catch (e) {
      debugPrint('居中窗口失败: $e');
    }
  }
}