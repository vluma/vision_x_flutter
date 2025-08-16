import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/components/bottom_navigation_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<MediaDetail> _mediaResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // 监听搜索数据源的变化
    searchDataSource.addListener(_handleSearchDataChange);

    // 如果已经有搜索查询，执行搜索
    if (searchDataSource.searchQuery.isNotEmpty) {
      _performSearch(searchDataSource.searchQuery);
    }
  }

  @override
  void dispose() {
    searchDataSource.removeListener(_handleSearchDataChange);
    super.dispose();
  }

  void _handleSearchDataChange() {
    // 当搜索数据源发生变化时执行搜索
    if (searchDataSource.searchQuery.isNotEmpty) {
      _performSearch(searchDataSource.searchQuery);
    } else {
      // 清空搜索结果
      setState(() {
        _mediaResults = [];
        _hasSearched = false;
      });
    }
  }

  // 执行聚合搜索
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _mediaResults = [];
    });

    try {
      final results = await ApiService.aggregatedSearch(query.trim());

      if (mounted) {
        setState(() {
          _mediaResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('搜索结果'),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else if (_hasSearched && _mediaResults.isEmpty)
            const Expanded(
              child: Center(
                child: Text('未找到相关结果'),
              ),
            )
          else if (_mediaResults.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _mediaResults.length,
                itemBuilder: (BuildContext context, int index) {
                  final media = _mediaResults[index];
                  return _MediaResultItem(
                    media: media,
                    onTap: () {
                      // 导航到详情页
                      context.go('/search/detail/${media.id}', extra: media);
                    },
                    onPlayTap: () {
                      // 直接导航到播放页面
                      _navigateToPlayer(context, media);
                    },
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text('请输入关键词搜索'),
              ),
            ),
        ],
      ),
    );
  }

  // 导航到播放器页面
  void _navigateToPlayer(BuildContext context, MediaDetail media) {
    // 检查是否有可用的剧集
    if (media.surces.isNotEmpty && media.surces.first.episodes.isNotEmpty) {
      final firstEpisode = media.surces.first.episodes.first;
      
      context.go('/search/video', extra: {
        'media': media,
        'episode': firstEpisode,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该媒体没有可播放的剧集')),
      );
    }
  }
}

// 媒体结果项组件
class _MediaResultItem extends StatelessWidget {
  final MediaDetail media;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;

  const _MediaResultItem({
    required this.media,
    required this.onTap,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    // 使用海报图片，如果没有则使用占位图
    final String? imageUrl = media.poster;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // 使用 CachedNetworkImage 加载图片
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.movie,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  // 评分
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        media.score ?? '暂无评分',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // 来源标签
                  Positioned(
                    left: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        media.sourceName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  // 播放按钮
                  Positioned(
                    right: 5,
                    top: 5,
                    child: GestureDetector(
                      onTap: onPlayTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                media.name ?? '未知片名',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Text(
                '${media.year ?? ''} ${media.area ?? ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}