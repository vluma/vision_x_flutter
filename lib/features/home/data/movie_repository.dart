/// 电影数据仓库
/// 负责电影数据的获取和管理

import 'package:vision_x_flutter/features/home/entities/movie_entity.dart';
import 'package:vision_x_flutter/services/api_service.dart';

class MovieRepository {
  /// 获取电影列表
  Future<List<MovieEntity>> getMovies({
    String type = 'movie',
    String tag = '热门',
    int pageLimit = 20,
    int pageStart = 0,
  }) async {
    try {
      final movies = await ApiService.getMovies(
        type: type,
        tag: tag,
        pageLimit: pageLimit,
        pageStart: pageStart,
      );
      
      return movies.map((movie) => MovieEntity(
        id: movie.id,
        title: movie.title,
        poster: movie.cover,
        rating: double.tryParse(movie.rate) ?? 0.0,
        year: _extractYearFromTitle(movie.title),
      )).toList();
    } catch (e) {
      throw Exception('获取电影数据失败: $e');
    }
  }

  /// 刷新电影数据
  Future<List<MovieEntity>> refreshMovies({
    String type = 'movie',
    String tag = '热门',
    int pageLimit = 20,
  }) {
    return getMovies(type: type, tag: tag, pageLimit: pageLimit, pageStart: 0);
  }

  /// 加载更多电影
  Future<List<MovieEntity>> loadMoreMovies({
    String type = 'movie',
    String tag = '热门',
    int pageLimit = 20,
    int pageStart = 0,
  }) {
    return getMovies(type: type, tag: tag, pageLimit: pageLimit, pageStart: pageStart);
  }

  /// 从标题中提取年份
  int _extractYearFromTitle(String title) {
    final regex = RegExp(r'\((\d{4})\)');
    final match = regex.firstMatch(title);
    return match != null ? int.parse(match.group(1)!) : DateTime.now().year;
  }
}