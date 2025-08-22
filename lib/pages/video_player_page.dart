import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vision_x_flutter/components/video_player.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/history_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async'; // 添加dart:async包用于Future

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
  late PageController _pageController;

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
    // 初始化PageController并跳转到当前剧集
    _pageController = PageController(initialPage: _currentEpisodeIndex);
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

  // 处理播放完成事件
  void _onPlaybackCompleted() {
    // 自动播放下一集
    _playNextEpisode();
  }

  // 播放下一集
  void _playNextEpisode() {
    try {
      final currentSource = widget.media.surces.firstWhere(
        (source) => source.name == widget.media.sourceName,
        orElse: () => widget.media.surces.first,
      );
      
      // 检查是否有下一集
      if (_currentEpisodeIndex + 1 < currentSource.episodes.length) {
        // 根据是否是短剧采用不同的切换方式
        bool isShortDrama = widget.media.category != null && 
            (widget.media.category!.contains('短剧') || widget.media.category == '短剧');
        
        if (isShortDrama) {
          // 短剧模式：通过PageView切换到下一集
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // 普通模式：直接切换到下一集
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _changeEpisode(_currentEpisodeIndex + 1);
            }
          });
        }
      } else {
        // 没有下一集了
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已经是最后一集了')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法播放下一集')),
        );
      }
    }
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
    // 检查是否是短剧类型（包含"短剧"关键词）
    bool isShortDrama = widget.media.category != null && 
        (widget.media.category!.contains('短剧') || widget.media.category == '短剧');
    
    if (isShortDrama) {
      // 竖屏抖音风格播放器 - 全屏显示
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildShortDramaPlayer(),
      );
    } else {
      // 普通横屏播放器
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
                      onPlaybackCompleted: _onPlaybackCompleted, // 传递播放完成回调
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
  }

  Widget _buildShortDramaPlayer() {
    // 设置全屏模式
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
    
    final currentSource = widget.media.surces.firstWhere(
      (source) => source.name == widget.media.sourceName,
      orElse: () => widget.media.surces.first,
    );
    
    return WillPopScope(
      onWillPop: _onShortDramaWillPop,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: currentSource.episodes.length,
        onPageChanged: (index) {
          _changeEpisode(index);
        },
        itemBuilder: (context, index) {
          final episode = currentSource.episodes[index];
          return Stack(
            children: [
              // 视频播放器部分（全屏）
              SizedBox.expand(
                child: Stack(
                  children: [
                    CustomVideoPlayer(
                      media: widget.media,
                      episode: episode,
                      onProgressUpdate: _updateProgress, // 传递进度更新回调
                      onPlaybackCompleted: _onPlaybackCompleted, // 传递播放完成回调
                      startPosition: index == _currentEpisodeIndex ? _currentProgress : 0, // 传递当前位置
                    ),
                    // 顶部返回按钮 (始终显示)
                    Positioned(
                      top: 50,
                      left: 20,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 28),
                        onPressed: _onBackButtonPressed,
                      ),
                    ),
                  ],
                ),
              ),
            
              // 底部信息部分（类似抖音）
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 视频标题
                      Text(
                        '${widget.media.name ?? '未知影片'} - ${episode.title}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    
                      const SizedBox(height: 8),
                    
                      // 视频描述
                      if (widget.media.description != null)
                        Text(
                          widget.media.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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

  // 处理短剧模式下的页面返回事件
  Future<bool> _onShortDramaWillPop() async {
    // 在返回前更新最终进度
    if (_hasRecordedInitialHistory) {
      HistoryService().updateHistoryProgress(
          widget.media, widget.episode, _currentProgress);
    }
    return true;
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
    // 恢复系统UI模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();

    // 页面销毁时无条件更新最终进度
    HistoryService().updateHistoryProgress(widget.media, widget.episode, _currentProgress);

    super.dispose();
  }
}