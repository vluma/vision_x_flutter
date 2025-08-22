import 'package:dio/dio.dart';
import '../models/douban_movie.dart';
import '../models/media_detail.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert'; // 添加dart:convert用于JSON解析
import 'package:shared_preferences/shared_preferences.dart';

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

// 创建全局单例
final searchDataSource = SearchDataSource();

class ApiService {
  static const String baseUrl = 'https://movie.douban.com/j';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
      'Referer': 'https://movie.douban.com/',
      'Accept': 'application/json',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 聚合搜索的API配置
  static final Map<String, Map<String, String>> apiSites = {
    'dyttzy': {
      'api': 'http://caiji.dyttzyapi.com/api.php/provide/vod',
      'name': '电影天堂资源',
    },
    'ruyi': {
      'api': 'https://cj.rycjapi.com/api.php/provide/vod',
      'name': '如意资源',
    },
    'bfzy': {
      'api': 'https://bfzyapi.com/api.php/provide/vod',
      'name': '暴风资源',
    },
    'tyyszy': {
      'api': 'https://tyyszy.com/api.php/provide/vod',
      'name': '天涯资源',
    },
    'ffzy': {
      'api': 'http://ffzy5.tv/api.php/provide/vod',
      'name': '非凡影视',
    },
    'heimuer': {
      'api': 'https://json.heimuer.xyz/api.php/provide/vod',
      'name': '黑木耳',
    },
    'zy360': {
      'api': 'https://360zy.com/api.php/provide/vod',
      'name': '360资源',
    },
    'iqiyi': {
      'api': 'https://www.iqiyizyapi.com/api.php/provide/vod',
      'name': 'iqiyi资源',
    },
    'wolong': {
      'api': 'https://wolongzyw.com/api.php/provide/vod',
      'name': '卧龙资源',
    },
    'hwba': {
      'api': 'https://cjhwba.com/api.php/provide/vod',
      'name': '华为吧资源',
    },
    'jisu': {
      'api': 'https://jszyapi.com/api.php/provide/vod',
      'name': '极速资源',
    },
    'dbzy': {
      'api': 'https://dbzy.tv/api.php/provide/vod',
      'name': '豆瓣资源',
    },
    'mozhua': {
      'api': 'https://mozhuazy.com/api.php/provide/vod',
      'name': '魔爪资源',
    },
    'mdzy': {
      'api': 'https://www.mdzyapi.com/api.php/provide/vod',
      'name': '魔都资源',
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
  };

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

  // 聚合搜索
  static Future<List<MediaDetail>> aggregatedSearch(String query) async {
    try {
      // 创建所有API请求
      List<Future<List<MediaDetail>>> futures = [];

      apiSites.forEach((key, value) {
        futures.add(_searchByAPI(key, value['api']!, value['name']!, query));
      });

      // 并发执行所有请求
      final results = await Future.wait(futures, eagerError: false);

      // 合并结果
      List<MediaDetail> allResults = [];
      for (var result in results) {
        allResults.addAll(result);
      }

      return allResults;
    } catch (e) {
      return [];
    }
  }

  // 获取选中的数据源
  static Future<Map<String, Map<String, String>>> getSelectedApiSites() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedSourcesString = prefs.getString('selected_sources') ?? '';
    
    if (selectedSourcesString.isNotEmpty) {
      Set<String> selectedSources = selectedSourcesString.split(',').toSet();
      Map<String, Map<String, String>> selectedSites = {};
      
      apiSites.forEach((key, value) {
        if (selectedSources.contains(key)) {
          selectedSites[key] = value;
        }
      });
      
      return selectedSites;
    } else {
      // 如果没有保存的设置，默认使用所有源
      return apiSites;
    }
  }

  // 聚合搜索（只使用选中的数据源）
  static Future<List<MediaDetail>> aggregatedSearchWithSelectedSources(String query) async {
    try {
      // 获取选中的数据源
      final selectedSites = await getSelectedApiSites();
      
      // 创建选中API的请求
      List<Future<List<MediaDetail>>> futures = [];

      selectedSites.forEach((key, value) {
        futures.add(_searchByAPI(key, value['api']!, value['name']!, query));
      });

      // 并发执行所有请求
      final results = await Future.wait(futures, eagerError: false);

      // 合并结果
      List<MediaDetail> allResults = [];
      for (var result in results) {
        allResults.addAll(result);
      }

      return allResults;
    } catch (e) {
      return [];
    }
  }

  // 流式聚合搜索（只使用选中的数据源）- 每个API返回结果后立即回调
  static Future<void> streamAggregatedSearchWithSelectedSources(
    String query, 
    Function(List<MediaDetail>) onResultsReceived,
    Function() onSearchCompleted,
  ) async {
    try {
      // 获取选中的数据源
      final selectedSites = await getSelectedApiSites();
      
      // 创建计数器跟踪完成的请求数量
      int completedRequests = 0;
      final totalRequests = selectedSites.length;

      // 为每个API创建单独的请求
      selectedSites.forEach((key, value) {
        _searchByAPI(key, value['api']!, value['name']!, query).then((results) {
          // 当一个API返回结果时，立即回调
          onResultsReceived(results);
          
          // 增加完成计数
          completedRequests++;
          
          // 如果所有请求都完成了，调用完成回调
          if (completedRequests == totalRequests) {
            onSearchCompleted();
          }
        }).catchError((error) {
          // 即使某个请求出错，也要增加计数器，确保能触发完成回调
          completedRequests++;
          if (completedRequests == totalRequests) {
            onSearchCompleted();
          }
        });
      });
    } catch (e) {
      // 如果获取选中数据源时出错，直接调用完成回调
      onSearchCompleted();
    }
  }

  // 按API搜索
  static Future<List<MediaDetail>> _searchByAPI(
      String apiCode, String apiUrl, String apiName, String query) async {
    try {
      final Dio apiDio = Dio(BaseOptions(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final searchUrl =
          '$apiUrl?ac=videolist&wd=${Uri.encodeQueryComponent(query)}';
      print('正在搜索 $apiName: $searchUrl');
      final response = await apiDio.get(searchUrl);

      print('收到 $apiName 的响应，状态码: ${response.statusCode}');
      print('$apiName 返回的原始数据类型: ${response.data.runtimeType}');
      if (response.data is Map) {
        print('$apiName 返回的数据键: ${(response.data as Map).keys.toList()}');
      } else if (response.data is List) {
        print('$apiName 返回的列表长度: ${(response.data as List).length}');
      } else {
        print('$apiName 返回的数据: ${response.data}');
      }

      if (response.statusCode == 200) {
        dynamic data = response.data;
        
        // 如果返回的是字符串，则尝试解析为JSON
        if (data is String) {
          print('$apiName 返回的是字符串，尝试解析为JSON');
          try {
            data = json.decode(data);
            print('$apiName JSON解析成功');
          } catch (e) {
            print('$apiName JSON解析失败: $e');
            return [];
          }
        }
        
        if (data is Map) {
          print('$apiName 返回的数据键: ${data.keys.toList()}');
          
          if (data.containsKey('list') && data['list'] is List) {
            final List<dynamic> list = data['list'];
            print('$apiName 找到 ${list.length} 个结果');
            return list.map((item) {
              return _mapApiDataToMediaDetail(item, apiName, apiCode, apiUrl);
            }).toList();
          } else {
            print('$apiName 数据格式不正确或没有list字段');
            print('$apiName 数据字段: ${data.keys.toList()}');
          }
        } else {
          print('$apiName 返回的数据不是Map类型: ${data.runtimeType}');
        }
      }

      return [];
    } catch (e, stackTrace) {
      print('搜索 $apiName 时出错: $e');
      print('错误堆栈: $stackTrace');
      // 出错时返回空列表而不是抛出异常
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
      return ''; // 确保返回空字符串而不是null
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
    return url ?? '';
  }
}
