import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/data/repositories/video_player_repository_impl.dart';
import 'package:vision_x_flutter/features/video_player/domain/models/video_player_models.dart';
import 'package:vision_x_flutter/features/video_player/domain/repositories/video_player_repository.dart';
import 'package:vision_x_flutter/features/video_player/presentation/notifiers/video_player_notifier.dart';
import 'package:vision_x_flutter/features/video_player/presentation/notifiers/video_player_ui_notifier.dart';

/// 视频播放器仓库提供者
final videoPlayerRepositoryProvider = Provider<VideoPlayerRepository>((ref) {
  return VideoPlayerRepositoryImpl();
});

/// 视频播放器配置提供者
final videoPlayerConfigProvider = StateNotifierProvider.family<VideoPlayerConfigNotifier, VideoPlayerConfig, MediaDetail>(
  (ref, media) => VideoPlayerConfigNotifier(
    VideoPlayerConfig(
      isShortDramaMode: _checkShortDramaMode(media.category, media.type),
      title: media.name,
    ),
  ),
);

/// 视频播放器状态提供者
final videoPlayerStateProvider = StateNotifierProvider.family<VideoPlayerNotifier, VideoPlayState, VideoPlayerParams>(
  (ref, params) => VideoPlayerNotifier(
    repository: ref.watch(videoPlayerRepositoryProvider),
    media: params.media,
    episode: params.episode,
    startPosition: params.startPosition,
  ),
);

/// 视频播放器UI状态提供者
final videoPlayerUIStateProvider = StateNotifierProvider<VideoPlayerUINotifier, VideoPlayerUIState>(
  (ref) => VideoPlayerUINotifier(),
);

/// 当前剧集提供者
final currentEpisodeProvider = StateProvider.family<Episode, MediaDetail>(
  (ref, media) => media.surces.first.episodes.first,
);

/// 当前剧集索引提供者
final currentEpisodeIndexProvider = StateProvider.family<int, MediaDetail>(
  (ref, media) => 0,
);

/// 视频时长提供者
final videoDurationProvider = StateProvider<int?>((ref) => null);

/// 视频播放器参数
class VideoPlayerParams {
  final MediaDetail media;
  final Episode episode;
  final int startPosition;

  VideoPlayerParams({
    required this.media,
    required this.episode,
    this.startPosition = 0,
  });
}

/// 检查是否为短剧模式
bool _checkShortDramaMode(String? category, String? type) {
  if (category == null || type == null) return false;
  
  // 根据分类和类型判断是否为短剧模式
  final isShortVideo = category.contains('短视频') || type.contains('短视频');
  final isShortDrama = category.contains('短剧') || type.contains('短剧');
  
  return isShortVideo || isShortDrama;
}

/// 视频播放器配置Notifier
class VideoPlayerConfigNotifier extends StateNotifier<VideoPlayerConfig> {
  VideoPlayerConfigNotifier(VideoPlayerConfig state) : super(state);

  void updateConfig(VideoPlayerConfig config) {
    state = config;
  }

  void toggleFullScreen() {
    state = state.copyWith(isFullScreen: !state.isFullScreen);
  }

  void setEpisodeInfo(String? episodeTitle, int currentIndex, int total) {
    state = state.copyWith(
      episodeTitle: episodeTitle,
      currentEpisodeIndex: currentIndex,
      totalEpisodes: total,
    );
  }
}