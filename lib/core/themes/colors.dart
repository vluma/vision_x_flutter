import 'package:flutter/material.dart';

/// 应用颜色定义
class AppColors {
  // 亮色主题
  static const primaryButtonLight = Color(0xFF3370FF);
  static const secondaryButtonLight = Color(0xFF6C8EFF);
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightCardBackground = Colors.white;
  static const lightPrimaryText = Color(0xFF333333);
  static const lightSecondaryText = Color(0xFF666666);
  static const lightTertiaryText = Color(0xFF999999);
  static const lightBorder = Color(0xFFEEEEEE);
  static const lightShadow = Color(0x1A000000);

  // 深色主题
  static const primaryButtonDark = Color(0xFF4080FF);
  static const secondaryButtonDark = Color(0xFF6C8EFF);
  static const darkBackground = Color(0xFF121212);
  static const darkCardBackground = Color(0xFF1E1E1E);
  static const darkPrimaryText = Color(0xFFE0E0E0);
  static const darkSecondaryText = Color(0xFFAAAAAA);
  static const darkTertiaryText = Color(0xFF777777);
  static const darkBorder = Color(0xFF333333);
  static const darkShadow = Color(0x4D000000);
  
  // 底部导航栏颜色
  static const bottomNavBackground = Color(0xFFFFFFFF); // 纯白背景
  static const bottomNavShadowInset1 = Color(0xFFD5D5D5);
  static const bottomNavShadowInset2 = Color(0xFFCCCCCC);
  static const bottomNavSelectedItem = Color(0xFF1976D2); // 与主按钮颜色一致
  static const bottomNavUnselectedItem = Colors.black45;
  static const bottomNavIndicator = Color(0xFFE0E0E0);
  
  // 影视应用专用颜色
  static const movieRed = Color(0xFFE50914); // 经典电影红
  static const movieGold = Color(0xFFFFD700); // 金色，用于高亮
  static const movieDarkBlue = Color(0xFF0F1B28); // 深蓝，适合背景
  static const moviePurple = Color(0xFF6200EA); // 紫色，用于特殊元素
}