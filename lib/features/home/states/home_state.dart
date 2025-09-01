library home_states;

import '../entities/movie_entity.dart';

/// 首页状态基类
abstract class HomeState {
  const HomeState();
  
  T map<T>({
    required T Function(HomeInitial) initial,
    required T Function(HomeLoading) loading,
    required T Function(HomeLoaded) loaded,
    required T Function(HomeError) error,
  }) {
    if (this is HomeInitial) {
      return initial(this as HomeInitial);
    } else if (this is HomeLoading) {
      return loading(this as HomeLoading);
    } else if (this is HomeLoaded) {
      return loaded(this as HomeLoaded);
    } else if (this is HomeError) {
      return error(this as HomeError);
    } else {
      throw Exception('Unknown HomeState type');
    }
  }
}

/// 初始状态
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// 加载中状态
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// 加载成功状态
class HomeLoaded extends HomeState {
  final List<MovieEntity> movies;
  final bool hasMore;
  final bool isLoadingMore;

  const HomeLoaded({
    required this.movies,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  HomeLoaded copyWith({
    List<MovieEntity>? movies,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeLoaded(
      movies: movies ?? this.movies,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// 加载失败状态
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}