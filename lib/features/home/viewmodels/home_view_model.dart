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
  
  HomeViewModel(this._movieRepository) : super(HomeInitial());

  /// 加载首页数据
  Future<void> loadMovies() async {
    state = HomeLoading();
    try {
      final movies = await _movieRepository.getMovies(pageLimit: 20);
      state = HomeLoaded(movies: movies, hasMore: movies.length >= 20);
    } catch (e) {
      state = HomeError('加载失败: $e');
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    try {
      final movies = await _movieRepository.refreshMovies(pageLimit: 20);
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
        final moreMovies = await _movieRepository.loadMoreMovies(
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

  /// 处理点击电影项
  void onItemTap(MovieEntity movie, BuildContext context) {
    // 点击电影项时跳转到搜索页面
    // 搜索功能将在后续版本实现
    searchDataSource.setSearchQuery(movie.title);
    searchDataSource.setSearchExpanded(true);
    context.push('/search', extra: {'query': movie.title});
  }
}