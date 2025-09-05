/// 导航栏常量配置
/// 包含所有导航相关的尺寸、动画、颜色等常量

import 'package:flutter/material.dart';
import '../states/navigation_state.dart';

class NavBarConstants {
  // 尺寸常量
  static const double containerHeight = 64.0;
  static const double containerBorderRadius = containerHeight / 2;
  static const double selectedContainerHeight = containerHeight - 8.0;
  static const double selectedContainerBorderRadius = selectedContainerHeight / 2;
  static const double iconSize = 24.0;
  static const double paddingAll = 4.0;
  static const double borderWidth = 0.5;
  static const double horizontalPadding = 16.0;
  static const double bottomPaddingOffset = 20.0;
  static const double maxColumnWidthOffset = 100.0;
  static const double minColumnWidth = 100.0;

  // 动画配置
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Curve animationCurve = Curves.easeInOut;

  // 颜色透明度
  static const double commonAlpha = 0.1;
  static const double selectedItemAlphaDark = 0.2;

  // 路由路径
  static const List<String> navPaths = ['/', '/history', '/settings'];

  // 图标映射
  static const Map<NavBarTab, IconData> tabIcons = {
    NavBarTab.home: Icons.home,
    NavBarTab.history: Icons.history,
    NavBarTab.settings: Icons.settings,
  };

  // 标签名称映射
  static const Map<NavBarTab, String> tabLabels = {
    NavBarTab.home: '首页',
    NavBarTab.history: '历史',
    NavBarTab.settings: '设置',
  };
}