import 'package:flutter/material.dart';

/// 应用间距定义
class AppSpacing {
  // 基础间距单位
  static const double baseUnit = 8.0;

  // 标准间距
  static const double xs = baseUnit * 0.5; // 4.0
  static const double sm = baseUnit; // 8.0
  static const double md = baseUnit * 2; // 16.0
  static const double lg = baseUnit * 3; // 24.0
  static const double xl = baseUnit * 4; // 32.0
  static const double xxl = baseUnit * 6; // 48.0

  // 特殊间距
  static const double screenPadding = md;
  static const double cardPadding = md;
  static const double buttonPadding = sm;
  static const double iconPadding = xs;
  static const double bottomNavigationBarMargin = 90; // 添加底部导航栏边距

  // 边距快捷方式
  static EdgeInsets get screenEdgeInsets => const EdgeInsets.all(screenPadding);
  static EdgeInsets get cardEdgeInsets => const EdgeInsets.all(cardPadding);
  static EdgeInsets get buttonEdgeInsets => const EdgeInsets.all(buttonPadding);
  static EdgeInsets get pageMargin => const EdgeInsets.all(md);
  static EdgeInsets get symmetricHorizontalMd =>
      const EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get symmetricVerticalMd =>
      const EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get symmetricHorizontalLg =>
      const EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get symmetricVerticalLg =>
      const EdgeInsets.symmetric(vertical: lg);

  // 圆角半径
  static const double borderRadiusSm = 4.0;
  static const double borderRadiusMd = 8.0;
  static const double borderRadiusLg = 12.0;
  static const double borderRadiusXl = 16.0;

  // 图标大小
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;

  // 按钮尺寸
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // 输入框高度
  static const double inputFieldHeight = 48.0;

  // 分隔线高度
  static const double dividerHeight = 1.0;
}
