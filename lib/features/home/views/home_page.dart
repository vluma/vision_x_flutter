import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/home/models/douban_movie.dart';
import 'package:vision_x_flutter/features/home/providers/home_providers.dart';
import 'package:vision_x_flutter/features/home/states/home_state.dart';
import 'package:vision_x_flutter/features/home/views/widgets/home_app_bar.dart';
import 'package:vision_x_flutter/features/home/views/widgets/loading_skeleton.dart';
import 'package:vision_x_flutter/features/home/views/widgets/video_grid.dart';
import 'package:vision_x_flutter/features/home/entities/movie_entity.dart';
import 'package:vision_x_flutter/shared/utilities/platform_adapter.dart';

// 条件导入桌面端主页
import 'home_page_desktop.dart' if (dart.library.io) 'home_page_desktop.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // 初始化加载数据 - 使用异步调度避免阻塞UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        ref.read(homeViewModelProvider.notifier).loadMovies();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 根据平台选择使用移动端或桌面端主页
    if (PlatformAdapter.isDesktop) {
      return const HomePageDesktop();
    } else {
      return _buildMobileHome();
    }
  }

  Widget _buildMobileHome() {
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    
    return Scaffold(
      appBar: HomeAppBar(
        selectedCategory: viewModel.currentCategory,
        selectedSource: viewModel.currentSource,
        selectedSort: viewModel.currentSort,
        onCategoryChanged: (category) => viewModel.changeCategory(category),
        onSourceChanged: (source) => viewModel.changeSource(source),
        onSortChanged: (sort) => viewModel.changeSort(sort),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(HomeState state) {
    return state.map(
      initial: (_) => const LoadingSkeleton(),
      loading: (_) => const LoadingSkeleton(),
      loaded: (loadedState) => VideoGrid(
        movies: loadedState.movies.map((movie) => _convertToDoubanMovie(movie)).toList(),
        hasMoreData: loadedState.hasMore,
        isLoading: loadedState.isLoadingMore,
        onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
        onLoadMore: () => ref.read(homeViewModelProvider.notifier).loadMore(),
        onItemTap: (movie) => ref.read(homeViewModelProvider.notifier).onItemTap(_convertToMovieEntity(movie), context),
      ),
      error: (errorState) => Center(
        child: Text('错误: ${errorState.message}'),
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