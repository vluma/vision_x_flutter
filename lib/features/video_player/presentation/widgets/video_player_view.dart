import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as vp;

/// 基础视频播放器视图
/// 封装了VideoPlayer组件，提供基本的视频播放功能
class VideoPlayerView extends StatelessWidget {
  final vp.VideoPlayerController controller;
  final BoxFit fit;

  const VideoPlayerView({
    super.key,
    required this.controller,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: vp.VideoPlayer(controller),
      ),
    );
  }
}