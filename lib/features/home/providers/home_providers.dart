library home_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/home/states/home_state.dart';
import '../data/movie_repository.dart';
import '../viewmodels/home_view_model.dart';

/// 电影仓库提供者
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepository();
});

/// 首页视图模型提供者
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(ref.watch(movieRepositoryProvider));
});