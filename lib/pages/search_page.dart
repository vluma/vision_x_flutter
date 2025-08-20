import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/components/loading_animation.dart';

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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String? imageUrl = media.poster;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 海报图片
            _buildImageContainer(imageUrl, isDarkMode),

            // 内容信息
            _buildContent(context, theme, isDarkMode),
          ],
        ),
      ),
    );
  }

  // 构建图片容器
  Widget _buildImageContainer(String? imageUrl, bool isDarkMode) {
    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingAnimation(),
                errorWidget: (context, url, error) => Container(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.movie,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : Container(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );
  }

  // 构建内容区域
  Widget _buildContent(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 标题和基本信息
            _buildTitleAndInfo(theme, isDarkMode),

            // 简介
            _buildDescription(isDarkMode),

            const SizedBox(height: 4),

            // 底部信息
            _buildBottomInfo(theme, isDarkMode),
          ],
        ),
      ),
    );
  }

  // 构建标题和基本信息
  Widget _buildTitleAndInfo(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          media.name ?? '未知片名',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // 年份、区域和类型信息
        _buildYearAreaType(theme, isDarkMode),

        const SizedBox(height: 4),

        // 评分和来源
        _buildRatingAndSource(theme, isDarkMode),
      ],
    );
  }

  // 构建年份、区域和类型信息
  Widget _buildYearAreaType(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        if (media.year != null && media.year!.isNotEmpty)
          Text(
            media.year!,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        if (media.year != null &&
            media.year!.isNotEmpty &&
            media.area != null &&
            media.area!.isNotEmpty)
          Text(
            ' · ',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        if (media.area != null && media.area!.isNotEmpty)
          Text(
            media.area!,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        if (media.type != null && media.type!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              media.type!,
              style: TextStyle(
                fontSize: 9,
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // 构建评分和来源信息
  Widget _buildRatingAndSource(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        // 评分
        if (media.score != null && media.score!.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 3),
              Text(
                media.score!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        // 来源信息
        if (media.sourceName.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              media.sourceName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
      ],
    );
  }

  // 构建简介
  Widget _buildDescription(bool isDarkMode) {
    if (media.description == null) {
      return const SizedBox.shrink();
    }

    return Text(
      media.description!,
      style: TextStyle(
        fontSize: 11,
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // 构建底部信息
  Widget _buildBottomInfo(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 演员信息
        if (media.actors != null && media.actors!.isNotEmpty)
          Expanded(
            child: Text(
              media.actors!,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // 详情按钮
        TextButton(
          onPressed: onDetailTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '详情',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
