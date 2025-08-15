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
    textTheme: TextTheme(
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
        side: BorderSide(color: AppColors.primaryButtonLight),
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

  // Dark Theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryButtonDark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCardBackground,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkPrimaryText),
      bodyMedium: TextStyle(color: AppColors.darkPrimaryText),
      bodySmall: TextStyle(color: AppColors.darkSecondaryText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryButtonDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
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
        side: BorderSide(color: AppColors.primaryButtonDark),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryButtonDark,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: AppColors.secondaryButtonDark,
      surface: AppColors.darkBackground,
    ),
  );
}