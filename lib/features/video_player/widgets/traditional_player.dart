import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vision_x_flutter/features/video_player/widgets/video_player.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/viewmodels/video_player_viewmodel.dart';
import 'package:vision_x_flutter/features/video_player/video_player_controller_provider.dart';

/// 传统模式播放器
class TraditionalPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const TraditionalPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: null,
      body: Column(
        children: [
          _buildVideoPlayerSection(context),
          _buildTabSection(Theme.of(context)),
        ],
      ),
    );
  }

  Widget _buildVideoPlayerSection(BuildContext context) {
    return SafeArea(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              _buildCustomVideoPlayer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomVideoPlayer(BuildContext context) {
    return CustomVideoPlayer(
      key: ValueKey(controller.currentEpisode.value.url),
      media: controller.media,
      episode: controller.currentEpisode.value,
      onProgressUpdate: controller.updateProgress,
      onPlaybackCompleted: controller.playNextEpisode,
      onVideoDurationReceived: controller.setVideoDuration,
      startPosition: controller.currentProgress.value,
      isShortDramaMode: false,
      onShowEpisodeSelector: () => _showEpisodeSelector(context),
      onBackPressed: () => context.pop(),
      onNextEpisode: controller.playNextEpisode,
      onPrevEpisode: controller.playPrevEpisode,
      onEpisodeChanged: controller.changeEpisode,
      currentEpisodeIndex: controller.currentEpisodeIndex.value,
      totalEpisodes: controller.totalEpisodes,
      onPreloadNextEpisode: controller.preloadNextEpisode,
    );
  }

  void _showEpisodeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          '选集 (${controller.currentEpisodeIndex.value + 1}/${controller.totalEpisodes})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: controller.totalEpisodes,
            itemBuilder: (context, index) {
              final isSelected = index == controller.currentEpisodeIndex.value;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  controller.changeEpisode(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.red : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? Colors.red
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white,
                        fontSize: 14.0,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(ThemeData theme) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            _buildTabBar(theme),
            _buildTabBarView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TabBar(
        tabs: const [
          Tab(text: '简介'),
          Tab(text: '评论'),
        ],
        indicatorColor: theme.colorScheme.primary,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  Widget _buildTabBarView(ThemeData theme) {
    return Expanded(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: const TabBarView(
          children: [
            _DescriptionTab(),
            _CommentsTab(),
          ],
        ),
      ),
    );
  }
}

// 简介标签页
class _DescriptionTab extends StatelessWidget {
  const _DescriptionTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controllerProvider = VideoPlayerControllerProvider.of(context);

    if (controllerProvider == null) {
      return const Center(child: Text('加载中...'));
    }

    final controller = controllerProvider.controller;
    final media = controller.media;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 媒体标题
          Text(
            media.name ?? '未知影片',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 10),

          // 基本信息
          if (media.year != null || media.area != null)
            Text(
              '${media.year ?? ''} ${media.area ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),

          const SizedBox(height: 10),

          // 演职人员信息
          if (media.actors != null || media.director != null) ...[
            if (media.director != null)
              Text(
                '导演: ${media.director}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            if (media.actors != null)
              Text(
                '主演: ${media.actors}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            const SizedBox(height: 10),
          ],

          // 描述信息
          if (media.description != null)
            Text(
              media.description!,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),

          // 播放进度
          if (controller.currentProgress.value > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '当前播放位置: ${Duration(seconds: controller.currentProgress.value).toString().split('.').first}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 评论标签页
class _CommentsTab extends StatelessWidget {
  const _CommentsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        '评论功能正在开发中...',
        style: TextStyle(
          fontSize: 16,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}
