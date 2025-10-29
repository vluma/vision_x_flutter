import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 视频播放器控制器提供者
class VideoPlayerController extends ChangeNotifier {
  VideoPlayerController() {
    // 初始化默认速度为1.0
    _playbackSpeed = 1.0;
  }

  // 播放速度
  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;
  set playbackSpeed(double value) {
    if (_playbackSpeed != value) {
      _playbackSpeed = value;
      notifyListeners();
    }
  }
}

/// 视频播放器控制器提供者
class VideoPlayerControllerProvider extends InheritedNotifier<VideoPlayerController> {
  final VideoPlayerController controller;

  const VideoPlayerControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  }) : super(notifier: controller);

  // 静态方法获取提供者
  static VideoPlayerControllerProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VideoPlayerControllerProvider>();
  }
}