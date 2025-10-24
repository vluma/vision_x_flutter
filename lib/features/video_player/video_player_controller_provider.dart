import 'package:flutter/material.dart';
import 'package:vision_x_flutter/features/video_player/viewmodels/video_player_viewmodel.dart';

// 这里是原有的provider代码内容，假设保持不变
class VideoPlayerControllerProvider extends InheritedWidget {
  final VideoPlayerViewModel viewModel;

  const VideoPlayerControllerProvider({
    Key? key,
    required this.viewModel,
    required Widget child,
  }) : super(key: key, child: child);

  static VideoPlayerViewModel of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<VideoPlayerControllerProvider>();
    assert(provider != null, 'No VideoPlayerControllerProvider found in context');
    return provider!.viewModel;
  }

  @override
  bool updateShouldNotify(VideoPlayerControllerProvider oldWidget) {
    return oldWidget.viewModel != viewModel;
  }
}