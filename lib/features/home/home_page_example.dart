import 'package:flutter/material.dart';
import 'package:vision_x_flutter/features/home/widgets/video_grid.dart';
import 'package:vision_x_flutter/data/models/douban_movie.dart';

/// Home页面示例，展示如何使用带滚动控制的VideoGrid
class HomePageExample extends StatefulWidget {
  const HomePageExample({super.key});

  @override
  State<HomePageExample> createState() => _HomePageExampleState();
}

class _HomePageExampleState extends State<HomePageExample> {
  List<DoubanMovie> _movies = [];
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟数据加载
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _movies = _generateSampleMovies();
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    // 模拟刷新数据
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _movies = _generateSampleMovies();
    });
  }

  void _onLoadMore() {
    if (_isLoading || !_hasMoreData) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // 模拟加载更多数据
    Future.delayed(const Duration(seconds: 2)).then((_) {
      setState(() {
        _movies.addAll(_generateSampleMovies());
        _isLoading = false;
        _hasMoreData = _movies.length < 20; // 模拟有限数据
      });
    });
  }

  void _onItemTap(DoubanMovie movie) {
    // 处理项目点击
    print('Item tapped: ${movie.title}');
  }

  List<DoubanMovie> _generateSampleMovies() {
    return List.generate(10, (index) => DoubanMovie(
      id: index.toString(),
      title: '电影 ${index + 1}',
      cover: 'https://example.com/cover$index.jpg',
      rate: (8.0 + index * 0.1).toStringAsFixed(1),
      url: 'https://example.com/movie$index',
      isNew: index % 3 == 0,
      playable: true,
      episodesInfo: '全${index + 10}集',
      coverX: 200,
      coverY: 300,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // 排序数据 - VideoGrid会自动检测并滚动到顶部
              setState(() {
                _movies.sort((a, b) => b.rate.compareTo(a.rate));
              });
            },
          ),
        ],
      ),
      body: VideoGrid(
        movies: _movies,
        hasMoreData: _hasMoreData,
        isLoading: _isLoading,
        onRefresh: _onRefresh,
        onLoadMore: _onLoadMore,
        onItemTap: _onItemTap,
      ),
    );
  }
}  