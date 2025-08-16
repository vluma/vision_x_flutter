import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/models/douban_movie.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io' show HttpClient, HttpClientRequest, HttpClientResponse;
import 'dart:typed_data' show Uint8List;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 当前选中的视频分类
  String _selectedCategory = '电影';
  // 当前选中的视频源
  String _selectedSource = '热门';
  // 当前选中的排序方式
  String _selectedSort = 'recommend';
  
  // 视频数据列表
  List<DoubanMovie> _movies = [];
  List<DoubanMovie> _searchResults = []; // 添加搜索结果列表
  bool _isLoading = false;
  bool _tagsLoading = false;
  bool _hasMoreData = true; // 是否还有更多数据
  int _currentPageStart = 0; // 当前页起始位置
  final int _pageLimit = 20; // 每页数据量
  bool _isSearching = false; // 是否正在显示搜索结果
  String _searchQuery = ''; // 当前搜索关键词

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // 视频分类列表
  final List<String> _categories = [
    '电影',
    '电视剧',
  ];

  // 排序选项
  final List<Map<String, String>> _sortOptions = [
    {'value': 'recommend', 'label': '推荐排序'},
    {'value': 'time', 'label': '时间排序'},
    {'value': 'rank', 'label': '评分排序'},
  ];

  // 视频源列表 (将根据选中的分类动态变化)
  List<String> _sources = [
    "热门",
    "最新",
    "经典",
    "豆瓣高分",
    "冷门佳片",
    "华语",
    "欧美",
    "韩国",
    "日本",
  ];

  @override
  void initState() {
    super.initState();
    _loadTags();
    _loadMovies();
  }

  // 加载标签数据
  Future<void> _loadTags() async {
    setState(() {
      _tagsLoading = true;
    });
    
    try {
      List<String> tags;
      if (_selectedCategory == '电影') {
        tags = await ApiService.getMovieTags();
      } else {
        tags = await ApiService.getTvTags();
      }
      
      setState(() {
        _sources = tags;
        if (!_sources.contains(_selectedSource)) {
          _selectedSource = _sources.first;
        }
        _tagsLoading = false;
      });
      
      // 重新加载电影数据
      _loadMovies();
    } catch (e) {
      // 使用默认标签
      setState(() {
        _sources = _selectedCategory == '电影'
            ? [
                "热门",
                "最新",
                "经典",
                "豆瓣高分",
                "冷门佳片",
                "华语",
                "欧美",
                "韩国",
                "日本",
              ]
            : [
                "热门",
                "美剧",
                "英剧",
                "韩剧",
                "日剧",
                "国产剧",
                "港剧",
                "日本动画",
                "综艺",
                "纪录片",
              ];
        _tagsLoading = false;
      });
      
      // 重新加载电影数据
      _loadMovies();
    }
  }

  // 加载电影数据（默认从第一页开始）
  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movies = await ApiService.getMovies(
        type: _selectedCategory == '电影' ? 'movie' : 'tv',
        tag: _selectedSource,
        sort: _selectedSort,
        pageStart: 0,
        pageLimit: _pageLimit,
      );
      
      setState(() {
        _movies = movies;
        _currentPageStart = 0;
        _hasMoreData = movies.length == _pageLimit; // 如果返回数据少于限制数量，说明没有更多数据
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 加载更多电影数据
  Future<void> _loadMoreMovies() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPageStart = _currentPageStart + _pageLimit;
      final movies = await ApiService.getMovies(
        type: _selectedCategory == '电影' ? 'movie' : 'tv',
        tag: _selectedSource,
        sort: _selectedSort,
        pageStart: nextPageStart,
        pageLimit: _pageLimit,
      );
      
      setState(() {
        _movies.addAll(movies);
        _currentPageStart = nextPageStart;
        _hasMoreData = movies.length == _pageLimit; // 如果返回数据少于限制数量，说明没有更多数据
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 下拉刷新
  Future<void> _refresh() async {
    _loadTags(); // 重新加载标签
    await _loadMovies(); // 重新加载第一页数据
  }

  // 切换分类
  void _switchCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedSource = '热门'; // 重置为默认源
    });
    _loadTags();
    // _loadMovies将在_loadTags中调用
  }

  // 切换排序方式
  void _switchSort(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    _loadMovies();
  }

  // 切换视频源
  void _switchSource(String source) {
    setState(() {
      _selectedSource = source;
    });
    _loadMovies();
  }

  // 执行搜索
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchQuery = '';
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
      _searchQuery = query;
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
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSearching ? '搜索结果: $_searchQuery' : '豆瓣热门'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
          // 排序控制按钮
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _switchSort,
            itemBuilder: (BuildContext context) {
              return _sortOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option['value']!,
                  child: Text(option['label']!),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isSearching) ...[
            // 顶部一级分类
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _categories.map((String category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (bool selected) {
                        if (selected) {
                          _switchCategory(category);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            // 二级分类（视频源）
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _sources.map((String source) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(source, style: const TextStyle(fontSize: 12)),
                      selected: _selectedSource == source,
                      onSelected: (bool selected) {
                        if (selected) {
                          _switchSource(source);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
          ],
          // 视频列表
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!_isSearching && 
                      scrollInfo.metrics.pixels >= 
                      scrollInfo.metrics.maxScrollExtent - 500) {
                    _loadMoreMovies();
                    return true;
                  }
                  return false;
                },
                child: _isLoading && (_movies.isEmpty && _searchResults.isEmpty)
                    ? const Center(child: CircularProgressIndicator())
                    : (_isSearching ? _searchResults : _movies).isEmpty
                        ? const Center(
                            child: Text('暂无数据'),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: _isSearching 
                                ? _searchResults.length 
                                : _movies.length + (_hasMoreData && !_isSearching ? 1 : 0), // 添加一个加载指示器的item
                            itemBuilder: (BuildContext context, int index) {
                              // 如果是最后一个item且还有更多数据，显示加载指示器
                              if (!_isSearching && 
                                  index == _movies.length && 
                                  _hasMoreData) {
                                // 延迟调用加载更多数据，避免在构建过程中调用 setState
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _loadMoreMovies();
                                });
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              
                              // 正常显示电影项
                              final movie = _isSearching 
                                  ? _searchResults[index] 
                                  : _movies[index];
                              return _VideoItem(
                                movie: movie,
                                onTap: () {
                                  // 跳转到搜索页面并传递视频名称进行搜索
                                  searchDataSource.setSearchQuery(movie.title);
                                  searchDataSource.setSearchExpanded(true);
                                  context.go('/search');
                                },
                              );
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 视频项组件
class _VideoItem extends StatelessWidget {
  final DoubanMovie movie;
  final VoidCallback onTap;

  const _VideoItem({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 处理图片URL，确保其有效且可访问
    String handleImageUrl(String url) {
      return ApiService.handleImageUrl(url);
    }

    final String imageUrl = handleImageUrl(movie.cover);
    
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