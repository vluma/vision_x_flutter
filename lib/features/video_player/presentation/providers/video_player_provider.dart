import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/presentation/providers/video_player_notifier.dart';

final videoPlayerProvider = StateNotifierProvider.family<VideoPlayerNotifier, VideoPlayerState, VideoPlayerParams>(
  (ref, params) => VideoPlayerNotifier(
    media: params.media,
    initialEpisode: params.initialEpisode,
    startPosition: params.startPosition,
  ),
);

class VideoPlayerParams {
  final MediaDetail media;
  final Episode initialEpisode;
  final int startPosition;

  VideoPlayerParams({
    required this.media,
    required this.initialEpisode,
    this.startPosition = 0,
  });
}