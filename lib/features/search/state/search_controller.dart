import 'package:flutter/material.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:vision_x_flutter/services/content_filter_service.dart';

/// 搜索状态管理类
class SearchPageController extends ChangeNotifier {
  List<MediaDetail> _mediaResults = [];
  List<MediaDetail> _filteredResults = [];
  List<MediaDetail> _aggregatedResults = [];
  String _selectedCategory = '全部';
  bool _isLoading = false;
  bool _hasSearched = false;
  String _lastSearchQuery = '';
  int _searchId = 0;

  List<MediaDetail> get mediaResults => _mediaResults;
  List<MediaDetail> get filteredResults => _filteredResults;
  List<MediaDetail> get aggregatedResults => _aggregatedResults;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String get lastSearchQuery => _lastSearchQuery;

  /// 检查控制器是否已被销毁
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// 安全地调用 notifyListeners
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// 执行聚合搜索
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty || _disposed) {
      return;
    }

    final int currentSearchId = ++_searchId;
    _isLoading = true;
    _hasSearched = true;
    _selectedCategory = '全部';
    _safeNotifyListeners();

    try {
      // 使用流式搜索方法，每个API返回结果后立即显示
      List<MediaDetail> tempResults = [];

      await ApiService.streamAggregatedSearchWithSelectedSources(
        query.trim(),
        (List<MediaDetail> results) async {
          // 当收到部分结果时更新UI
          if (currentSearchId == _searchId && !_disposed) {
            tempResults.addAll(results);

            // 应用内容过滤
            final filteredResults = await ContentFilterService.filterYellowContent(
                tempResults,
                (media) =>
                    '${media.name ?? ''} ${media.subtitle ?? ''} ${media.type ?? ''} ${media.category ?? ''} ${media.remarks ?? ''}');

            _mediaResults = List.from(filteredResults);
            _filteredResults = List.from(filteredResults);
            _aggregatedResults = _aggregateMedia(filteredResults);
            _safeNotifyListeners();
          }
        },
        () async {
          // 当所有搜索完成时
          if (currentSearchId == _searchId && !_disposed) {
            _isLoading = false;
            _lastSearchQuery = query.trim();
            _safeNotifyListeners();

            // 更新分类
            _updateCategories();
          }
        },
      );
    } catch (e) {
      if (currentSearchId == _searchId && !_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  /// 聚合结果，将名称、年份、分类相同的媒体聚合在一起
  List<MediaDetail> _aggregateMedia(List<MediaDetail> mediaList) {
    final Map<String, MediaDetail> aggregatedMap = {};

    for (var media in mediaList) {
      // 创建唯一标识符，基于名称、年份和分类
      final key = '${media.name ?? ''}_${media.year ?? ''}_${media.type ?? ''}';

      if (aggregatedMap.containsKey(key)) {
        // 如果已存在，合并来源和剧集信息
        final existingMedia = aggregatedMap[key]!;
        existingMedia.surces.addAll(media.surces);
      } else {
        // 如果不存在，添加新条目
        aggregatedMap[key] = MediaDetail(
          id: media.id,
          name: media.name,
          subtitle: media.subtitle,
          type: media.type,
          category: media.category,
          year: media.year,
          area: media.area,
          language: media.language,
          duration: media.duration,
          state: media.state,
          remarks: media.remarks,
          version: media.version,
          actors: media.actors,
          director: media.director,
          writer: media.writer,
          description: media.description,
          content: media.content,
          poster: media.poster,
          posterThumb: media.posterThumb,
          posterSlide: media.posterSlide,
          posterScreenshot: media.posterScreenshot,
          playUrl: media.playUrl,
          playFrom: media.playFrom,
          playServer: media.playServer,
          playNote: media.playNote,
          score: media.score,
          scoreAll: media.scoreAll,
          scoreNum: media.scoreNum,
          doubanScore: media.doubanScore,
          doubanId: media.doubanId,
          hits: media.hits,
          hitsDay: media.hitsDay,
          hitsWeek: media.hitsWeek,
          hitsMonth: media.hitsMonth,
          up: media.up,
          down: media.down,
          time: media.time,
          timeAdd: media.timeAdd,
          letter: media.letter,
          color: media.color,
          tag: media.tag,
          serial: media.serial,
          tv: media.tv,
          weekday: media.weekday,
          pubdate: media.pubdate,
          total: media.total,
          isEnd: media.isEnd,
          trysee: media.trysee,
          sourceName: media.sourceName,
          sourceCode: media.sourceCode,
          apiUrl: media.apiUrl,
          hasCover: media.hasCover,
          sourceInfo: media.sourceInfo,
          surces: List.from(media.surces),
        );
      }
    }

    return aggregatedMap.values.toList();
  }

  /// 更新分类列表并返回排序后的分类
  List<String> _updateCategories() {
    Set<String> categories = <String>{};
    for (var media in _mediaResults) {
      if (media.type != null && media.type!.isNotEmpty) {
        categories.add(media.type!);
      }
    }

    // 排序分类
    final sortedCategories = ['全部', ...categories.toList()..sort()];

    // 如果当前选中的分类不在新分类列表中，则重置为"全部"
    if (_selectedCategory != '全部' && !categories.contains(_selectedCategory)) {
      _selectedCategory = '全部';
      _filteredResults = List.from(_mediaResults);
      _aggregatedResults = _aggregateMedia(_filteredResults);
      _safeNotifyListeners();
    }

    return sortedCategories;
  }

  /// 获取排序后的分类列表（供UI使用）
  List<String> getSortedCategories() {
    Set<String> categories = <String>{};
    for (var media in _mediaResults) {
      if (media.type != null && media.type!.isNotEmpty) {
        categories.add(media.type!);
      }
    }
    return ['全部', ...categories.toList()..sort()];
  }

  /// 按来源分组结果
  Map<String, List<MediaDetail>> getGroupedResults() {
    Map<String, List<MediaDetail>> groupedResults = {};
    for (var media in _filteredResults) {
      final sourceName = media.sourceName;
      if (!groupedResults.containsKey(sourceName)) {
        groupedResults[sourceName] = [];
      }
      groupedResults[sourceName]!.add(media);
    }
    return groupedResults;
  }

  /// 筛选结果
  Future<void> filterResults(String category) async {
    if (_disposed) return;
    
    _selectedCategory = category;
    List<MediaDetail> categoryResults;

    if (category == '全部') {
      categoryResults = List.from(_mediaResults);
    } else {
      categoryResults =
          _mediaResults.where((media) => media.type == category).toList();
    }

    // 应用内容过滤
    _filteredResults = await ContentFilterService.filterYellowContent(
        categoryResults,
        (media) =>
            '${media.name ?? ''} ${media.subtitle ?? ''} ${media.type ?? ''} ${media.category ?? ''} ${media.remarks ?? ''}');

    _aggregatedResults = _aggregateMedia(_filteredResults);
    _safeNotifyListeners();
  }

  /// 清除搜索结果
  void clearResults() {
    if (_disposed) return;
    
    _mediaResults.clear();
    _filteredResults.clear();
    _aggregatedResults.clear();
    _selectedCategory = '全部';
    _hasSearched = false;
    _lastSearchQuery = '';
    _safeNotifyListeners();
  }
}