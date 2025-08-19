import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<MediaDetail> _mediaResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _lastSearchQuery = ''; // 添加这个变量来跟踪上次搜索的内容
  int _searchId = 0; // 添加搜索ID以跟踪当前搜索

  @override
  void initState() {
    super.initState();
    // 监听搜索数据源的变化
    searchDataSource.addListener(_handleSearchDataChange);

    // 只有当页面没有搜索过且有搜索查询时才执行搜索
    if (searchDataSource.searchQuery.isNotEmpty && !_hasSearched) {
      _performSearch(searchDataSource.searchQuery);
      _lastSearchQuery = searchDataSource.searchQuery;
    }
  }

  @override
  void dispose() {
    searchDataSource.removeListener(_handleSearchDataChange);
    super.dispose();
  }

  void _handleSearchDataChange() {
    // 当搜索数据源发生变化时更新搜索控制器
    // 只有当搜索查询发生变化时才执行新搜索
    if (searchDataSource.searchQuery.isNotEmpty &&
        searchDataSource.searchQuery != _lastSearchQuery) {
      _performSearch(searchDataSource.searchQuery);
      _lastSearchQuery = searchDataSource.searchQuery;
    }
  }

  // 执行聚合搜索
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      return;
    }

    // 增加搜索ID，取消之前的搜索
    final int currentSearchId = ++_searchId;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await ApiService.aggregatedSearch(query.trim());

      // 只有当这是最新的搜索时才更新UI
      if (mounted && currentSearchId == _searchId) {
        setState(() {
          _mediaResults = results;
          _isLoading = false;
          _lastSearchQuery = query.trim(); // 更新最后搜索的查询
        });
      }
    } catch (e) {
      // 只有当这是最新的搜索时才显示错误
      if (mounted && currentSearchId == _searchId) {
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
          // 搜索结果
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
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: _mediaResults.length,
                itemBuilder: (BuildContext context, int index) {
                  final media = _mediaResults[index];
                  return _MediaResultItem(
                    media: media,
                    onTap: () {
                      // 默认点击跳转到播放页面
                      _navigateToPlayer(context, media);
                    },
                    onDetailTap: () {
                      // 导航到详情页（模态方式）
                      _showDetailPage(context, media);
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

  // 显示详情页面（模态方式）
  void _showDetailPage(BuildContext context, MediaDetail media) {
    context.push(
      '/search/detail/${media.id}',
      extra: media,
    );
  }
}

// 媒体结果项组件
class _MediaResultItem extends StatelessWidget {
  final MediaDetail media;
  final VoidCallback onTap;
  final VoidCallback onDetailTap;

  const _MediaResultItem({
    required this.media,
    required this.onTap,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    // 使用海报图片，如果没有则使用占位图
    final String? imageUrl = media.poster;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧海报图
            Container(
              width: 120,
              height: 180,
              margin: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
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
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),

            // 右侧信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题和年份
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            media.name ?? '未知片名',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 评分
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                media.score ?? '暂无',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // 年份和区域
                    Text(
                      '${media.year ?? ''} ${media.area ?? ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // 类型
                    if (media.type != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          media.type!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // 简介
                    if (media.description != null)
                      Text(
                        media.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 12),

                    // 底部信息和按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 来源标签
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            media.sourceName,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // 详情按钮
                        OutlinedButton(
                          onPressed: onDetailTap,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            '查看详情',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}