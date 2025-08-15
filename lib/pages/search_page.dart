import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/models/douban_movie.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DoubanMovie> _searchResults = [];
  List<MediaDetail> _mediaResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _useMediaDetail = false; // 切换使用新模型

  // 执行搜索
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // 搜索电影和电视剧
      final movieResults = await ApiService.getMovies(
        type: 'movie',
        tag: query.trim(),
        pageLimit: 10,
      );
      
      final tvResults = await ApiService.getMovies(
        type: 'tv',
        tag: query.trim(),
        pageLimit: 10,
      );

      // 合并结果
      final allResults = [...movieResults, ...tvResults];
      
      setState(() {
        _searchResults = allResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('搜索失败，请稍后重试')),
        );
      }
    }
  }

  // 清空搜索
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _mediaResults = [];
      _hasSearched = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '搜索电影、电视剧...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // 添加切换按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_useMediaDetail ? '新模型' : '旧模型'),
              Switch(
                value: _useMediaDetail,
                onChanged: (value) {
                  setState(() {
                    _useMediaDetail = value;
                  });
                },
              ),
            ],
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else if (_hasSearched && _searchResults.isEmpty && _mediaResults.isEmpty)
            const Expanded(
              child: Center(
                child: Text('未找到相关结果'),
              ),
            )
          else if (_searchResults.isNotEmpty || _mediaResults.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _useMediaDetail ? _mediaResults.length : _searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  if (_useMediaDetail) {
                    // 使用新模型显示
                    final media = _mediaResults[index];
                    return _MediaResultItem(
                      media: media,
                      onTap: () {
                        // TODO: 导航到新模型的详情页
                      },
                    );
                  } else {
                    // 使用旧模型显示
                    final movie = _searchResults[index];
                    return _SearchResultItem(
                      movie: movie,
                      onTap: () {
                        context.go('/search/detail/${movie.id}');
                      },
                    );
                  }
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
}

// 搜索结果项组件 (旧模型)
class _SearchResultItem extends StatelessWidget {
  final DoubanMovie movie;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = ApiService.handleImageUrl(movie.cover);
    
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
                        movie.rate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
                movie.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 媒体结果项组件 (新模型)
class _MediaResultItem extends StatelessWidget {
  final MediaDetail media;
  final VoidCallback onTap;

  const _MediaResultItem({
    required this.media,
    required this.onTap,
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
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
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