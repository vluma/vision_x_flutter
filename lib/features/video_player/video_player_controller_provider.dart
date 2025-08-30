import 'package:flutter/material.dart';
import 'package:vision_x_flutter/features/video_player/video_player_controller.dart';

/// 视频播放控制器提供者
/// 用于在widget树中传递控制器
class VideoPlayerControllerProvider extends InheritedWidget {
  final VideoPlayerController controller;

  const VideoPlayerControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static VideoPlayerControllerProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VideoPlayerControllerProvider>();
  }

  @override
  bool updateShouldNotify(VideoPlayerControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}