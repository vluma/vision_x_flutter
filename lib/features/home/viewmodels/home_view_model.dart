import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/features/home/data/movie_repository.dart';
import 'package:vision_x_flutter/features/home/models/douban_movie.dart';
import 'package:vision_x_flutter/features/home/models/filter_criteria.dart';
import 'package:vision_x_flutter/features/home/states/home_state.dart';
import 'package:vision_x_flutter/services/api_service.dart';

/// 首页ViewModel，处理业务逻辑
class HomeViewModel extends StateNotifier<HomeState> {
  final MovieRepository _movieRepository;
  
  FilterCriteria _filterCriteria = FilterCriteria.defaultCriteria;

  HomeViewModel(this._movieRepository) : super(const HomeInitial());

  /// 获取当前筛选条件
  FilterCriteria get filterCriteria => _filterCriteria;
  
  /// 获取当前分类
  String get currentCategory => _filterCriteria.category.label;
  
  /// 获取当前来源
  String get currentSource => _filterCriteria.source;
  
  /// 获取当前排序
  String get currentSort => _filterCriteria.sort;

  /// 加载首页数据
  Future<void> loadMovies() async {
    // 使用异步调度确保状态更新不会阻塞UI
    await Future.microtask(() => state = HomeLoading());
    try {
      final type = _filterCriteria.category == MovieCategory.movie ? 'movie' : 'tv';
      final movies = await _movieRepository.getMovies(
        type: type,
        tag: _filterCriteria.source,
        sort: _filterCriteria.sort,
        pageLimit: 20,
      );
      await Future.microtask(() => state = HomeLoaded(movies: movies, hasMore: movies.length >= 20));
    } catch (e) {
      await Future.microtask(() => state = HomeError('加载失败: $e'));
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    try {
      final type = _filterCriteria.category == MovieCategory.movie ? 'movie' : 'tv';
      final movies = await _movieRepository.refreshMovies(
        type: type,
        tag: _filterCriteria.source,
        sort: _filterCriteria.sort,
        pageLimit: 20,
      );
      await Future.microtask(() => state = HomeLoaded(movies: movies, hasMore: movies.length >= 20));
    } catch (e) {
      // 错误处理保持在UI线程之外
      if (mounted) {
        await Future.microtask(() => state = HomeError('刷新失败: $e'));
      }
    }
  }

  /// 加载更多数据
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is HomeLoaded && !currentState.isLoadingMore) {
      await Future.microtask(() => state = currentState.copyWith(isLoadingMore: true));
      try {
        final type = _filterCriteria.category == MovieCategory.movie ? 'movie' : 'tv';
        final moreMovies = await _movieRepository.loadMoreMovies(
          type: type,
          tag: _filterCriteria.source,
          sort: _filterCriteria.sort,
          pageLimit: 20,
          pageStart: currentState.movies.length,
        );
        final allMovies = [...currentState.movies, ...moreMovies];
        await Future.microtask(() => state = HomeLoaded(
          movies: allMovies,
          hasMore: moreMovies.length >= 20,
          isLoadingMore: false,
        ));
      } catch (e) {
        await Future.microtask(() => state = currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  /// 更改分类
  Future<void> changeCategory(String category) async {
    final movieCategory = category == MovieCategory.movie.label ? MovieCategory.movie : MovieCategory.tv;
    if (_filterCriteria.category != movieCategory) {
      _filterCriteria = _filterCriteria.copyWith(
        category: movieCategory,
        source: movieCategory == MovieCategory.movie 
            ? FilterCriteria.movieSources.first 
            : FilterCriteria.tvSources.first,
      );
      await loadMovies();
    }
  }

  /// 更改来源
  Future<void> changeSource(String source) async {
    if (_filterCriteria.source != source) {
      _filterCriteria = _filterCriteria.copyWith(source: source);
      await loadMovies();
    }
  }

  /// 更改排序
  Future<void> changeSort(String sort) async {
    if (_filterCriteria.sort != sort) {
      _filterCriteria = _filterCriteria.copyWith(sort: sort);
      await loadMovies();
    }
  }

  /// 处理点击电影项
  void onItemTap(DoubanMovie movie, BuildContext context) {
    // 点击电影项时跳转到搜索页面
    // 搜索功能将在后续版本实现
    Future.microtask(() {
      searchDataSource.setSearchQuery(movie.title);
      searchDataSource.setSearchExpanded(true);
    });
    context.push('/search', extra: {'query': movie.title});
  }
  
  /// 检查组件是否仍然挂载
  bool get mounted => state != null;
}