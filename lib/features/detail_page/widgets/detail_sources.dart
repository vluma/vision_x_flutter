import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/shared/widgets/custom_card.dart';

/// 详情页面播放源组件
/// 显示所有播放源和剧集列表
class DetailSources extends StatelessWidget {
  final MediaDetail media;

  const DetailSources({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.surces.isEmpty) {
      return _buildNoSources();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '播放源',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // 显示所有播放源
          ..._buildSourceSections(context),
        ],
      ),
    );
  }

  Widget _buildNoSources() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        '暂无播放源',
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  List<Widget> _buildSourceSections(BuildContext context) {
    return media.surces.asMap().entries.map((entry) {
      final source = entry.value;
      final index = entry.key;

      return Padding(
        padding:
            EdgeInsets.only(bottom: index == media.surces.length - 1 ? 0 : 12),
        child: _buildSourceSection(context, source),
      );
    }).toList();
  }

  Widget _buildSourceSection(BuildContext context, Source source) {
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 源标题
          Text(
            '${source.name} (${source.episodes.length}个视频)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          // 剧集列表
          _buildEpisodesGrid(context, source.episodes),
        ],
      ),
    );
  }

  Widget _buildEpisodesGrid(BuildContext context, List<Episode> episodes) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: episodes.map((episode) {
        return _buildEpisodeButton(context, episode);
      }).toList(),
    );
  }

  Widget _buildEpisodeButton(BuildContext context, Episode episode) {
    return ElevatedButton(
      onPressed: () => _navigateToVideoPlayer(context, episode),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        episode.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _navigateToVideoPlayer(BuildContext context, Episode episode) {
    context.push(
      '/search/video',
      extra: {
        'media': media,
        'episode': episode,
      },
    );
  }
}
