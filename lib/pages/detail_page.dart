import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:vision_x_flutter/components/loading_animation.dart';
import 'package:vision_x_flutter/components/custom_card.dart';
import 'package:vision_x_flutter/components/swipe_back_gesture.dart';

class DetailPage extends StatelessWidget {
  final String? id;
  final MediaDetail? media;

  const DetailPage({super.key, this.id, this.media});

  @override
  Widget build(BuildContext context) {
    return SwipeBackGesture(
      onBackPressed: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(media?.name ?? '详情页面'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: media == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _buildDetailContent(context),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 海报和基本信息
          _buildHeaderSection(context),
          
          // 简介
          _buildDescriptionSection(context),
          
          // 演职人员
          _buildCastSection(context),
          
          // 播放源
          _buildSourcesSection(context),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 海报
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: CachedNetworkImage(
              imageUrl: ApiService.handleImageUrl(media!.poster ?? ''),
              width: 120,
              height: 160,
              fit: BoxFit.cover,
              placeholder: (context, url) => const LoadingAnimation(),
              errorWidget: (context, url, error) => Container(
                width: 120,
                height: 160,
                color: Theme.of(context).cardColor,
                child: const Icon(
                  Icons.movie,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 基本信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media!.name ?? '',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                
                if (media!.year != null && media!.year!.isNotEmpty)
                  Text('年份: ${media!.year}'),
                
                if (media!.type != null && media!.type!.isNotEmpty)
                  Text('类型: ${media!.type}'),
                
                if (media!.area != null && media!.area!.isNotEmpty)
                  Text('地区: ${media!.area}'),
                
                if (media!.language != null && media!.language!.isNotEmpty)
                  Text('语言: ${media!.language}'),
                
                if (media!.duration != null && media!.duration!.isNotEmpty)
                  Text('时长: ${media!.duration}'),
                
                if (media!.score != null && media!.score!.isNotEmpty)
                  Text('评分: ${media!.score}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '简介',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            media!.description ?? media!.content ?? '暂无简介',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection(BuildContext context) {
    List<Widget> castWidgets = [];
    
    if (media!.director != null && media!.director!.isNotEmpty) {
      castWidgets.add(
        Text('导演: ${media!.director}'),
      );
    }
    
    if (media!.actors != null && media!.actors!.isNotEmpty) {
      castWidgets.add(
        Text('主演: ${media!.actors}'),
      );
    }
    
    if (castWidgets.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '演职人员',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...castWidgets,
        ],
      ),
    );
  }

  Widget _buildSourcesSection(BuildContext context) {
    if (media!.surces.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('暂无播放源'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '播放源',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          // 显示所有播放源
          for (int i = 0; i < media!.surces.length; i++)
            _buildSourceSection(context, media!.surces[i], i),
        ],
      ),
    );
  }

  Widget _buildSourceSection(BuildContext context, Source source, int sourceIndex) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${source.name} (${source.episodes.length}个视频)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          
          // 显示剧集列表
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: source.episodes.map((episode) {
              return ElevatedButton(
                onPressed: () {
                  // 跳转到视频播放页面
                  context.push(
                    '/search/video',
                    extra: {
                      'media': media,
                      'episode': episode,
                    },
                  );
                },
                child: Text(episode.title, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}