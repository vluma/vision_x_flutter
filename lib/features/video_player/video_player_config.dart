import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';

/// 视频播放页面配置常量
class VideoPlayerConfig {
  // 页面过渡动画
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration episodeChangeDelay = Duration(milliseconds: 500);
  static const Duration shortDramaEpisodeChangeDelay = Duration(milliseconds: 100);

  // 视频比例
  static const double videoAspectRatio = 16 / 9;

  // 短剧分类标识
  static const String shortDramaCategory = '短剧';

  // 消息文本
  static const String lastEpisodeMessage = '已经是最后一集了';
  static const String firstEpisodeMessage = '已经是第一集了';
  static const String playNextEpisodeError = '无法播放下一集';
  static const String playPrevEpisodeError = '无法播放上一集';
  static const String switchEpisodeError = '无法切换到该集数';

  // UI配置
  static const double cardHeight = 44.0;
  static const double expandedCardHeightRatio = 0.75;
  static const double cardMargin = 16.0;
  static const double cardPadding = 4.0;
  static const double borderRadius = 8.0;
  static const double expandedBorderRadius = 12.0;

  // 颜色配置
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color cardBackgroundColor = Color(0xFF1E1E1E);
  static const Color secondaryBackgroundColor = Color(0xFF2A2A2A);
  static const Color dividerColor = Color(0x40FFFFFF); // white with 25% opacity

  // 渐变颜色
  static const List<Color> primaryGradient = [Color(0xFFE53E3E), Color(0xFFC53030)];
  
  // 动画配置
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
}

/// 视频播放工具类
class VideoPlayerUtils {
  /// 检查是否为短剧模式
  static bool isShortDramaMode(String? category, String? type) {
    const shortDramaCategory = '短剧';
    return (category != null && 
            (category.contains(shortDramaCategory) || category == shortDramaCategory)) ||
           (type != null && 
            (type.contains(shortDramaCategory) || type == shortDramaCategory));
  }

  /// 格式化时间显示
  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    return duration.toString().split('.').first.padLeft(8, '0');
  }

  /// 安全执行操作，避免在disposed状态下调用setState
  static void safeSetState(VoidCallback callback, {bool mounted = true}) {
    if (mounted) {
      callback();
    }
  }

  /// 获取当前源
  static Source getCurrentSource(MediaDetail media) {
    return media.surces.firstWhere(
      (source) => source.name == media.sourceName,
      orElse: () => media.surces.first,
    );
  }

  /// 获取当前剧集索引
  static int getCurrentEpisodeIndex(Source source, Episode targetEpisode) {
    try {
      return source.episodes.indexWhere(
        (episode) => episode.url == targetEpisode.url,
      );
    } catch (e) {
      return 0;
    }
  }
}