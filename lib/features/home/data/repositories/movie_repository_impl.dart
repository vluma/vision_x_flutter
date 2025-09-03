import 'package:vision_x_flutter/features/home/data/movie_repository.dart';
import 'package:vision_x_flutter/features/home/entities/movie_entity.dart';
import 'package:vision_x_flutter/services/api_service.dart';

class MovieRepositoryImpl implements MovieRepository {
  @override
  Future<List<MovieEntity>> getMovies({
    String type = 'movie',
    String tag = '热门',
    String sort = 'recommend',
    int pageLimit = 20,
    int pageStart = 0,
  }) async {
    try {
      final movies = await ApiService.getMovies(
        type: type,
        tag: tag,
        sort: sort,
        pageLimit: pageLimit,
        pageStart: pageStart,
      );
      
      return movies.map((movie) => MovieEntity(
        id: movie.id,
        title: movie.title,
        poster: movie.cover,
        rating: double.tryParse(movie.rate) ?? 0.0,
        year: _extractYearFromTitle(movie.title),
        director: '',
        casts: [],
        genre: '',
        description: '',
      )).toList();
    } catch (e) {
      throw Exception('获取电影数据失败: $e');
    }
  }

  int _extractYearFromTitle(String title) {
    final regex = RegExp(r'\((\d{4})\)');
    final match = regex.firstMatch(title);
    return match != null ? int.parse(match.group(1)!) : DateTime.now().year;
  }

  @override
  Future<List<MovieEntity>> refreshMovies({
    String type = 'movie',
    String tag = '热门',
    String sort = 'recommend',
    int pageLimit = 20,
  }) {
    return getMovies(
      type: type,
      tag: tag,
      sort: sort,
      pageLimit: pageLimit,
      pageStart: 0,
    );
  }

  @override
  Future<List<MovieEntity>> loadMoreMovies({
    String type = 'movie',
    String tag = '热门',
    String sort = 'recommend',
    int pageLimit = 20,
    int pageStart = 0,
  }) {
    return getMovies(
      type: type,
      tag: tag,
      sort: sort,
      pageLimit: pageLimit,
      pageStart: pageStart,
    );
  }
}