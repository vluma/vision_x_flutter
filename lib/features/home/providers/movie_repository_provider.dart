import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/home/data/movie_repository.dart';
import 'package:vision_x_flutter/features/home/data/repositories/movie_repository_impl.dart';

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl();
});