import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:vision_x_flutter/features/video_player/domain/models/video_player_models.dart';
import 'package:vision_x_flutter/features/video_player/presentation/providers/video_player_providers.dart';
import 'package:vision_x_flutter/features/video_player/presentation/widgets/video_player_view.dart';
import 'package:vision_x_flutter/features/video_player/presentation/widgets/video_controls/short_drama_controls_view.dart';
import 'package:vision_x_flutter/shared/widgets/loading_animation.dart';

/// 短剧播放器视图
/// 针对短视频和短剧场景优化的播放器界面
class ShortDramaPlayerView extends ConsumerWidget {
  final VideoPlayerParams params;

  const ShortDramaPlayerView({
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
    
    // 获取视频控制器
    final controller = playerNotifier.controller;
    
    if (controller == null || !controller.value.isInitialized) {
      return _buildLoadingView(context, params.media.poster);
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
            
            // 短剧控制界面
            if (uiState.controlsVisible || !playerState.isPlaying)
              ShortDramaControlsView(
                controller: controller,
                playerState: playerState,
                uiState: uiState,
                onPlayPause: () => playerNotifier.togglePlay(),
                onBack: () => Navigator.of(context).pop(),
                onSeek: (position) => playerNotifier.seekTo(
                  Duration(milliseconds: (position * playerState.totalDuration.inMilliseconds).round()),
                ),
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
  
  /// 构建加载视图
  Widget _buildLoadingView(BuildContext context, String? posterUrl) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 海报背景
          if (posterUrl != null && posterUrl.isNotEmpty)
            Image.network(
              posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          
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