import 'package:flutter/material.dart';

class AppColors {
  // 主要背景色 - 浅色主题
  static const Color lightBackground = Color(0xFFF5F5F5); // 更柔和的浅灰背景
  static const Color darkBackground = Color(0xFF0A0A0A); // 深色背景保持不变
  
  // 卡片背景色
  static const Color lightCardBackground = Colors.white; // 浅色卡片保持纯白
  static const Color darkCardBackground = Color(0xFF1E1E1E); // 调整为更深的卡片背景色
  
  // 图片背景色
  static const Color lightImageBackground = Color(0xFFEEEEEE); // 浅色图片背景
  static const Color darkImageBackground = Color(0xFF252525); // 深色图片背景
  
  // 卡片内置块颜色
  static const Color lightCardBlock = Color(0xFFFAFAFA); // 浅色卡片内区块
  static const Color darkCardBlock = Color(0xFF2D2D2D); // 深色卡片内区块
  
  // 阴影颜色
  static const Color lightShadow = Color(0x33000000); // 浅色阴影 (20% 不透明度)
  static const Color darkShadow = Color(0x4D000000); // 深色阴影 (30% 不透明度)
  
  // 边框颜色
  static const Color lightBorder = Color(0xFFE0E0E0); // 浅色边框
  static const Color darkBorder = Color(0xFF333333); // 深色边框
  
  // 主要按钮颜色 - 使用更现代的蓝色
  static const Color primaryButtonLight = Color(0xFF1976D2); // 稍微加深以在新背景上提供更好的对比度
  static const Color primaryButtonDark = Color(0xFF1565C0); // 深色主题下使用更深的蓝色
  
  static const Color secondaryButtonLight = Color(0xFF757575);
  static const Color secondaryButtonDark = Color(0xFF9E9E9E);
  
  // 文字颜色
  static const Color lightPrimaryText = Colors.black87;
  static const Color darkPrimaryText = Colors.white;
  
  static const Color lightSecondaryText = Colors.black54;
  static const Color darkSecondaryText = Colors.white70;
  
  // 三级文字颜色
  static const Color lightTertiaryText = Colors.black38; // 新增三级文字颜色
  static const Color darkTertiaryText = Colors.white54; // 新增三级文字颜色
  
  // 状态颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // 底部导航栏颜色
  static const Color bottomNavBackground = Color(0xFFFFFFFF); // 纯白背景
  static const Color bottomNavShadowInset1 = Color(0xFFD5D5D5);
  static const Color bottomNavShadowInset2 = Color(0xFFCCCCCC);
  static const Color bottomNavSelectedItem = Color(0xFF1976D2); // 与主按钮颜色一致
  static const Color bottomNavUnselectedItem = Colors.black45;
  static const Color bottomNavIndicator = Color(0xFFE0E0E0);
  
  // 影视应用专用颜色
  static const Color movieRed = Color(0xFFE50914); // 经典电影红
  static const Color movieGold = Color(0xFFFFD700); // 金色，用于高亮
  static const Color movieDarkBlue = Color(0xFF0F1B28); // 深蓝，适合背景
  static const Color moviePurple = Color(0xFF6200EA); // 紫色，用于特殊元素
}