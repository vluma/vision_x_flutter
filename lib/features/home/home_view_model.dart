import 'package:flutter/material.dart';
import 'package:vision_x_flutter/data/models/douban_movie.dart';
import 'package:vision_x_flutter/services/api_service.dart';

/// 首页状态管理类，负责处理业务逻辑和数据状态
class HomeViewModel extends ChangeNotifier {
  // 当前选中的视频分类
  String _selectedCategory = '电影';
  String get selectedCategory => _selectedCategory;

  // 当前选中的视频源
  String _selectedSource = '热门';
  String get selectedSource => _selectedSource;

  // 当前选中的排序方式
  String _selectedSort = 'recommend';
  String get selectedSort => _selectedSort;

  // 视频数据列表
  List<DoubanMovie> _movies = [];
  List<DoubanMovie> get movies => _movies;

  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _tagsLoading = false;
  bool get tagsLoading => _tagsLoading;

  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  // 分页参数
  int _currentPageStart = 0;
  final int _pageLimit = 20;



  // 视频源列表 (将根据选中的分类动态变化)
  List<String> _sources = ApiService.defaultMovieTags;
  List<String> get sources => _sources;

  // 防抖计时器
  DateTime? _lastLoadTime;

  HomeViewModel() {
    _initialize();
  }

  /// 初始化数据
  Future<void> _initialize() async {
    await _loadTags();
    await _loadMovies();
  }

  /// 加载标签数据
  Future<void> _loadTags() async {
    if (_tagsLoading) return;

    setState(() => _tagsLoading = true);

    try {
      List<String> tags;
      if (_selectedCategory == '电影') {
        tags = await ApiService.getMovieTags();
      } else {
        tags = await ApiService.getTvTags();
      }

      setState(() {
        _sources = tags;
        if (!_sources.contains(_selectedSource)) {
          _selectedSource = _sources.first;
        }
        _tagsLoading = false;
      });

      // 重新加载电影数据
      await _loadMovies();
    } catch (e) {
      // 使用默认标签
      setState(() {
        _sources = _selectedCategory == '电影'
            ? ApiService.defaultMovieTags
            : ApiService.defaultTvTags;
        _tagsLoading = false;
      });

      // 重新加载电影数据
      await _loadMovies();
    }
  }

  /// 加载电影数据（默认从第一页开始）
  Future<void> _loadMovies() async {
    // 防抖处理：避免频繁请求
    final now = DateTime.now();
    if (_lastLoadTime != null && 
        now.difference(_lastLoadTime!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastLoadTime = now;

    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final movies = await ApiService.getMovies(
        type: _selectedCategory == '电影' ? 'movie' : 'tv',
        tag: _selectedSource,
        sort: _selectedSort,
        pageStart: 0,
        pageLimit: _pageLimit,
      );

      setState(() {
        _movies = movies;
        _currentPageStart = 0;
        _hasMoreData = movies.length == _pageLimit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      rethrow;
    }
  }

  /// 加载更多电影数据
  Future<void> loadMoreMovies() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final nextPageStart = _currentPageStart + _pageLimit;
      final movies = await ApiService.getMovies(
        type: _selectedCategory == '电影' ? 'movie' : 'tv',
        tag: _selectedSource,
        sort: _selectedSort,
        pageStart: nextPageStart,
        pageLimit: _pageLimit,
      );

      setState(() {
        _movies.addAll(movies);
        _currentPageStart = nextPageStart;
        _hasMoreData = movies.length == _pageLimit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      rethrow;
    }
  }

  /// 下拉刷新
  Future<void> refresh() async {
    await _loadTags();
    await _loadMovies();
  }

  /// 切换分类
  void switchCategory(String category) {
    if (_selectedCategory == category) return;

    setState(() {
      _selectedCategory = category;
      _selectedSource = '热门';
    });
    _loadTags();
  }

  /// 切换排序方式
  void switchSort(String sort) {
    if (_selectedSort == sort) return;

    setState(() => _selectedSort = sort);
    _loadMovies();
  }

  /// 切换视频源
  void switchSource(String source) {
    if (_selectedSource == source) return;

    setState(() => _selectedSource = source);
    _loadMovies();
  }

  /// 辅助方法：更新状态并通知监听器
  void setState(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}