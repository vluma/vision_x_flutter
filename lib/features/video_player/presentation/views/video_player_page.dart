import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/presentation/providers/video_player_provider.dart';
import 'package:vision_x_flutter/features/video_player/presentation/widgets/short_drama_player.dart' as short_drama;
import 'package:vision_x_flutter/features/video_player/presentation/widgets/traditional_player.dart' as traditional;

class VideoPlayerPage extends ConsumerWidget {
  final MediaDetail media;
  final Episode initialEpisode;
  final int startPosition;

  const VideoPlayerPage({
    super.key,
    required this.media,
    required this.initialEpisode,
    this.startPosition = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = VideoPlayerParams(
      media: media,
      initialEpisode: initialEpisode,
      startPosition: startPosition,
    );
    
    final state = ref.watch(videoPlayerProvider(params));
    
    return state.isShortDramaMode
        ? short_drama.ShortDramaPlayer(media: media)
        : traditional.TraditionalPlayer(media: media);
  }
}