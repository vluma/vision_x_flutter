import 'package:flutter/material.dart';
import 'package:vision_x_flutter/components/video_player.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/history_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final MediaDetail media;
  late Episode episode;
  final int startPosition; // 添加起始位置参数

  VideoPlayerPage({
    super.key,
    required this.media,
    required Episode episode,
    this.startPosition = 0, // 默认从头开始
  }) : episode = episode;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  int _currentIndex = 0;
  int _currentProgress = 0;
  bool _hasRecordedInitialHistory = false;
  int _currentEpisodeIndex = 0;

  final List<Widget> _tabs = const [
    Tab(text: '简介'),
    Tab(text: '评论'),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化当前进度为起始位置
    _currentProgress = widget.startPosition;
    _currentEpisodeIndex = _getCurrentEpisodeIndex();
    // 添加延时确保页面完全加载后再记录初始历史
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordInitialHistory();
    });
  }

  int _getCurrentEpisodeIndex() {
    try {
      final currentSource = widget.media.surces.firstWhere(
        (source) => source.name == widget.media.sourceName,
        orElse: () => widget.media.surces.first,
      );
      return currentSource.episodes.indexWhere(
        (episode) => episode.url == widget.episode.url,
      );
    } catch (e) {
      return 0;
    }
  }

  // 记录初始观看历史
  void _recordInitialHistory() async {
    if (_hasRecordedInitialHistory) return;

    await HistoryService()
        .addHistory(widget.media, widget.episode, widget.startPosition);
    _hasRecordedInitialHistory = true;
  }

  // 更新观看进度
  void _updateProgress(int progress) {
    setState(() {
      _currentProgress = progress;
    });
    // 更新历史记录中的进度
    HistoryService()
        .updateHistoryProgress(widget.media, widget.episode, progress);
  }

  // 切换剧集
  void _changeEpisode(int index) {
    try {
      final currentSource = widget.media.surces.firstWhere(
        (source) => source.name == widget.media.sourceName,
        orElse: () => widget.media.surces.first,
      );
      
      if (index >= 0 && index < currentSource.episodes.length) {
        setState(() {
          _currentEpisodeIndex = index;
          widget.episode = currentSource.episodes[index];
          _currentProgress = 0; // 重置进度
        });
        
        // 重新加载播放器
        setState(() {
          // 通过重建播放器来切换剧集
        });
        
        // 记录新剧集的历史
        HistoryService().addHistory(widget.media, widget.episode, 0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法切换到该集数')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: null, // 移除AppBar
      body: Column(
        children: [
          // 视频播放器部分
          SafeArea(
            child: AspectRatio(
              aspectRatio: 16 / 9, // 设置标准16:9宽高比
              child: Stack(
                children: [
                  CustomVideoPlayer(
                    media: widget.media,
                    episode: widget.episode,
                    onProgressUpdate: _updateProgress, // 传递进度更新回调
                    startPosition: _currentProgress, // 传递当前位置
                  ),
                  // 顶部返回按钮 (始终显示)
                  Positioned(
                    top: 10,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                      onPressed: _onBackButtonPressed,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 导航标签部分
          Expanded(
            child: DefaultTabController(
              length: _tabs.length,
              child: Column(
                children: [
                  Container(
                    color: Colors.black,
                    child: TabBar(
                      tabs: _tabs,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      onTap: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: TabBarView(
                        children: [
                          // 简介内容
                          _buildDescriptionTab(),
                          // 评论内容
                          _buildCommentsTab(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 处理返回按钮按下事件
  void _onBackButtonPressed() {
    // 在返回前更新最终进度
    if (_hasRecordedInitialHistory) {
      HistoryService().updateHistoryProgress(
          widget.media, widget.episode, _currentProgress);
    }
    Navigator.of(context).pop();
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.media.name ?? '未知影片',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.media.year != null || widget.media.area != null)
            Text(
              '${widget.media.year ?? ''} ${widget.media.area ?? ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 10),
          if (widget.media.actors != null)
            Text(
              '主演: ${widget.media.actors}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 10),
          if (widget.media.director != null)
            Text(
              '导演: ${widget.media.director}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 10),
          if (widget.media.description != null)
            Text(
              widget.media.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          // 显示起始播放位置信息
          if (_currentProgress > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '当前播放位置: ${Duration(seconds: _currentProgress).toString().split('.').first}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ),
          // 剧集选择器
          if (widget.media.surces.isNotEmpty) _buildEpisodeSelector(),
        ],
      ),
    );
  }

  // 构建剧集选择器
  Widget _buildEpisodeSelector() {
    try {
      final currentSource = widget.media.surces.firstWhere(
        (source) => source.name == widget.media.sourceName,
        orElse: () => widget.media.surces.first,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              '剧集选择',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: currentSource.episodes.length,
              itemBuilder: (context, index) {
                final episode = currentSource.episodes[index];
                final isSelected = index == _currentEpisodeIndex;
                
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _changeEpisode(index),
                    child: Text(
                      episode.title,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCommentsTab() {
    return const Center(
      child: Text(
        '评论功能正在开发中...',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 页面销毁时更新最终进度
    if (_hasRecordedInitialHistory) {
      HistoryService().updateHistoryProgress(
          widget.media, widget.episode, _currentProgress);
    }
    super.dispose();
  }
}