import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/presentation/providers/video_player_provider.dart';

class ShortDramaPlayer extends ConsumerStatefulWidget {
  final MediaDetail media;

  const ShortDramaPlayer({super.key, required this.media});

  @override
  ConsumerState<ShortDramaPlayer> createState() => _ShortDramaPlayerState();
}

class _ShortDramaPlayerState extends ConsumerState<ShortDramaPlayer> {
  late VideoPlayerParams _params;

  @override
  void initState() {
    super.initState();
    _params = VideoPlayerParams(
      media: widget.media,
      initialEpisode: widget.media.surces.first.episodes.first,
    );
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    // _verticalDragStart 变量用于处理垂直拖动开始位置
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final endPosition = details.primaryVelocity ?? 0;
    
    // 向上滑动切换下一集
    if (endPosition < -1000) {
      // 通过ref.read获取notifier并调用方法
      final notifier = ref.read(videoPlayerProvider(_params).notifier);
      final nextEpisode = notifier.getNextEpisode();
      if (nextEpisode != null) {
        notifier.changeEpisode(nextEpisode);
        notifier.togglePlayPause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoPlayerProvider(_params));

    // 监听播放完成
    if (state.currentProgress >= (state.duration ?? 0) - 1000 && 
        state.duration != null && 
        state.duration! > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(videoPlayerProvider(_params).notifier);
        notifier.onPlaybackComplete();
      });
    }

    return GestureDetector(
      onVerticalDragStart: _handleVerticalDragStart,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: Scaffold(
        body: Stack(
          key: ValueKey(state.currentEpisode.url), // 强制重建以切换剧集
          children: [
            // 视频内容
            Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  '短剧模式: ${state.currentEpisode.title}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            
            // 控制按钮
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      final notifier = ref.read(videoPlayerProvider(_params).notifier);
                      notifier.togglePlayPause();
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: () {
                      final notifier = ref.read(videoPlayerProvider(_params).notifier);
                      notifier.toggleFullscreen();
                    },
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}