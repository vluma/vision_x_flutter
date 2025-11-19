import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/home/data/movie_repository.dart';

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepository();
});