import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/models/douban_movie.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/theme/colors.dart';
import 'package:vision_x_flutter/components/loading_animation.dart';
import 'package:vision_x_flutter/components/custom_card.dart';
import 'package:vision_x_flutter/theme/spacing.dart';
import 'package:vision_x_flutter/pages/test_swipe_page.dart';

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
  bool _isLoading = false;
  bool _tagsLoading = false;
  bool _hasMoreData = true;
  int _currentPageStart = 0;
  final int _pageLimit = 20;

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
  List<String> _sources = ApiService.defaultMovieTags;

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
            ? ApiService.defaultMovieTags
            : ApiService.defaultTvTags;
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
        _hasMoreData = movies.length == _pageLimit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载失败，请稍后重试')),
        );
      }
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
        _hasMoreData = movies.length == _pageLimit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载更多失败，请稍后重试')),
        );
      }
    }
  }

  // 下拉刷新
  Future<void> _refresh() async {
    _loadTags();
    await _loadMovies();
  }

  // 切换分类
  void _switchCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedSource = '热门';
    });
    _loadTags();
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

  // 构建分类导航项
  List<Widget> _buildCategoryActions() {
    return [
      ..._categories.map((category) => _buildCategoryItem(category)),
      _buildSortButton(),
    ];
  }

  // 构建单个分类项
  Widget _buildCategoryItem(String category) {
    final bool isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            _switchCategory(category);
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodySmall?.color ??
                        Colors.grey,
              ),
            ),
            const SizedBox(height: 3),
            if (isSelected) _buildIndicator(),
          ],
        ),
      ),
    );
  }

  // 构建选中指示器
  Widget _buildIndicator() {
    return Container(
      height: 3,
      width: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // 构建排序按钮
  Widget _buildSortButton() {
    return PopupMenuButton<String>(
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
    );
  }

  // 构建源标签列表
  List<Widget> _buildSourceTags() {
    return _sources.map((source) {
      final bool isSelected = _selectedSource == source;
      return Padding(
        padding: const EdgeInsets.only(right: 20),
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              _switchSource(source);
            }
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                source,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey,
                ),
              ),
              const SizedBox(height: 3),
              if (isSelected)
                Container(
                  height: 2,
                  width: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('豆瓣热门'),
        actions: [
          ..._buildCategoryActions(),
          IconButton(
            icon: const Icon(Icons.swipe_left),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TestSwipePage(),
                ),
              );
            },
            tooltip: '测试左滑返回',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _buildSourceTags(),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 500) {
                    _loadMoreMovies();
                    return true;
                  }
                  return false;
                },
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建主要内容
  Widget _buildContent() {
    if (_isLoading && _movies.isEmpty) {
      return _buildSkeletonList();
    }

    if (_movies.isEmpty) {
      return const Center(
        child: Text('暂无数据'),
      );
    }

    return GridView.builder(
      padding: AppSpacing.pageMargin.copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.bottomNavigationBarMargin,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: _movies.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index == _movies.length && _hasMoreData) {
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

        final movie = _movies[index];
        return _VideoItem(
          movie: movie,
          onTap: () {
            // 点击电影项时跳转到搜索页面
            searchDataSource.setSearchQuery(movie.title);
            searchDataSource.setSearchExpanded(true);
            context.go('/search');
          },
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    return GridView.builder(
      padding: AppSpacing.pageMargin.copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.xl * 2,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 8,
      itemBuilder: (BuildContext context, int index) {
        return _VideoItemSkeleton();
      },
    );
  }
}

// 视频项骨架屏组件 - 带有VisionX文字和彩色渐变效果的自定义加载动画
class _VideoItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                width: double.infinity,
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 60,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                ),
              ],
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String imageUrl = ApiService.handleImageUrl(movie.cover);

    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
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
                    ),
                    if (movie.rate.isNotEmpty &&
                        double.tryParse(movie.rate) != null &&
                        double.parse(movie.rate) > 0)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.darkBackground.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.yellow, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                movie.rate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
