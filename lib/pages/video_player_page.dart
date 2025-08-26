import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vision_x_flutter/components/video_player.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/history_service.dart';
import 'package:vision_x_flutter/components/video_swipe_back_gesture.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'dart:async';

/// 视频播放页面
/// 支持竖屏短剧模式和横屏传统模式
class VideoPlayerPage extends StatefulWidget {
  final MediaDetail media;
  final Episode episode;
  final int startPosition;

  const VideoPlayerPage({
    super.key,
    required this.media,
    required this.episode,
    this.startPosition = 0,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // MARK: - 常量定义
  static const Duration _pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration _episodeChangeDelay = Duration(milliseconds: 500);
  static const Duration _shortDramaEpisodeChangeDelay =
      Duration(milliseconds: 100);
  static const double _videoAspectRatio = 16 / 9;
  static const String _shortDramaCategory = '短剧';
  static const String _lastEpisodeMessage = '已经是最后一集了';
  static const String _firstEpisodeMessage = '已经是第一集了';
  static const String _playNextEpisodeError = '无法播放下一集';
  static const String _playPrevEpisodeError = '无法播放上一集';
  static const String _switchEpisodeError = '无法切换到该集数';

  // MARK: - 状态变量
  late Episode _episode;
  int _currentProgress = 0;
  int _currentEpisodeIndex = 0;
  int? _videoDuration;
  bool _hasRecordedInitialHistory = false;

  // MARK: - 控制器
  late PageController _pageController;
  Key _videoPlayerKey = UniqueKey();

  // MARK: - UI 配置
  static const List<Widget> _tabs = [
    Tab(text: '简介'),
    Tab(text: '评论'),
  ];

  // MARK: - 计算属性
  bool get _isShortDramaMode => _checkShortDramaMode();
  Source get _currentSource => _getCurrentSource();
  int get _totalEpisodes => _currentSource.episodes.length;
  bool get _canPlayNext => _currentEpisodeIndex < _totalEpisodes - 1;
  bool get _canPlayPrev => _currentEpisodeIndex > 0;

  // MARK: - 生命周期方法
  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  // MARK: - 初始化方法
  void _initializePage() {
    _episode = widget.episode;
    _currentProgress = widget.startPosition;
    _currentEpisodeIndex = _getCurrentEpisodeIndex();
    _pageController = PageController(initialPage: _currentEpisodeIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordInitialHistory();
    });
  }

  void _cleanup() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    _updateFinalProgress();
  }

  // MARK: - 数据获取方法
  int _getCurrentEpisodeIndex() {
    try {
      final currentSource = _getCurrentSource();
      return currentSource.episodes.indexWhere(
        (episode) => episode.url == _episode.url,
      );
    } catch (e) {
      return 0;
    }
  }

  Source _getCurrentSource() {
    return widget.media.surces.firstWhere(
      (source) => source.name == widget.media.sourceName,
      orElse: () => widget.media.surces.first,
    );
  }

  bool _checkShortDramaMode() {
    final category = widget.media.category;
    final type = widget.media.type;

    return (category != null &&
            (category.contains(_shortDramaCategory) ||
                category == _shortDramaCategory)) ||
        (type != null &&
            (type.contains(_shortDramaCategory) ||
                type == _shortDramaCategory));
  }

  // MARK: - 历史记录管理
  void _recordInitialHistory() async {
    if (_hasRecordedInitialHistory) return;

    await HistoryService().addHistory(
        widget.media, _episode, widget.startPosition, _videoDuration);
    _hasRecordedInitialHistory = true;
  }

  void _updateProgress(int progress) {
    if (!mounted) return;

    setState(() {
      _currentProgress = progress;
    });

    _updateHistoryProgress(progress);
  }

  void _updateHistoryProgress(int progress) {
    try {
      HistoryService().updateHistoryProgress(
          widget.media, _episode, progress, _videoDuration);
    } catch (e) {
      // 历史记录更新失败，静默处理
    }
  }

  void _updateFinalProgress() {
    if (_hasRecordedInitialHistory) {
      HistoryService().updateHistoryProgress(
          widget.media, _episode, _currentProgress, _videoDuration);
    }
  }

  // MARK: - 播放控制回调
  void _onPlaybackCompleted() {
    _playNextEpisode();
  }

  void _onVideoDurationReceived(int duration) {
    if (_videoDuration == null && mounted) {
      setState(() {
        _videoDuration = duration;
      });
      if (_hasRecordedInitialHistory) {
        _updateHistoryProgress(_currentProgress);
      }
    }
  }

  void _onPreloadNextEpisode() {
    try {
      final currentSource = _getCurrentSource();
      if (_currentEpisodeIndex + 1 < currentSource.episodes.length) {
        // TODO: 实现预加载逻辑
      }
    } catch (e) {
      // 预加载失败，静默处理
    }
  }

  // MARK: - 剧集切换方法
  void _playNextEpisode() {
    if (!_canPlayNext) {
      _showMessage(_lastEpisodeMessage);
      return;
    }

    try {
      if (_isShortDramaMode) {
        _switchToNextEpisodeInShortDramaMode();
      } else {
        _switchToNextEpisodeInNormalMode();
      }
    } catch (e) {
      _showMessage(_playNextEpisodeError);
    }
  }

  void _playPrevEpisode() {
    if (!_canPlayPrev) {
      _showMessage(_firstEpisodeMessage);
      return;
    }

    try {
      if (_isShortDramaMode) {
        _switchToPrevEpisodeInShortDramaMode();
      } else {
        _changeEpisode(_currentEpisodeIndex - 1);
      }
    } catch (e) {
      _showMessage(_playPrevEpisodeError);
    }
  }

  void _switchToNextEpisodeInShortDramaMode() {
    try {
      _pageController.jumpToPage(_currentEpisodeIndex + 1);
    } catch (e) {
      _pageController.animateToPage(
        _currentEpisodeIndex + 1,
        duration: _pageTransitionDuration,
        curve: Curves.easeInOut,
      );
    }
    // 移除延迟调用，让 PageView 的 onPageChanged 来处理状态更新
  }

  void _switchToPrevEpisodeInShortDramaMode() {
    try {
      _pageController.jumpToPage(_currentEpisodeIndex - 1);
    } catch (e) {
      _pageController.animateToPage(
        _currentEpisodeIndex - 1,
        duration: _pageTransitionDuration,
        curve: Curves.easeInOut,
      );
    }
    // 移除延迟调用，让 PageView 的 onPageChanged 来处理状态更新
  }

  void _switchToNextEpisodeInNormalMode() {
    Future.delayed(_episodeChangeDelay, () {
      if (mounted) {
        _changeEpisode(_currentEpisodeIndex + 1);
      }
    });
  }

  void _changeEpisode(int index) {
    if (!mounted) return;

    try {
      if (index < 0 || index >= _totalEpisodes) {
        return;
      }

      // 避免重复切换
      if (index == _currentEpisodeIndex) {
        return;
      }

      setState(() {
        _currentEpisodeIndex = index;
        _episode = _currentSource.episodes[index];
        _currentProgress = 0;
      });

      // 在普通模式下，需要重新构建视频播放器
      if (!_isShortDramaMode) {
        // 生成新的key来强制重建视频播放器
        _videoPlayerKey = UniqueKey();
      }

      _recordEpisodeHistory();
    } catch (e) {
      _showMessage(_switchEpisodeError);
    }
  }

  Future<void> _recordEpisodeHistory() async {
    try {
      await HistoryService()
          .addHistory(widget.media, _episode, 0, _videoDuration);
    } catch (e) {
      // 历史记录失败，静默处理
    }
  }

  // MARK: - 导航方法
  void _onBackButtonPressed() {
    _updateFinalProgress();
    // 直接刷新历史数据
    HistoryService().refreshData();
    Navigator.of(context).pop();
  }

  Future<bool> _onShortDramaWillPop() async {
    _updateFinalProgress();
    // 直接刷新历史数据
    HistoryService().refreshData();
    return true;
  }

  // MARK: - 工具方法
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // MARK: - 构建方法
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _isShortDramaMode
        ? _buildShortDramaLayout(theme)
        : _buildTraditionalLayout(theme);
  }

  Widget _buildShortDramaLayout(ThemeData theme) {
    return VideoSwipeBackGesture(
      onBackPressed: _onBackButtonPressed,
      enableSwipeBack: true,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _buildShortDramaPlayer(),
      ),
    );
  }

  Widget _buildTraditionalLayout(ThemeData theme) {
    return VideoSwipeBackGesture(
      onBackPressed: _onBackButtonPressed,
      enableSwipeBack: true,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: null,
        body: Column(
          children: [
            _buildVideoPlayerSection(),
            _buildTabSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayerSection() {
    return SafeArea(
      child: AspectRatio(
        aspectRatio: _videoAspectRatio,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              _buildCustomVideoPlayer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomVideoPlayer() {
    return CustomVideoPlayer(
      key: _videoPlayerKey,
      media: widget.media,
      episode: _episode,
      onProgressUpdate: _updateProgress,
      onPlaybackCompleted: _onPlaybackCompleted,
      onVideoDurationReceived: _onVideoDurationReceived,
      startPosition: _currentProgress,
      isShortDramaMode: _isShortDramaMode,
      onBackPressed: _onBackButtonPressed,
      onNextEpisode: _playNextEpisode,
      onPrevEpisode: _playPrevEpisode,
      onEpisodeChanged: _changeEpisode,
      currentEpisodeIndex: _currentEpisodeIndex,
      totalEpisodes: _getCurrentSource().episodes.length,
      onPreloadNextEpisode: _onPreloadNextEpisode,
    );
  }

  Widget _buildTabSection(ThemeData theme) {
    return Expanded(
      child: DefaultTabController(
        length: _tabs.length,
        child: Column(
          children: [
            _buildTabBar(theme),
            _buildTabBarView(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TabBar(
        tabs: _tabs,
        indicatorColor: theme.colorScheme.primary,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        onTap: (index) {
          // Tab切换逻辑，当前不需要特殊处理
        },
      ),
    );
  }

  Widget _buildTabBarView(ThemeData theme) {
    return Expanded(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: const TabBarView(
          children: [
            _DescriptionTab(),
            _CommentsTab(),
          ],
        ),
      ),
    );
  }

  // MARK: - 短剧播放器构建
  Widget _buildShortDramaPlayer() {
    final currentSource = _getCurrentSource();

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final bool shouldPop = await _onShortDramaWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: currentSource.episodes.length,
            onPageChanged: _changeEpisode,
            itemBuilder: (context, index) => _buildShortDramaEpisodeItem(index),
          ),
          // 剧集信息卡片
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildShortDramaInfoCard(),
          ),
        ],
      ),
    );
  }

  void _setFullScreenMode() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  Widget _buildShortDramaEpisodeItem(int index) {
    final episode = _getCurrentSource().episodes[index];

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          SizedBox.expand(
            child: Stack(
              children: [
                _buildShortDramaVideoPlayer(episode, index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortDramaVideoPlayer(Episode episode, int index) {
    return CustomVideoPlayer(
      key: ValueKey(episode.url),
      media: widget.media,
      episode: episode,
      onProgressUpdate: _updateProgress,
      onPlaybackCompleted: _onPlaybackCompleted,
      onVideoDurationReceived: _onVideoDurationReceived,
      startPosition: index == _currentEpisodeIndex ? _currentProgress : 0,
      isShortDramaMode: true,
      onBackPressed: _onBackButtonPressed,
      onNextEpisode: _playNextEpisode,
      onPrevEpisode: _playPrevEpisode,
      onEpisodeChanged: _changeEpisode,
      currentEpisodeIndex: index,
      totalEpisodes: _getCurrentSource().episodes.length,
      onPreloadNextEpisode: _onPreloadNextEpisode,
    );
  }

  // 构建短剧信息卡片
  Widget _buildShortDramaInfoCard() {
    return _ShortDramaInfoCard(
      media: widget.media,
      currentEpisodeIndex: _currentEpisodeIndex,
      totalEpisodes: _getCurrentSource().episodes.length,
      onEpisodeChanged: _changeEpisode,
    );
  }
}

// MARK: - 简介标签页
class _DescriptionTab extends StatelessWidget {
  const _DescriptionTab();

  @override
  Widget build(BuildContext context) {
    final videoPlayerPage =
        context.findAncestorStateOfType<_VideoPlayerPageState>()!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaTitle(videoPlayerPage, theme),
          const SizedBox(height: 10),
          _buildMediaInfo(videoPlayerPage, theme),
          const SizedBox(height: 10),
          _buildMediaDetails(videoPlayerPage, theme),
          const SizedBox(height: 10),
          _buildMediaDescription(videoPlayerPage, theme),
          _buildProgressInfo(videoPlayerPage, theme),
          _buildEpisodeSelector(videoPlayerPage, context),
        ],
      ),
    );
  }

  Widget _buildMediaTitle(
      _VideoPlayerPageState videoPlayerPage, ThemeData theme) {
    return Text(
      videoPlayerPage.widget.media.name ?? '未知影片',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildMediaInfo(
      _VideoPlayerPageState videoPlayerPage, ThemeData theme) {
    final media = videoPlayerPage.widget.media;
    if (media.year == null && media.area == null)
      return const SizedBox.shrink();

    return Text(
      '${media.year ?? ''} ${media.area ?? ''}',
      style: TextStyle(
        fontSize: 14,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
      ),
    );
  }

  Widget _buildMediaDetails(
      _VideoPlayerPageState videoPlayerPage, ThemeData theme) {
    final media = videoPlayerPage.widget.media;
    final children = <Widget>[];

    if (media.actors != null) {
      children.add(Text(
        '主演: ${media.actors}',
        style: TextStyle(
          fontSize: 14,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ));
    }

    if (media.director != null) {
      children.add(Text(
        '导演: ${media.director}',
        style: TextStyle(
          fontSize: 14,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildMediaDescription(
      _VideoPlayerPageState videoPlayerPage, ThemeData theme) {
    final description = videoPlayerPage.widget.media.description;
    if (description == null) return const SizedBox.shrink();

    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
    );
  }

  Widget _buildProgressInfo(
      _VideoPlayerPageState videoPlayerPage, ThemeData theme) {
    if (videoPlayerPage._currentProgress <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        '当前播放位置: ${Duration(seconds: videoPlayerPage._currentProgress).toString().split('.').first}',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEpisodeSelector(
      _VideoPlayerPageState videoPlayerPage, BuildContext context) {
    if (videoPlayerPage.widget.media.surces.isEmpty)
      return const SizedBox.shrink();

    try {
      final currentSource = videoPlayerPage._getCurrentSource();
      final theme = Theme.of(context);

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
                final isSelected =
                    index == videoPlayerPage._currentEpisodeIndex;

                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary.withOpacity(0.3),
                      foregroundColor: isSelected
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => videoPlayerPage._changeEpisode(index),
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
}

// MARK: - 评论标签页
class _CommentsTab extends StatelessWidget {
  const _CommentsTab();

  @override
  Widget build(BuildContext context) {
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
}

// MARK: - 短剧信息卡片
class _ShortDramaInfoCard extends StatefulWidget {
  final MediaDetail media;
  final int currentEpisodeIndex;
  final int totalEpisodes;
  final Function(int) onEpisodeChanged;

  const _ShortDramaInfoCard({
    required this.media,
    required this.currentEpisodeIndex,
    required this.totalEpisodes,
    required this.onEpisodeChanged,
  });

  @override
  State<_ShortDramaInfoCard> createState() => _ShortDramaInfoCardState();
}

class _ShortDramaInfoCardState extends State<_ShortDramaInfoCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    if (_isExpanded) {
      // 展开内容
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
        child: _buildExpandedContent(theme),
      ).animate()
        .slideY(
          begin: 1.0,
          end: 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
    }

    // 卡片（收起状态）
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Container(
        height: 44.0,
        margin: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 4.0,
          bottom: safeAreaBottom + 4.0,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: _buildHeader(theme),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        height: 44.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // 剧集信息：名称 - 剧集
            Expanded(
              child: Text(
                '${widget.media.name ?? '未知剧集'} - 第${widget.currentEpisodeIndex + 1}集',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 展开/收起按钮
            Icon(
              _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.white,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(ThemeData theme) {
    // 打印所有可用数据用于调试
    _printMediaData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部卡片 - 标题和基本信息
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
          child: Row(
            children: [
              // 左侧：标题和基础信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 标题
                    Text(
                      widget.media.name ?? '未知剧集',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4.0),

                    // 基本信息行（彩色背景标签）
                    _buildBasicInfoRow(),
                  ],
                ),
              ),
              // 右侧：关闭按钮
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  iconSize: 16.0,
                  onPressed: _toggleExpanded,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8.0),
        Container(
          height: 0.3,
          color: Colors.white24,
        ),

        const SizedBox(height: 16.0),

        // Tab栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildTabBar(theme),
        ),

        const SizedBox(height: 16.0),

        // Tab内容
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildTabContent(theme),
          ),
        ),

        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildBasicInfoRow() {
    // 过滤掉null和空字符串
    final List<String> infoItems = [
      widget.media.year,
      widget.media.area,
      widget.media.language,
      widget.media.duration,
      widget.media.state,
    ].where((item) => item != null && item.isNotEmpty).cast<String>().toList();

    if (infoItems.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6.0,
          runSpacing: 3.0,
          children: infoItems.map((item) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _printMediaData() {
    print('=== 媒体数据调试信息 ===');
    print('ID: ${widget.media.id}');
    print('名称: ${widget.media.name}');
    print('副标题: ${widget.media.subtitle}');
    print('类型: ${widget.media.type}');
    print('分类: ${widget.media.category}');
    print('年份: ${widget.media.year}');
    print('地区: ${widget.media.area}');
    print('语言: ${widget.media.language}');
    print('时长: ${widget.media.duration}');
    print('状态: ${widget.media.state}');
    print('备注: ${widget.media.remarks}');
    print('版本: ${widget.media.version}');
    print('演员: ${widget.media.actors}');
    print('导演: ${widget.media.director}');
    print('编剧: ${widget.media.writer}');
    print('描述: ${widget.media.description}');
    print('内容: ${widget.media.content}');

    // 添加海报信息打印
    print('海报: ${widget.media.poster}');
    print('缩略海报: ${widget.media.posterThumb}');
    print('幻灯片海报: ${widget.media.posterSlide}');
    print('截图海报: ${widget.media.posterScreenshot}');

    print('评分: ${widget.media.score}');
    print('豆瓣评分: ${widget.media.doubanScore}');
    print('播放量: ${widget.media.hits}');
    print('日播放量: ${widget.media.hitsDay}');
    print('周播放量: ${widget.media.hitsWeek}');
    print('月播放量: ${widget.media.hitsMonth}');
    print('点赞数: ${widget.media.up}');
    print('点踩数: ${widget.media.down}');
    print('标签: ${widget.media.tag}');
    print('剧集总数: ${widget.media.total}');
    print('是否完结: ${widget.media.isEnd}');
    print('来源名称: ${widget.media.sourceName}');
    print('来源代码: ${widget.media.sourceCode}');
    print('=== 数据源信息 ===');
    for (int i = 0; i < widget.media.surces.length; i++) {
      final source = widget.media.surces[i];
      print('数据源 $i: ${source.name}');
      print('  剧集数量: ${source.episodes.length}');
      for (int j = 0; j < source.episodes.length; j++) {
        final episode = source.episodes[j];
        print('    剧集 $j: ${episode.title} (${episode.url})');
      }
    }
    print('=== 当前播放信息 ===');
    print('当前剧集索引: ${widget.currentEpisodeIndex}');
    print('总剧集数: ${widget.totalEpisodes}');
    print('==================');
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton('选集', 0, theme),
          const SizedBox(width: 4.0),
          _buildTabButton('简介', 1, theme),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, ThemeData theme) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Colors.red, Color(0xFFE53E3E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4.0,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 14.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildEpisodeSelector(theme);
      case 1:
        return _buildDescription(theme);
      default:
        return const SizedBox();
    }
  }

  Widget _buildEpisodeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 剧集信息头部
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '剧集选择',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '共 ${widget.totalEpisodes} 集',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Color(0xFFE53E3E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4.0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '第${widget.currentEpisodeIndex + 1}集',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // 剧集网格
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: widget.totalEpisodes,
                itemBuilder: (context, index) {
                  final isSelected = index == widget.currentEpisodeIndex;
                  return GestureDetector(
                    onTap: () {
                      // 在短剧模式下，需要通过 PageView 来切换剧集
                      final videoPlayerPage = context
                          .findAncestorStateOfType<_VideoPlayerPageState>();
                      if (videoPlayerPage != null &&
                          videoPlayerPage._isShortDramaMode) {
                        videoPlayerPage._pageController.jumpToPage(index);
                      } else {
                        widget.onEpisodeChanged(index);
                      }
                      _toggleExpanded();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Colors.red, Color(0xFFE53E3E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: isSelected
                              ? Colors.red.withOpacity(0.5)
                              : Colors.white.withOpacity(0.2),
                          width: 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 13.0,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 评分信息
          if (widget.media.score != null ||
              widget.media.doubanScore != null) ...[
            _buildRatingSection(),
            const SizedBox(height: 20.0),
          ],

          // 简介
          if (widget.media.description != null) ...[
            _buildSectionCard('简介', _buildDescriptionContent()),
            const SizedBox(height: 20.0),
          ],

          // 演职人员
          if (widget.media.actors != null ||
              widget.media.director != null ||
              widget.media.writer != null) ...[
            _buildSectionCard('演职人员', _buildCastContent()),
            const SizedBox(height: 20.0),
          ],

          // 统计信息
          _buildSectionCard('统计信息', _buildStatsGrid()),
          const SizedBox(height: 20.0),

          // 其他信息
          if (widget.media.remarks != null || widget.media.tag != null) ...[
            _buildSectionCard('其他信息', _buildOtherInfoContent()),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.0,
                height: 20.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Color(0xFFE53E3E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          content,
        ],
      ),
    );
  }

  Widget _buildDescriptionContent() {
    return Text(
      widget.media.description!,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14.0,
        height: 1.6,
      ),
    );
  }

  Widget _buildCastContent() {
    return Column(
      children: [
        if (widget.media.director != null) ...[
          _buildInfoRow('导演', widget.media.director!),
          const SizedBox(height: 8.0),
        ],
        if (widget.media.actors != null) ...[
          _buildInfoRow('主演', widget.media.actors!),
          const SizedBox(height: 8.0),
        ],
        if (widget.media.writer != null) ...[
          _buildInfoRow('编剧', widget.media.writer!),
        ],
      ],
    );
  }

  Widget _buildOtherInfoContent() {
    return Column(
      children: [
        if (widget.media.remarks != null) ...[
          _buildInfoRow('备注', widget.media.remarks!),
          const SizedBox(height: 8.0),
        ],
        if (widget.media.tag != null) ...[
          _buildInfoRow('标签', widget.media.tag!),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50.0,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14.0,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        if (widget.media.score != null) ...[
          Expanded(
            child: _buildRatingCard('评分', widget.media.score!, Colors.orange),
          ),
          const SizedBox(width: 12.0),
        ],
        if (widget.media.doubanScore != null) ...[
          Expanded(
            child:
                _buildRatingCard('豆瓣', widget.media.doubanScore!, Colors.green),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingCard(String label, String score, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            score,
            style: TextStyle(
              color: color,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      childAspectRatio: 2.8,
      children: [
        _buildStatItem('播放量', '${widget.media.hits}', Icons.play_circle_outline,
            Colors.blue),
        _buildStatItem(
            '日播放', '${widget.media.hitsDay}', Icons.trending_up, Colors.green),
        _buildStatItem(
            '点赞', '${widget.media.up}', Icons.thumb_up_outlined, Colors.orange),
        _buildStatItem(
            '剧集数', '${widget.media.total}', Icons.video_library, Colors.purple),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  int _selectedTabIndex = 0;
}
