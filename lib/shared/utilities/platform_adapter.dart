import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 平台适配器，用于检测当前运行平台
class PlatformAdapter {
  /// 检查是否为桌面平台（Windows、macOS或Linux）
  static bool get isDesktop {
    // 修改为Web平台也视为桌面平台
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// 检查是否为移动平台（Android或iOS）
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// 检查是否为Web平台
  static bool get isWeb {
    return kIsWeb;
  }
}