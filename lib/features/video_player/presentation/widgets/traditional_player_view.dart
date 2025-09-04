import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:vision_x_flutter/features/video_player/domain/models/video_player_models.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/presentation/providers/video_player_providers.dart';
import 'package:vision_x_flutter/features/video_player/presentation/widgets/video_player_view.dart';
import 'package:vision_x_flutter/features/video_player/presentation/widgets/video_controls/normal_controls_view.dart';
import 'package:vision_x_flutter/shared/widgets/loading_animation.dart';

/// 传统播放器视图
/// 针对长视频和电视剧场景优化的播放器界面
class TraditionalPlayerView extends ConsumerWidget {
  final VideoPlayerParams params;

  const TraditionalPlayerView({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取播放器状态
    final playerState = ref.watch(videoPlayerStateProvider(params));
    final playerNotifier = ref.watch(videoPlayerStateProvider(params).notifier);
    final uiState = ref.watch(videoPlayerUIStateProvider);
    final uiNotifier = ref.watch(videoPlayerUIStateProvider.notifier);
    final config = ref.watch(videoPlayerConfigProvider(params.media));

    // 获取视频控制器
    final controller = playerNotifier.controller;

    if (controller == null || !controller.value.isInitialized) {
      return _buildLoadingView(context);
    }

    return GestureDetector(
      onTap: () => uiNotifier.toggleControls(),
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 视频播放器
            VideoPlayerView(controller: controller),

            // 传统控制界面
            if (uiState.controlsVisible || !playerState.isPlaying)
              NormalControlsView(
                controller: controller,
                playerState: playerState,
                uiState: uiState,
                config: config,
                onPlayPause: () => playerNotifier.togglePlay(),
                onBack: () => Navigator.of(context).pop(),
                onSeek: (position) => playerNotifier.seekTo(
                  Duration(
                      milliseconds:
                          (position * playerState.totalDuration.inMilliseconds)
                              .round()),
                ),
                onToggleFullScreen: () {
                  ref
                      .read(videoPlayerConfigProvider(params.media).notifier)
                      .toggleFullScreen();
                },
                onNextEpisode:
                    _canPlayNext(ref) ? () => _playNextEpisode(ref) : null,
                onPrevEpisode:
                    _canPlayPrev(ref) ? () => _playPrevEpisode(ref) : null,
                onSpeedChanged: (speed) =>
                    playerNotifier.setPlaybackSpeed(speed),
              ),

            // 大播放按钮
            if (uiState.showBigPlayButton && !playerState.isPlaying)
              Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                    size: 80,
                  ),
                  onPressed: () => playerNotifier.play(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 检查是否可以播放下一集
  bool _canPlayNext(WidgetRef ref) {
    final currentIndex = ref.read(currentEpisodeIndexProvider(params.media));
    final source = _getCurrentSource();
    return currentIndex < source.episodes.length - 1;
  }

  /// 检查是否可以播放上一集
  bool _canPlayPrev(WidgetRef ref) {
    final currentIndex = ref.read(currentEpisodeIndexProvider(params.media));
    return currentIndex > 0;
  }

  /// 播放下一集
  void _playNextEpisode(WidgetRef ref) {
    final currentIndex = ref.read(currentEpisodeIndexProvider(params.media));
    final source = _getCurrentSource();

    if (currentIndex < source.episodes.length - 1) {
      final nextIndex = currentIndex + 1;
      final nextEpisode = source.episodes[nextIndex];

      // 更新当前剧集
      ref.read(currentEpisodeProvider(params.media).notifier).state =
          nextEpisode;
      ref.read(currentEpisodeIndexProvider(params.media).notifier).state =
          nextIndex;

      // 更新配置
      ref.read(videoPlayerConfigProvider(params.media).notifier).setEpisodeInfo(
            nextEpisode.title,
            nextIndex,
            source.episodes.length,
          );

      // 创建新的参数并重新加载播放器
      final newParams = VideoPlayerParams(
        media: params.media,
        episode: nextEpisode,
        startPosition: 0,
      );

      // 这里需要通过路由导航或其他方式重新加载播放器
      // 在实际应用中，可能需要通过回调或事件通知父组件进行处理
    }
  }

  /// 播放上一集
  void _playPrevEpisode(WidgetRef ref) {
    final currentIndex = ref.read(currentEpisodeIndexProvider(params.media));
    final source = _getCurrentSource();

    if (currentIndex > 0) {
      final prevIndex = currentIndex - 1;
      final prevEpisode = source.episodes[prevIndex];

      // 更新当前剧集
      ref.read(currentEpisodeProvider(params.media).notifier).state =
          prevEpisode;
      ref.read(currentEpisodeIndexProvider(params.media).notifier).state =
          prevIndex;

      // 更新配置
      ref.read(videoPlayerConfigProvider(params.media).notifier).setEpisodeInfo(
            prevEpisode.title,
            prevIndex,
            source.episodes.length,
          );

      // 创建新的参数并重新加载播放器
      final newParams = VideoPlayerParams(
        media: params.media,
        episode: prevEpisode,
        startPosition: 0,
      );

      // 这里需要通过路由导航或其他方式重新加载播放器
      // 在实际应用中，可能需要通过回调或事件通知父组件进行处理
    }
  }

  /// 获取当前视频源
  Source _getCurrentSource() {
    return params.media.surces.firstWhere(
      (source) => source.name == params.media.sourceName,
      orElse: () => params.media.surces.first,
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 加载动画
          const Center(
            child: LoadingAnimation(
              showBackground: false,
              sizeRatio: 0.2,
            ),
          ),

          // 返回按钮
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
