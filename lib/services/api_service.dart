import 'package:dio/dio.dart';
import '../models/douban_movie.dart';

class ApiService {
  static const String baseUrl = 'https://movie.douban.com/j';
  
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
      'Referer': 'https://movie.douban.com/',
      'Accept': 'application/json',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 获取电影标签
  static Future<List<String>> getMovieTags() async {
    try {
      final response = await _dio.get('/search_tags?type=movie');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['tags'] is List) {
          return List<String>.from(data['tags']);
        }
      }
      // 如果请求失败，返回默认标签
      return [
        "热门",
        "最新",
        "经典",
        "豆瓣高分",
        "冷门佳片",
        "华语",
        "欧美",
        "韩国",
        "日本",
        "动作",
        "喜剧",
        "爱情",
        "科幻",
        "悬疑",
        "恐怖",
        "治愈",
      ];
    } catch (e) {
      // 出错时返回默认标签
      return [
        "热门",
        "最新",
        "经典",
        "豆瓣高分",
        "冷门佳片",
        "华语",
        "欧美",
        "韩国",
        "日本",
        "动作",
        "喜剧",
        "爱情",
        "科幻",
        "悬疑",
        "恐怖",
        "治愈",
      ];
    }
  }

  // 获取电视剧标签
  static Future<List<String>> getTvTags() async {
    try {
      final response = await _dio.get('/search_tags?type=tv');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['tags'] is List) {
          return List<String>.from(data['tags']);
        }
      }
      // 如果请求失败，返回默认标签
      return [
        "热门",
        "美剧",
        "英剧",
        "韩剧",
        "日剧",
        "国产剧",
        "港剧",
        "日本动画",
        "综艺",
        "纪录片",
      ];
    } catch (e) {
      // 出错时返回默认标签
      return [
        "热门",
        "美剧",
        "英剧",
        "韩剧",
        "日剧",
        "国产剧",
        "港剧",
        "日本动画",
        "综艺",
        "纪录片",
      ];
    }
  }

  // 获取电影/电视剧列表
  static Future<List<DoubanMovie>> getMovies({
    required String type,
    required String tag,
    String sort = 'recommend', // 默认推荐排序
    int pageStart = 0,
    int pageLimit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/search_subjects',
        queryParameters: {
          'type': type,
          'tag': tag,
          'sort': sort,
          'page_start': pageStart,
          'page_limit': pageLimit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['subjects'] is List) {
          final List<dynamic> subjects = data['subjects'];
          return subjects.map((item) => DoubanMovie.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 处理图片URL，使用代理服务解决防盗链问题
  static String handleImageUrl(String url) {
    if (url.isEmpty) {
      return '';
    }
    
    // 如果URL已经是完整格式，使用代理服务处理
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // 使用图片代理服务解决防盗链问题
      return 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}&default=1';
    }
    
    // 如果是相对路径或不完整的URL，尝试修复
    if (url.startsWith('//')) {
      final fullUrl = 'https:$url';
      return 'https://images.weserv.nl/?url=${Uri.encodeComponent(fullUrl)}&default=1';
    }
    
    // 其他情况返回原URL
    return url;
  }
}