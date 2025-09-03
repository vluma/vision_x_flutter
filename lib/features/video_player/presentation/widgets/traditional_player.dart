import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/presentation/providers/video_player_provider.dart';

class TraditionalPlayer extends ConsumerWidget {
  final MediaDetail media;

  const TraditionalPlayer({super.key, required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = VideoPlayerParams(
      media: media,
      initialEpisode: media.surces.first.episodes.first,
    );
    final notifier = ref.read(videoPlayerProvider(params).notifier);
    final state = ref.watch(videoPlayerProvider(params));

    return Scaffold(
      body: Column(
        children: [
          // 视频播放区域
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  '正在播放: ${state.currentEpisode.title}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          
          // 控制区域
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // 播放/暂停按钮
                IconButton(
                  icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: notifier.togglePlayPause,
                ),
                
                // 进度条
                Slider(
                  value: state.currentProgress.toDouble(),
                  min: 0,
                  max: state.duration?.toDouble() ?? 100,
                  onChanged: (value) => notifier.updateProgress(value.toInt()),
                ),
                
                // 音量控制
                Row(
                  children: [
                    const Icon(Icons.volume_up),
                    Expanded(
                      child: Slider(
                        value: state.volume,
                        min: 0,
                        max: 1,
                        onChanged: notifier.setVolume,
                      ),
                    ),
                  ],
                ),
                
                // 播放速度
                DropdownButton<double>(
                  value: state.playbackRate,
                  items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((rate) {
                    return DropdownMenuItem(
                      value: rate,
                      child: Text('${rate}x'),
                    );
                  }).toList(),
                  onChanged: (rate) {
                    if (rate != null) notifier.changePlaybackRate(rate);
                  },
                ),
                
                // 全屏按钮
                IconButton(
                  icon: Icon(state.isFullscreen 
                      ? Icons.fullscreen_exit 
                      : Icons.fullscreen),
                  onPressed: notifier.toggleFullscreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}