import 'package:flutter/material.dart';
import 'colors.dart';

class AppThemes {
  // Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryButtonLight,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCardBackground,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightPrimaryText),
      bodyMedium: TextStyle(color: AppColors.lightPrimaryText),
      bodySmall: TextStyle(color: AppColors.lightSecondaryText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryButtonLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryButtonLight,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryButtonLight,
        side: const BorderSide(color: AppColors.primaryButtonLight),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryButtonLight,
      brightness: Brightness.light,
    ).copyWith(
      secondary: AppColors.secondaryButtonLight,
      surface: AppColors.lightBackground,
    ),
  );

  // Dark Theme - 优化为更适合影视类应用的深色主题
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryButtonDark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A), // 更深的背景色
    cardColor: const Color(0xFF1E1E1E), // 卡片背景色
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkPrimaryText),
      bodyMedium: TextStyle(color: AppColors.darkPrimaryText),
      bodySmall: TextStyle(color: AppColors.darkSecondaryText),
      headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.white),
      headlineSmall: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white70),
      titleSmall: TextStyle(color: Colors.white60),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryButtonDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryButtonDark,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryButtonDark,
        side: const BorderSide(color: AppColors.primaryButtonDark),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryButtonDark,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: AppColors.secondaryButtonDark,
      surface: const Color(0xFF121212),
      onSurface: Colors.white70,
      outline: Colors.white24,
    ),
  );
}