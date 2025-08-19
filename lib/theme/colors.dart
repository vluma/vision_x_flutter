import 'package:flutter/material.dart';

class AppColors {
  // 主要背景色
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF0A0A0A); // 更深的背景色，适合影视应用
  
  // 卡片背景色
  static const Color lightCardBackground = Colors.white;
  static const Color darkCardBackground = Color(0xFF1E1E1E); // 调整为更深的卡片背景色
  
  // 主要按钮颜色 - 使用更现代的蓝色
  static const Color primaryButtonLight = Color(0xFF2196F3); // 保持现有颜色
  static const Color primaryButtonDark = Color(0xFF1565C0); // 深色主题下使用更深的蓝色
  
  static const Color secondaryButtonLight = Color(0xFF757575);
  static const Color secondaryButtonDark = Color(0xFF9E9E9E);
  
  // 文字颜色
  static const Color lightPrimaryText = Colors.black87;
  static const Color darkPrimaryText = Colors.white;
  
  static const Color lightSecondaryText = Colors.black54;
  static const Color darkSecondaryText = Colors.white70;
  
  // 状态颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 底部导航栏颜色
  static const Color bottomNavBackground = Color(0xFF1E1E1E); // 使用与卡片相同的背景色
  static const Color bottomNavShadowInset1 = Color(0xFF121212);
  static const Color bottomNavShadowInset2 = Color(0xFF2E2E2E);
  static const Color bottomNavSelectedItem = Color(0xFF1565C0); // 与主按钮颜色一致
  static const Color bottomNavUnselectedItem = Colors.white60;
  static const Color bottomNavIndicator = Color(0xFF1E1E1E);
  
  // 影视应用专用颜色
  static const Color movieRed = Color(0xFFE50914); // 经典电影红
  static const Color movieGold = Color(0xFFFFD700); // 金色，用于高亮
  static const Color movieDarkBlue = Color(0xFF0F1B28); // 深蓝，适合背景
  static const Color moviePurple = Color(0xFF6200EA); // 紫色，用于特殊元素
}