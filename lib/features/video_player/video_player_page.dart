import 'package:flutter/material.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/viewmodels/video_player_viewmodel.dart';
import 'package:vision_x_flutter/features/video_player/video_player_controller_provider.dart';
import 'package:vision_x_flutter/features/video_player/widgets/short_drama_player.dart';
import 'package:vision_x_flutter/features/video_player/widgets/traditional_player.dart';
import 'package:vision_x_flutter/features/video_player/video_player_performance.dart';

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
    debugPrint('VideoPlayerPage dispose() 开始');
    
    try {
      // 清理预加载缓存，防止内存泄漏
      VideoPlayerPerformance.clearPreloadCache();
      debugPrint('预加载缓存已清理');
    } catch (e) {
      debugPrint('清理预加载缓存时出错: $e');
    }
    
    try {
      _controller.dispose();
      debugPrint('VideoPlayerController 已释放');
    } catch (e) {
      debugPrint('释放 VideoPlayerController 时出错: $e');
    }
    
    debugPrint('VideoPlayerPage dispose() 完成');
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
