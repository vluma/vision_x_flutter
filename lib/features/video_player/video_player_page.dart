import 'package:flutter/material.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/video_player_controller.dart';
import 'package:vision_x_flutter/features/video_player/video_player_controller_provider.dart';
import 'package:vision_x_flutter/features/video_player/widgets/short_drama_player.dart';
import 'package:vision_x_flutter/features/video_player/widgets/traditional_player.dart';

/// 视频播放页面 - 主入口
class VideoPlayerPage extends StatefulWidget {
  final MediaDetail media;
  final Episode episode;
  final int startPosition;

  const VideoPlayerPage({
    super.key,
    required this.media,
    required this.episode,
    this.startPosition = 0,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController(
      media: widget.media,
      initialEpisode: widget.episode,
      startPosition: widget.startPosition,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayerControllerProvider(
      controller: _controller,
      child: ValueListenableBuilder<bool>(
        valueListenable: _controller.isShortDramaMode,
        builder: (context, isShortDramaMode, _) {
          return isShortDramaMode
              ? ShortDramaPlayer(controller: _controller)
              : TraditionalPlayer(controller: _controller);
        },
      ),
    );
  }
}
