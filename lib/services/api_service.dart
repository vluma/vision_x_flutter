import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/home/models/douban_movie.dart';
import '../shared/models/media_detail.dart';

/// 搜索数据状态管理类，处理搜索查询和UI状态
class SearchDataSource extends ChangeNotifier {
  String _searchQuery = '';
  bool _isSearchExpanded = false;

  String get searchQuery => _searchQuery;
  bool get isSearchExpanded => _isSearchExpanded;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSearchExpanded(bool expanded) {
    _isSearchExpanded = expanded;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}

// 全局搜索数据源单例
final searchDataSource = SearchDataSource();

/// API服务类 - 处理豆瓣电影数据和聚合搜索
/// 提供电影/电视剧标签获取、内容搜索、聚合搜索等功能
class ApiService {
  static const String baseUrl = 'https://movie.douban.com/j';

  // 默认电影标签
  static const List<String> _defaultMovieTags = [
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

  // 默认电视标签
  static const List<String> _defaultTvTags = [
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

  /// 获取默认电影标签列表
  static List<String> get defaultMovieTags => _defaultMovieTags;

  /// 获取默认电视剧标签列表
  static List<String> get defaultTvTags => _defaultTvTags;

  // 豆瓣API Dio实例
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      'Referer': 'https://movie.douban.com/',
      'Accept': 'application/json',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// 聚合搜索API配置 - 支持多个视频资源站点
  static final Map<String, Map<String, String>> apiSites = {
    /*
    'dyttzy': {
      'api': 'http://caiji.dyttzyapi.com/api.php/provide/vod',
      'name': '电影天堂资源'
    },
    'ruyi': {
      'api': 'https://cj.rycjapi.com/api.php/provide/vod',
      'name': '如意资源'
    },
    'bfzy': {'api': 'https://bfzyapi.com/api.php/provide/vod', 'name': '暴风资源'},
    'tyyszy': {'api': 'https://tyyszy.com/api.php/provide/vod', 'name': '天涯资源'},
    'ffzy': {'api': 'http://ffzy5.tv/api.php/provide/vod', 'name': '非凡影视'},
    'heimuer': {
      'api': 'https://json.heimuer.xyz/api.php/provide/vod',
      'name': '黑木耳'
    },
    'zy360': {'api': 'https://360zy.com/api.php/provide/vod', 'name': '360资源'},
    'iqiyi': {
      'api': 'https://www.iqiyizyapi.com/api.php/provide/vod',
      'name': 'iqiyi资源'
    },
    'wolong': {
      'api': 'https://wolongzyw.com/api.php/provide/vod',
      'name': '卧龙资源'
    },
    'hwba': {'api': 'https://cjhwba.com/api.php/provide/vod', 'name': '华为吧资源'},
    'jisu': {'api': 'https://jszyapi.com/api.php/provide/vod', 'name': '极速资源'},
    'dbzy': {'api': 'https://dbzy.tv/api.php/provide/vod', 'name': '豆瓣资源'},
    'mozhua': {
      'api': 'https://mozhuazy.com/api.php/provide/vod',
      'name': '魔爪资源'
    },
    'mdzy': {
      'api': 'https://www.mdzyapi.com/api.php/provide/vod',
      'name': '魔都资源'
    },
    'zuid': {
      'api': 'https://api.zuidapi.com/api.php/provide/vod',
      'name': '最大资源'
    },
    'yinghua': {
      'api': 'https://m3u8.apiyhzy.com/api.php/provide/vod',
      'name': '樱花资源'
    },
    'baidu': {
      'api': 'https://api.apibdzy.com/api.php/provide/vod',
      'name': '百度云资源'
    },
    'wujin': {
      'api': 'https://api.wujinapi.me/api.php/provide/vod',
      'name': '无尽资源'
    },
    'wwzy': {'api': 'https://wwzy.tv/api.php/provide/vod', 'name': '旺旺短剧'},
    'ikun': {
      'api': 'https://ikunzyapi.com/api.php/provide/vod',
      'name': 'iKun资源'
    },
    */
  };

  /// 获取电影标签列表
  /// 如果API调用失败，返回默认电影标签
  static Future<List<String>> getMovieTags() async {
    return _getTags('movie', _defaultMovieTags);
  }

  /// 获取电视剧标签列表
  /// 如果API调用失败，返回默认电视剧标签
  static Future<List<String>> getTvTags() async {
    return _getTags('tv', _defaultTvTags);
  }

  /// 私有方法：获取标签的通用实现
  /// [type] 内容类型：'movie' 或 'tv'
  /// [defaultTags] 默认标签列表，用于API调用失败时返回
  static Future<List<String>> _getTags(
      String type, List<String> defaultTags) async {
    try {
      final response =
          await _dio.get('/search_tags', queryParameters: {'type': type});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['tags'] is List) {
          return List<String>.from(data['tags']);
        }
      }
      return defaultTags;
    } catch (e) {
      return defaultTags;
    }
  }

  /// 获取电影/电视剧列表
  /// [type] 内容类型：'movie' 或 'tv'
  /// [tag] 标签名称
  /// [sort] 排序方式，默认'recommend'
  /// [pageStart] 起始页码，默认0
  /// [pageLimit] 每页数量，默认20
  static Future<List<DoubanMovie>> getMovies({
    required String type,
    required String tag,
    String sort = 'recommend',
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
          return subjects
              .map((item) => DoubanMovie.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 聚合搜索 - 使用所有数据源进行搜索
  /// [query] 搜索关键词
  /// 返回所有数据源的搜索结果合并列表
  static Future<List<MediaDetail>> aggregatedSearch(String query) async {
    try {
      final futures = apiSites.entries
          .map((entry) => _searchByAPI(
              entry.key, entry.value['api']!, entry.value['name']!, query))
          .toList();

      final results = await Future.wait(futures, eagerError: false);
      return results.expand((result) => result).toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取用户选中的数据源配置
  /// 从SharedPreferences读取用户选择的数据源
  static Future<Map<String, Map<String, String>>> getSelectedApiSites() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedSourcesString = prefs.getString('selected_sources') ?? '';

    if (selectedSourcesString.isNotEmpty) {
      final selectedSources = selectedSourcesString.split(',').toSet();
      return Map.from(apiSites)
        ..removeWhere((key, _) => !selectedSources.contains(key));
    } else {
      return Map.from(apiSites); // 默认使用所有源
    }
  }

  /// 聚合搜索 - 只使用用户选中的数据源
  /// [query] 搜索关键词
  static Future<List<MediaDetail>> aggregatedSearchWithSelectedSources(
      String query) async {
    try {
      final selectedSites = await getSelectedApiSites();
      final futures = selectedSites.entries
          .map((entry) => _searchByAPI(
              entry.key, entry.value['api']!, entry.value['name']!, query))
          .toList();

      final results = await Future.wait(futures, eagerError: false);
      return results.expand((result) => result).toList();
    } catch (e) {
      return [];
    }
  }

  /// 流式聚合搜索 - 每个API返回结果后立即回调
  /// [query] 搜索关键词
  /// [onResultsReceived] 单个API结果回调
  /// [onSearchCompleted] 所有搜索完成回调
  static Future<void> streamAggregatedSearchWithSelectedSources(
    String query,
    Function(List<MediaDetail>) onResultsReceived,
    Function() onSearchCompleted,
  ) async {
    try {
      final selectedSites = await getSelectedApiSites();
      final totalRequests = selectedSites.length;
      var completedRequests = 0;

      selectedSites.forEach((key, value) {
        _searchByAPI(key, value['api']!, value['name']!, query).then((results) {
          onResultsReceived(results);
          if (++completedRequests == totalRequests) {
            onSearchCompleted();
          }
        }).catchError((_) {
          if (++completedRequests == totalRequests) {
            onSearchCompleted();
          }
        });
      });
    } catch (e) {
      onSearchCompleted();
    }
  }

  /// 按指定API进行搜索
  /// [apiCode] API代码标识
  /// [apiUrl] API地址
  /// [apiName] API名称
  /// [query] 搜索关键词
  static Future<List<MediaDetail>> _searchByAPI(
      String apiCode, String apiUrl, String apiName, String query) async {
    try {
      final apiDio = Dio(BaseOptions(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final searchUrl =
          '$apiUrl?ac=videolist&wd=${Uri.encodeQueryComponent(query)}';
      final response = await apiDio.get(searchUrl);

      if (response.statusCode == 200) {
        dynamic data = response.data;

        // 处理字符串类型的响应数据
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (e) {
            return [];
          }
        }

        if (data is Map && data.containsKey('list') && data['list'] is List) {
          final List<dynamic> list = data['list'];
          return list
              .map((item) =>
                  _mapApiDataToMediaDetail(item, apiName, apiCode, apiUrl))
              .toList();
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // 映射API数据到MediaDetail对象
  static MediaDetail _mapApiDataToMediaDetail(
      dynamic item, String apiName, String apiCode, String apiUrl) {
    // 解析剧集信息
    List<Source> sources =
        _parseEpisodes(item['vod_play_url']?.toString() ?? '');

    return MediaDetail(
      id: item['vod_id'] is int
          ? item['vod_id']
          : int.tryParse(item['vod_id']?.toString() ?? '0') ?? 0,
      name: item['vod_name']?.toString(),
      subtitle: item['vod_sub']?.toString(),
      type: item['type_name']?.toString(),
      category: item['vod_class']?.toString(),
      year: item['vod_year']?.toString(),
      area: item['vod_area']?.toString(),
      language: item['vod_lang']?.toString(),
      duration: item['vod_duration']?.toString(),
      state: item['vod_state']?.toString(),
      remarks: item['vod_remarks']?.toString(),
      version: item['vod_version']?.toString(),
      actors: item['vod_actor']?.toString(),
      director: item['vod_director']?.toString(),
      writer: item['vod_writer']?.toString(),
      description: item['vod_blurb']?.toString(),
      content: item['vod_content']?.toString(),
      poster: _validateImageUrl(item['vod_pic']?.toString()),
      posterThumb: _validateImageUrl(item['vod_pic_thumb']?.toString()),
      posterSlide: _validateImageUrl(item['vod_pic_slide']?.toString()),
      posterScreenshot:
          _validateImageUrl(item['vod_pic_screenshot']?.toString()),
      playUrl: item['vod_play_url']?.toString(),
      playFrom: item['vod_play_from']?.toString(),
      playServer: item['vod_play_server']?.toString(),
      playNote: item['vod_play_note']?.toString(),
      score: item['vod_score']?.toString(),
      scoreAll: item['vod_score_all'] is int
          ? item['vod_score_all']
          : int.tryParse(item['vod_score_all']?.toString() ?? '0') ?? 0,
      scoreNum: item['vod_score_num'] is int
          ? item['vod_score_num']
          : int.tryParse(item['vod_score_num']?.toString() ?? '0') ?? 0,
      doubanScore: item['vod_douban_score']?.toString(),
      doubanId: item['vod_douban_id'] is int
          ? item['vod_douban_id']
          : int.tryParse(item['vod_douban_id']?.toString() ?? '0') ?? 0,
      hits: item['vod_hits'] is int
          ? item['vod_hits']
          : int.tryParse(item['vod_hits']?.toString() ?? '0') ?? 0,
      hitsDay: item['vod_hits_day'] is int
          ? item['vod_hits_day']
          : int.tryParse(item['vod_hits_day']?.toString() ?? '0') ?? 0,
      hitsWeek: item['vod_hits_week'] is int
          ? item['vod_hits_week']
          : int.tryParse(item['vod_hits_week']?.toString() ?? '0') ?? 0,
      hitsMonth: item['vod_hits_month'] is int
          ? item['vod_hits_month']
          : int.tryParse(item['vod_hits_month']?.toString() ?? '0') ?? 0,
      up: item['vod_up'] is int
          ? item['vod_up']
          : int.tryParse(item['vod_up']?.toString() ?? '0') ?? 0,
      down: item['vod_down'] is int
          ? item['vod_down']
          : int.tryParse(item['vod_down']?.toString() ?? '0') ?? 0,
      time: item['vod_time']?.toString(),
      timeAdd: item['vod_time_add'] is int
          ? item['vod_time_add']
          : int.tryParse(item['vod_time_add']?.toString() ?? '0') ?? 0,
      letter: item['vod_letter']?.toString(),
      color: item['vod_color']?.toString(),
      tag: item['vod_tag']?.toString(),
      serial: item['vod_serial']?.toString(),
      tv: item['vod_tv']?.toString(),
      weekday: item['vod_weekday']?.toString(),
      pubdate: item['vod_pubdate']?.toString(),
      total: item['vod_total'] is int
          ? item['vod_total']
          : int.tryParse(item['vod_total']?.toString() ?? '0') ?? 0,
      isEnd: item['vod_isend'] is int
          ? item['vod_isend']
          : int.tryParse(item['vod_isend']?.toString() ?? '0') ?? 0,
      trysee: item['vod_trysee'] is int
          ? item['vod_trysee']
          : int.tryParse(item['vod_trysee']?.toString() ?? '0') ?? 0,
      sourceName: apiName,
      sourceCode: apiCode,
      apiUrl: apiUrl,
      hasCover: item['vod_pic'] != null &&
          item['vod_pic'].toString().startsWith('http'),
      sourceInfo: null,
      surces: sources,
    );
  }

  // 解析剧集信息
  static List<Source> _parseEpisodes(String playUrl) {
    if (playUrl.isEmpty) return [];

    try {
      List<Source> sources = [];
      final sourceStrings = playUrl.split('\$\$\$');

      for (var sourceStr in sourceStrings) {
        final trimmedSource = sourceStr.trim();
        if (trimmedSource.isEmpty) continue;

        final episodeStrings = trimmedSource.split('#');
        List<Episode> episodes = [];
        String sourceType = 'unknown';

        for (var episodeStr in episodeStrings) {
          final trimmedEpisode = episodeStr.trim();
          if (trimmedEpisode.isEmpty) continue;

          final parts = trimmedEpisode.split('\$');
          if (parts.length < 2) continue;

          final title = parts[0].trim();
          final url = parts[1].trim();

          if (!url.startsWith('http://') && !url.startsWith('https://')) {
            continue;
          }

          String type = 'unknown';
          if (url.contains('.m3u8')) {
            type = 'm3u8';
          } else if (url.contains('.mp4')) {
            type = 'mp4';
          } else if (url.contains('.flv')) {
            type = 'flv';
          }

          if (sourceType == 'unknown' && type != 'unknown') {
            sourceType = type;
          }

          episodes.add(Episode(
            title: title,
            url: url,
            index: episodes.length,
            type: type,
          ));
        }

        if (episodes.isNotEmpty && sourceType != 'unknown') {
          sources.add(Source(
            name: sourceType,
            episodes: episodes,
          ));
        }
      }

      return sources;
    } catch (e) {
      return [];
    }
  }

  // 验证图片URL是否有效
  static String? _validateImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return null;
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

    // 其他情况返回原URL，确保不为null
    return url;
  }
}
