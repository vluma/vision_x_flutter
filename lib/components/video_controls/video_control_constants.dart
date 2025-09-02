import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 视频控制器常量配置类
class VideoControlConstants {
  // 计时器配置
  static const int hideDelayMs = 3000;
  static const int seekIntervalMs = 100;
  
  // 快进快退配置
  static const int seekStepMs = 500;
  static const double maxSeekSpeedMultiplier = 10.0;
  static const double seekSpeedIncrement = 1.05;
  
  // UI尺寸配置
  static const double backButtonSize = 30.0;
  static const double playButtonSize = 40.0;
  static const double controlButtonSize = 24.0;
  static const double pauseIconSize = 80.0;
  static const double lockButtonSize = 30.0;
  
  // 间距配置
  static const double topPadding = 8.0;
  static const double sidePadding = 8.0;
  static const double bottomPadding = 52.0;
  static const double gestureExcludeTop = 50.0;
  static const double gestureExcludeSide = 50.0;
  static const double gestureExcludeBottom = 100.0;
  
  // 颜色配置
  static const Color primaryColor = Color(0xFF00D4FF);
  static const Color backgroundColor = Color(0xFF1E1E1E);
  static const Color cardBackgroundColor = Color(0xFF2A2A2A);
  static const Color textColor = Colors.white;
  static const Color iconColor = Colors.white;
  
  // 进度条颜色
  static const VideoProgressColors progressColors = VideoProgressColors(
    playedColor: primaryColor,
    bufferedColor: Color(0x88FFFFFF),
    backgroundColor: Color(0x44FFFFFF),
  );
  
  // 渐变背景
  static const BoxDecoration gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromRGBO(0, 0, 0, 0.7),
        Color.fromRGBO(0, 0, 0, 0.0),
        Color.fromRGBO(0, 0, 0, 0.0),
        Color.fromRGBO(0, 0, 0, 0.7),
      ],
    ),
  );
  
  // 动画配置
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
  
  // 字体样式
  static const TextStyle titleStyle = TextStyle(
    color: textColor,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle timeStyle = TextStyle(
    color: textColor,
    fontSize: 14.0,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    color: textColor,
    fontSize: 14.0,
  );
}