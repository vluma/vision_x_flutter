import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/home/models/douban_movie.dart';
import 'package:vision_x_flutter/features/home/providers/home_providers.dart';
import 'package:vision_x_flutter/features/home/states/home_state.dart';
import 'package:vision_x_flutter/features/home/views/widgets/video_grid.dart';
import 'package:vision_x_flutter/features/home/entities/movie_entity.dart';
import 'package:vision_x_flutter/shared/widgets/custom_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:vision_x_flutter/core/themes/colors.dart';

/// 用于桌面端的主页，参考macOS TV应用的设计风格
class HomePageDesktop extends ConsumerStatefulWidget {
  const HomePageDesktop({super.key});

  @override
  ConsumerState<HomePageDesktop> createState() => _HomePageDesktopState();
}

class _HomePageDesktopState extends ConsumerState<HomePageDesktop> {
  // 侧边栏导航项
  final List<Map<String, dynamic>> _navigationItems = [
    {
      'title': '立即观看',
      'icon': Icons.play_circle_filled,
    },
    {
      'title': '电影',
      'icon': Icons.movie,
    },
    {
      'title': '电视剧',
      'icon': Icons.tv,
    },
    {
      'title': '儿童',
      'icon': Icons.child_care,
    },
    {
      'title': '我的媒体库',
      'icon': Icons.video_library,
    },
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        ref.read(homeViewModelProvider.notifier).loadMovies();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      body: Row(
        children: [
          // 侧边栏导航
          _buildSidebar(),

          // 主内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部筛选栏
                _buildFilterBar(viewModel),

                // 内容区域
                Expanded(
                  child: _buildBody(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建侧边栏导航
  Widget _buildSidebar() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFf5f5f7),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo区域
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Vision X',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 导航项
          Expanded(
            child: ListView.builder(
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Material(
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryButtonDark.withOpacity(0.3)
                            : AppColors.primaryButtonLight.withOpacity(0.3))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'],
                              size: 20,
                              color: isSelected
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppColors.primaryButtonDark)
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.black87),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.primaryButtonDark)
                                    : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建顶部筛选栏
  Widget _buildFilterBar(dynamic viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 分类筛选
          _buildDropdown(
            '分类',
            viewModel.currentCategory,
            ['全部', '电影', '电视剧', '动漫', '综艺'],
            (value) => viewModel.changeCategory(value!),
          ),

          const SizedBox(width: 16),

          // 来源筛选
          _buildDropdown(
            '来源',
            viewModel.currentSource,
            ['全部', '热门', '豆瓣', '自定义'],
            (value) => viewModel.changeSource(value!),
          ),

          const SizedBox(width: 16),

          // 排序筛选
          _buildDropdown(
            '排序',
            viewModel.currentSort,
            ['最新', '评分', '热门', 'recommend'],
            (value) => viewModel.changeSort(value!),
          ),

          const Spacer(),

          // 搜索框
          SizedBox(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索视频...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建下拉筛选组件
  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          underline: Container(),
        ),
      ],
    );
  }

  /// 构建内容区域
  Widget _buildBody(HomeState state) {
    return state.map(
      initial: (_) => const Center(child: CircularProgressIndicator()),
      loading: (_) => const Center(child: CircularProgressIndicator()),
      loaded: (loadedState) => _buildContentGrid(loadedState.movies
          .map((movie) => _convertToDoubanMovie(movie))
          .toList()),
      error: (errorState) => Center(
        child: Text('错误: ${errorState.message}'),
      ),
    );
  }

  /// 构建内容网格
  Widget _buildContentGrid(List<DoubanMovie> movies) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, // 桌面端显示更多列
          childAspectRatio: 0.6, // 更适合海报比例
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _buildMovieCard(movie);
        },
      ),
    );
  }

  /// 构建电影卡片
  Widget _buildMovieCard(DoubanMovie movie) {
    final String imageUrl = ApiService.handleImageUrl(movie.cover);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => ref
          .read(homeViewModelProvider.notifier)
          .onItemTap(_convertToMovieEntity(movie), context),
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 电影海报
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12.0)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
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
              ),
            ),

            // 电影信息
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (movie.rate.isNotEmpty &&
                      double.tryParse(movie.rate) != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          movie.rate,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DoubanMovie _convertToDoubanMovie(MovieEntity movie) {
    return DoubanMovie(
      id: movie.id,
      title: movie.title,
      cover: movie.poster,
      rate: movie.rating.toString(),
      url: '',
      isNew: false,
      playable: true,
      episodesInfo: '',
      coverX: 0,
      coverY: 0,
    );
  }

  MovieEntity _convertToMovieEntity(DoubanMovie movie) {
    return MovieEntity(
      id: movie.id,
      title: movie.title,
      poster: movie.cover,
      rating: double.tryParse(movie.rate) ?? 0.0,
      year: 0,
    );
  }
}
