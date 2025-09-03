import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  VideoPlayerNotifier({
    required MediaDetail media,
    required Episode initialEpisode,
    int startPosition = 0,
  }) : super(VideoPlayerState(
          media: media,
          currentEpisode: initialEpisode,
          currentProgress: startPosition,
          isShortDramaMode: media.type == 'shortDrama',
        )) {
    // 初始化时设置短剧模式
    state = state.copyWith(isShortDramaMode: media.type == 'shortDrama');
  }

  // 获取下一集
  Episode? getNextEpisode() {
    final currentIndex = state.media.surces
        .expand((s) => s.episodes)
        .toList()
        .indexWhere((e) => e.url == state.currentEpisode.url);
    
    if (currentIndex == -1 || currentIndex + 1 >= state.media.surces.expand((s) => s.episodes).length) {
      return null;
    }
    return state.media.surces.expand((s) => s.episodes).toList()[currentIndex + 1];
  }

  // 播放完成处理
  void onPlaybackComplete() {
    if (state.isShortDramaMode) {
      final nextEpisode = getNextEpisode();
      if (nextEpisode != null) {
        changeEpisode(nextEpisode);
        state = state.copyWith(isPlaying: true); // 自动播放下一集
      }
    }
  }

  // 播放/暂停
  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  // 更新进度
  void updateProgress(int progress) {
    state = state.copyWith(currentProgress: progress);
  }

  // 设置视频时长
  void setDuration(int duration) {
    state = state.copyWith(duration: duration);
  }

  // 切换剧集
  void changeEpisode(Episode episode) {
    state = state.copyWith(
      currentEpisode: episode,
      currentProgress: 0,
      duration: null,
      isPlaying: false, // 重置播放状态
    );
  }

  // 切换播放速度
  void changePlaybackRate(double rate) {
    state = state.copyWith(playbackRate: rate);
  }

  // 切换全屏
  void toggleFullscreen() {
    state = state.copyWith(isFullscreen: !state.isFullscreen);
  }

  // 设置音量
  void setVolume(double volume) {
    state = state.copyWith(volume: volume);
  }
}

class VideoPlayerState {
  final MediaDetail media;
  final Episode currentEpisode;
  final int currentProgress;
  final int? duration;
  final bool isPlaying;
  final bool isFullscreen;
  final bool isShortDramaMode;
  final double playbackRate;
  final double volume;

  VideoPlayerState({
    required this.media,
    required this.currentEpisode,
    this.currentProgress = 0,
    this.duration,
    this.isPlaying = false,
    this.isFullscreen = false,
    this.isShortDramaMode = false,
    this.playbackRate = 1.0,
    this.volume = 1.0,
  });

  VideoPlayerState copyWith({
    MediaDetail? media,
    Episode? currentEpisode,
    int? currentProgress,
    int? duration,
    bool? isPlaying,
    bool? isFullscreen,
    bool? isShortDramaMode,
    double? playbackRate,
    double? volume,
  }) {
    return VideoPlayerState(
      media: media ?? this.media,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      currentProgress: currentProgress ?? this.currentProgress,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      playbackRate: playbackRate ?? this.playbackRate,
      volume: volume ?? this.volume,
    );
  }
}