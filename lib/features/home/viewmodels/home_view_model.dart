import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/features/home/data/movie_repository.dart';
import 'package:vision_x_flutter/features/home/entities/movie_entity.dart';
import 'package:vision_x_flutter/features/home/states/home_state.dart';
import 'package:vision_x_flutter/services/api_service.dart';

/// 首页ViewModel，处理业务逻辑
class HomeViewModel extends StateNotifier<HomeState> {
  final MovieRepository _movieRepository;
  
  String _currentCategory = '电影';
  String _currentSource = '热门';
  String _currentSort = 'recommend';

  HomeViewModel(this._movieRepository) : super(const HomeInitial());

  /// 获取当前分类
  String get currentCategory => _currentCategory;
  
  /// 获取当前来源
  String get currentSource => _currentSource;
  
  /// 获取当前排序
  String get currentSort => _currentSort;

  /// 加载首页数据
  Future<void> loadMovies() async {
    state = const HomeLoading();
    try {
      final type = _currentCategory == '电影' ? 'movie' : 'tv';
      final movies = await _movieRepository.getMovies(
        type: type,
        tag: _currentSource,
        pageLimit: 20,
      );
      state = HomeLoaded(movies: movies, hasMore: movies.length >= 20);
    } catch (e) {
      state = HomeError('加载失败: $e');
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    try {
      final type = _currentCategory == '电影' ? 'movie' : 'tv';
      final movies = await _movieRepository.refreshMovies(
        type: type,
        tag: _currentSource,
        pageLimit: 20,
      );
      state = HomeLoaded(movies: movies, hasMore: movies.length >= 20);
    } catch (e) {
      state = HomeError('刷新失败: $e');
    }
  }

  /// 加载更多数据
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is HomeLoaded && !currentState.isLoadingMore) {
      state = currentState.copyWith(isLoadingMore: true);
      try {
        final type = _currentCategory == '电影' ? 'movie' : 'tv';
        final moreMovies = await _movieRepository.loadMoreMovies(
          type: type,
          tag: _currentSource,
          pageLimit: 20,
          pageStart: currentState.movies.length,
        );
        final allMovies = [...currentState.movies, ...moreMovies];
        state = HomeLoaded(
          movies: allMovies,
          hasMore: moreMovies.length >= 20,
          isLoadingMore: false,
        );
      } catch (e) {
        state = currentState.copyWith(isLoadingMore: false);
      }
    }
  }

  /// 更改分类
  Future<void> changeCategory(String category) async {
    if (_currentCategory != category) {
      _currentCategory = category;
      // 切换分类时重置二级分类
      _currentSource = category == '电影' ? '热门' : '热门';
      await loadMovies();
    }
  }

  /// 更改来源
  Future<void> changeSource(String source) async {
    if (_currentSource != source) {
      _currentSource = source;
      await loadMovies();
    }
  }

  /// 更改排序
  Future<void> changeSort(String sort) async {
    if (_currentSort != sort) {
      _currentSort = sort;
      // Note: Sort functionality would need to be implemented in the repository
      // For now, we'll reload with current filters
      await loadMovies();
    }
  }

  /// 处理点击电影项
  void onItemTap(MovieEntity movie, BuildContext context) {
    // 点击电影项时跳转到搜索页面
    // 搜索功能将在后续版本实现
    searchDataSource.setSearchQuery(movie.title);
    searchDataSource.setSearchExpanded(true);
    context.push('/search', extra: {'query': movie.title});
  }
}