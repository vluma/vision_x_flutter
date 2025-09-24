import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/video_player/domain/models/video_player_models.dart';
import 'package:vision_x_flutter/features/video_player/domain/repositories/video_player_repository.dart';

/// 视频播放器状态管理器
class VideoPlayerNotifier extends StateNotifier<VideoPlayState> {
  final VideoPlayerRepository _repository;
  final VideoPlayerParams _params;
  
  // 添加controller属性，这里只是示例，实际应该根据需要实现
  dynamic get controller => null;

  VideoPlayerNotifier({
    required VideoPlayerRepository repository,
    required VideoPlayerParams params,
  })  : _repository = repository,
        _params = params,
        super(const VideoPlayState());

  /// 播放视频
  Future<void> play() async {
    state = state.copyWith(isPlaying: true);
  }

  /// 暂停视频
  void pause() {
    state = state.copyWith(isPlaying: false);
  }
  
  /// 切换播放/暂停状态
  void togglePlay() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// 跳转到指定位置
  void seekTo(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  /// 设置总时长
  void setDuration(Duration duration) {
    state = state.copyWith(totalDuration: duration);
  }

  /// 更新播放进度
  void updatePosition(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  /// 设置缓冲状态
  void setBuffering(bool buffering) {
    state = state.copyWith(isBuffering: buffering);
  }

  /// 设置播放速度
  void setPlaybackSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
  }

  /// 重置播放器状态
  void reset() {
    state = const VideoPlayState();
  }
}