/// 电影数据仓库
/// 负责电影数据的获取和管理
library;

import 'package:vision_x_flutter/features/home/models/douban_movie.dart';
import 'package:vision_x_flutter/services/api_service.dart';

class MovieRepository {
  /// 获取电影列表
  Future<List<DoubanMovie>> getMovies({
    String type = 'movie',
    String tag = '热门',
    String sort = 'recommend',
    int pageLimit = 20,
    int pageStart = 0,
  }) async {
    try {
      return await ApiService.getMovies(
        type: type,
        tag: tag,
        sort: sort,
        pageLimit: pageLimit,
        pageStart: pageStart,
      );
    } catch (e) {
      throw Exception('获取电影数据失败: $e');
    }
  }

  /// 刷新电影数据
  Future<List<DoubanMovie>> refreshMovies({
    String type = 'movie',
    String tag = '热门',
    String sort = 'recommend',
    int pageLimit = 20,
  }) {
    return getMovies(type: type, tag: tag, sort: sort, pageLimit: pageLimit, pageStart: 0);
  }

  /// 加载更多电影
  Future<List<DoubanMovie>> loadMoreMovies({
    String type = 'movie',
    String tag = '热门',
    String sort = 'recommend',
    int pageLimit = 20,
    int pageStart = 0,
  }) {
    return getMovies(type: type, tag: tag, sort: sort, pageLimit: pageLimit, pageStart: pageStart);
  }
}