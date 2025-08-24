import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // 添加对widgets库的导入
import 'package:flutter/services.dart';
import 'package:vision_x_flutter/components/video_player.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/history_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/theme/theme_provider.dart';
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
  Key _videoPlayerKey = UniqueKey(); // 移除late，直接初始化
  int? _videoDuration; // 添加视频总时长变量

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
        .addHistory(widget.media, widget.episode, widget.startPosition, _videoDuration);
    _hasRecordedInitialHistory = true;
  }

  // 更新观看进度
  void _updateProgress(int progress) {
    setState(() {
      _currentProgress = progress;
    });
    // 更新历史记录中的进度
    HistoryService()
        .updateHistoryProgress(widget.media, widget.episode, progress, _videoDuration);
  }

  // 处理播放完成事件
  void _onPlaybackCompleted() {
    // 自动播放下一集
    _playNextEpisode();
  }

  // 添加获取视频时长的回调函数
  void _onVideoDurationReceived(int duration) {
    if (_videoDuration == null) {
      setState(() {
        _videoDuration = duration;
      });
      // 更新历史记录包含视频总时长
      if (_hasRecordedInitialHistory) {
        HistoryService().updateHistoryProgress(
          widget.media, widget.episode, _currentProgress, _videoDuration);
      }
    }
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
          _currentProgress = 0;
        });
        
        HistoryService().addHistory(widget.media, widget.episode, 0, _videoDuration);
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
    final theme = Theme.of(context);
    final themeProvider = ThemeProvider.of(context);
    
    // 检查是否是短剧类型（包含"短剧"关键词）
    bool isShortDrama = (widget.media.category != null && 
        (widget.media.category!.contains('短剧') || widget.media.category == '短剧')) ||
        (widget.media.type != null && 
        (widget.media.type!.contains('短剧') || widget.media.type == '短剧'));
    
    if (isShortDrama) {
      // 竖屏抖音风格播放器 - 全屏显示
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _buildShortDramaPlayer(),
      );
    } else {
      // 普通横屏播放器
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: null, // 移除AppBar
        body: Column(
          children: [
            // 视频播放器部分
            SafeArea(
              child: AspectRatio(
                aspectRatio: 16 / 9, // 设置标准16:9宽高比
                child: Container(
                  color: Colors.black, // 设置背景颜色为黑色
                  child: Stack(
                    children: [
                      CustomVideoPlayer(
                        key: _videoPlayerKey, // 添加key参数
                        media: widget.media,
                        episode: widget.episode,
                        onProgressUpdate: _updateProgress, // 传递进度更新回调
                        onPlaybackCompleted: _onPlaybackCompleted, // 传递播放完成回调
                        onVideoDurationReceived: _onVideoDurationReceived, // 传递视频时长回调
                        startPosition: _currentProgress, // 传递当前位置
                      ),
                      // 顶部返回按钮 (始终显示)
                      Positioned(
                        top: 10,
                        left: 20,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: theme.iconTheme.color, size: 24),
                          onPressed: _onBackButtonPressed,
                        ),
                      ),
                    ],
                  ),
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
                      color: theme.scaffoldBackgroundColor,
                      child: TabBar(
                        tabs: _tabs,
                        indicatorColor: theme.colorScheme.primary,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                        onTap: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: theme.scaffoldBackgroundColor,
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
          final theme = Theme.of(context);
          final episode = currentSource.episodes[index];
          return Container(
            color: Colors.black, // 设置背景颜色为黑色
            child: Stack(
              children: [
                // 视频播放器部分（全屏）
                SizedBox.expand(
                  child: Stack(
                    children: [
                      CustomVideoPlayer(
                        key: ValueKey(episode.url), // 为每个episode使用独立的key，确保播放器正确重建
                        media: widget.media,
                        episode: episode,
                        onProgressUpdate: _updateProgress,
                        onPlaybackCompleted: _onPlaybackCompleted,
                        startPosition: index == _currentEpisodeIndex ? _currentProgress : 0,
                      ),
                      // 顶部返回按钮 (始终显示)
                      Positioned(
                        top: 50,
                        left: 20,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: theme.iconTheme.color, size: 28),
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withOpacity(0.87),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      
                        const SizedBox(height: 8),
                      
                        // 视频描述
                        if (widget.media.description != null)
                          Text(
                            widget.media.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.media.name ?? '未知影片',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.media.year != null || widget.media.area != null)
            Text(
              '${widget.media.year ?? ''} ${widget.media.area ?? ''}',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          const SizedBox(height: 10),
          if (widget.media.actors != null)
            Text(
              '主演: ${widget.media.actors}',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          const SizedBox(height: 10),
          if (widget.media.director != null)
            Text(
              '导演: ${widget.media.director}',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          const SizedBox(height: 10),
          if (widget.media.description != null)
            Text(
              widget.media.description!,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          // 显示起始播放位置信息
          if (_currentProgress > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '当前播放位置: ${Duration(seconds: _currentProgress).toString().split('.').first}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    
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
                      backgroundColor: isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary.withOpacity(0.3),
                      foregroundColor: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
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
    final theme = Theme.of(context);
    
    return Center(
      child: Text(
        '评论功能正在开发中...',
        style: TextStyle(
          fontSize: 16,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();

    if (_hasRecordedInitialHistory) {
      HistoryService().updateHistoryProgress(
          widget.media, widget.episode, _currentProgress, _videoDuration);
    }

    super.dispose();
  }
}