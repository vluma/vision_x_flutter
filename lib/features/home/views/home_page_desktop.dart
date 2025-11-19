import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/home/models/douban_movie.dart';
import 'package:vision_x_flutter/features/home/models/filter_criteria.dart';
import 'package:vision_x_flutter/features/home/providers/home_providers.dart';
import 'package:vision_x_flutter/features/home/states/home_state.dart';
import 'package:vision_x_flutter/features/home/views/widgets/video_grid.dart';
import 'package:vision_x_flutter/features/home/views/widgets/loading_skeleton.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部筛选栏
          _buildFilterBar(viewModel),

          // 内容区域
          Expanded(
            child: _buildBody(state, viewModel),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 分类筛选
              _buildCategorySelector(viewModel),

              const SizedBox(width: 16),

              // 排序筛选
              _buildSortSelector(viewModel),

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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 来源标签
          _buildSourceTags(viewModel),
        ],
      ),
    );
  }

  /// 构建分类选择器
  Widget _buildCategorySelector(dynamic viewModel) {
    final categories = [MovieCategory.movie.label, MovieCategory.tv.label];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('分类: ', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        ...categories.map((category) {
          final bool isSelected = viewModel.currentCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  viewModel.changeCategory(category);
                }
              },
            ),
          );
        }),
      ],
    );
  }

  /// 构建排序选择器
  Widget _buildSortSelector(dynamic viewModel) {
    final sortOptions = FilterCriteria.sortOptions;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('排序: ', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          initialValue: viewModel.currentSort,
          onSelected: (value) => viewModel.changeSort(value),
          itemBuilder: (BuildContext context) {
            return sortOptions.map((option) {
              return PopupMenuItem<String>(
                value: option['value']!,
                child: Text(option['label']!),
              );
            }).toList();
          },
          child: Row(
            children: [
              Text(sortOptions
                  .firstWhere((element) =>
                      element['value'] == viewModel.currentSort)['label']!),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建来源标签
  Widget _buildSourceTags(dynamic viewModel) {
    final sources = viewModel.currentCategory == MovieCategory.movie.label
        ? FilterCriteria.movieSources
        : FilterCriteria.tvSources;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: sources.map((source) {
          final bool isSelected = viewModel.currentSource == source;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(source),
              selected: isSelected,
              onSelected: (selected) => viewModel.changeSource(source),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildBody(HomeState state, dynamic viewModel) {
    return state.map(
      initial: (_) => const LoadingSkeleton(),
      loading: (_) => const LoadingSkeleton(),
      loaded: (loadedState) => _buildContentGrid(loadedState.movies
          .map((movie) => _convertToDoubanMovie(movie))
          .toList(), viewModel),
      error: (errorState) => Center(
        child: Text('错误: ${errorState.message}'),
      ),
    );
  }

  /// 计算网格列数基于屏幕宽度
  int _calculateCrossAxisCount(double width) {
    // 根据宽度动态计算列数
    // 最小宽度200，最大宽度300
    const minItemWidth = 200.0;
    const maxItemWidth = 300.0;
    
    // 计算列数
    int count = (width / maxItemWidth).floor();
    
    // 确保至少有3列，最多不超过10列
    count = count < 3 ? 3 : count;
    count = count > 10 ? 10 : count;
    
    return count;
  }

  /// 构建内容网格
  Widget _buildContentGrid(List<DoubanMovie> movies, dynamic viewModel) {
    if (movies.isEmpty) {
      return const Center(
        child: Text('暂无数据'),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        final itemWidth = constraints.maxWidth / crossAxisCount;
        final childAspectRatio = itemWidth / (itemWidth * 1.5); // 2:3 比例
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildMovieCard(movie, viewModel);
            },
          ),
        );
      },
    );
  }

  /// 构建电影卡片
  Widget _buildMovieCard(DoubanMovie movie, dynamic viewModel) {
    final String imageUrl = ApiService.handleImageUrl(movie.cover);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => viewModel.onItemTap(_convertToMovieEntity(movie), context),
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