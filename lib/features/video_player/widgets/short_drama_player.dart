import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 添加foundation导入
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:vision_x_flutter/features/video_player/widgets/video_player.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/viewmodels/video_player_viewmodel.dart';

/// 短剧模式播放器 - 支持垂直滑动切换剧集的播放器组件
class ShortDramaPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const ShortDramaPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildShortDramaPlayer(context),
    );
  }

  /// 构建短剧播放器主体
  Widget _buildShortDramaPlayer(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Stack(
        children: [
          // 垂直滑动页面视图
          _buildEpisodePageView(),
          // 透明背景控件，用于点击收起信息卡片
          _buildTransparentOverlay(),
          // 剧集信息卡片
          _buildInfoCard(),
        ],
      ),
    );
  }

  /// 构建剧集页面视图
  Widget _buildEpisodePageView() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.currentEpisodeIndex,
      builder: (context, currentIndex, child) {
        // 当剧集索引变化时，同步更新PageView的位置
        if (controller.pageController.hasClients &&
            controller.pageController.page?.round() != currentIndex) {
          controller.pageController.animateToPage(
            currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        return PageView.builder(
          controller: controller.pageController,
          scrollDirection: Axis.vertical,
          itemCount: controller.totalEpisodes,
          onPageChanged: controller.changeEpisode,
          itemBuilder: (context, index) => _buildEpisodeItem(index, context),
        );
      },
    );
  }

  /// 构建单个剧集项目
  Widget _buildEpisodeItem(int index, BuildContext context) {
    final episode = controller.currentSource.episodes[index];

    return Container(
      color: Colors.black,
      child: _buildVideoPlayer(episode, index, context),
    );
  }

  /// 构建视频播放器
  Widget _buildVideoPlayer(Episode episode, int index, BuildContext context) {
    return ValueListenableBuilder<Episode>(
      valueListenable: controller.currentEpisode,
      builder: (context, currentEpisode, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.isFullScreen,
          builder: (context, isFullScreen, _) {
            // 如果当前是全屏状态，使用固定key避免重建
            // 否则使用剧集URL作为key确保正常更新
            final playerKey = isFullScreen 
                ? const ValueKey('fullscreen_player')
                : ValueKey(currentEpisode.url);
                
            debugPrint('构建视频播放器: 全屏=$isFullScreen, 剧集=${currentEpisode.title}, Key=$playerKey');
            
            return CustomVideoPlayer(
              key: playerKey,
              media: controller.media,
              episode: currentEpisode,
              onProgressUpdate: controller.updateProgress,
              onPlaybackCompleted: () {
                controller.playNextEpisode();
              },
              onVideoDurationReceived: controller.setVideoDuration,
              startPosition: index == controller.currentEpisodeIndex.value
                  ? controller.currentProgress.value
                  : 0,
              isShortDramaMode: true,
              onBackPressed: () => context.pop(),
              onNextEpisode: controller.playNextEpisode,
              onPrevEpisode: controller.playPrevEpisode,
              onEpisodeChanged: controller.changeEpisode,
              currentEpisodeIndex: index,
              totalEpisodes: controller.totalEpisodes,
              onPreloadNextEpisode: controller.preloadNextEpisode,
              onFullScreenChanged: controller.setFullScreen, // 同步全屏状态
            );
          },
        );
      },
    );
  }

  /// 构建透明背景控件
  Widget _buildTransparentOverlay() {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isInfoCardExpanded,
      builder: (context, isExpanded, child) {
        return Visibility(
          visible: isExpanded,
          child: GestureDetector(
            onTap: controller.toggleInfoCard,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        );
      },
    );
  }

  /// 构建信息卡片
  Widget _buildInfoCard() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: _ShortDramaInfoCard(
        media: controller.media,
        currentEpisodeIndex: controller.currentEpisodeIndex.value,
        totalEpisodes: controller.totalEpisodes,
        onEpisodeChanged: controller.changeEpisode,
      ),
    );
  }
}

/// 短剧信息卡片组件 - 显示剧集信息和提供交互控制
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
  int _selectedTabIndex = 0;
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // 获取父组件中的控制器实例
    final ShortDramaPlayer parent =
        context.findAncestorWidgetOfExactType<ShortDramaPlayer>()!;
    _controller = parent.controller;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isInfoCardExpanded,
      builder: (context, isExpanded, child) {
        // 使用AnimatedSwitcher添加切换动画
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            // 对展开和折叠状态使用不同的动画
            if (child.key == const ValueKey('expanded')) {
              // 展开动画：从底部向上滑出 + 淡入效果
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0, // 从底部开始
                  child: child,
                ),
              );
            } else {
              // 折叠动画：向底部滑入
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            }
          },
          child: isExpanded
              ? _buildExpandedCard(key: const ValueKey('expanded'))
              : _buildCollapsedCard(key: const ValueKey('collapsed')),
        );
      },
    );
  }

  /// 构建展开状态卡片
  Widget _buildExpandedCard({Key? key}) {
    return Container(
      key: key,
      height: MediaQuery.of(context).size.height * 0.75,
      width: double.infinity,
      decoration: _buildCardDecoration(roundedTopOnly: true),
      child: _buildExpandedContent(),
    );
  }

  /// 构建折叠状态卡片
  Widget _buildCollapsedCard({Key? key}) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      key: key,
      color: const Color(0xFF0A0A0A),
      child: Container(
        height: 44.0,
        margin: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 4.0,
          bottom: safeAreaBottom + 4.0,
        ),
        decoration: _buildCardDecoration(),
        child: _buildHeader(),
      ),
    );
  }

  /// 构建卡片装饰样式
  BoxDecoration _buildCardDecoration({bool roundedTopOnly = false}) {
    return BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: roundedTopOnly
          ? const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            )
          : const BorderRadius.all(Radius.circular(8.0)),
    );
  }

  /// 构建卡片头部
  Widget _buildHeader() {
    return ValueListenableBuilder<int>(
        valueListenable: _controller.currentEpisodeIndex,
        builder: (context, currentIndex, child) {
          final episodeTitle =
              _controller.currentSource.episodes[currentIndex].title;
          return GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              height: 44.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // 添加媒体封面图片
                  if (widget.media.poster != null &&
                      widget.media.poster!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.media.poster!,
                        width: 32.0,
                        height: 32.0,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 32.0,
                          height: 32.0,
                          color: Colors.grey.withValues(alpha: 0.3),
                          child: const Center(
                            child: SizedBox(
                              width: 16.0,
                              height: 16.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white30),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 32.0,
                          height: 32.0,
                          color: Colors.grey.withValues(alpha: 0.3),
                          child: const Icon(
                            Icons.movie,
                            color: Colors.white70,
                            size: 16.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                  Expanded(
                    child: Text(
                      '${widget.media.name ?? '未知剧集'} - ${(episodeTitle != null && episodeTitle.isNotEmpty) ? episodeTitle : '第${currentIndex + 1}集'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          );
        });
  }

  /// 构建展开内容
  Widget _buildExpandedContent() {
    return ValueListenableBuilder<int>(
        valueListenable: _controller.currentEpisodeIndex,
        builder: (context, currentIndex, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                child: Row(
                  children: [
                    // 添加媒体封面图片
                    if (widget.media.poster != null &&
                        widget.media.poster!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: CachedNetworkImage(
                          imageUrl: widget.media.poster!,
                          width: 32.0,
                          height: 32.0,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 32.0,
                            height: 32.0,
                            color: Colors.grey.withValues(alpha: 0.3),
                            child: const Center(
                              child: SizedBox(
                                width: 16.0,
                                height: 16.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white30),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 32.0,
                            height: 32.0,
                            color: Colors.grey.withValues(alpha: 0.3),
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white70,
                              size: 16.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          _buildBasicInfoRow(),
                        ],
                      ),
                    ),
                    Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: 16.0,
                        onPressed: _toggleExpanded,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Container(height: 0.3, color: Colors.white24),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildPlaybackSpeedRow(),
              ),
              const SizedBox(height: 12.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildTabBar(),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildTabContent(currentIndex),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          );
        });
  }

  Widget _buildBasicInfoRow() {
    final infoItems = [
      widget.media.year,
      widget.media.area,
      widget.media.language,
      widget.media.duration,
      widget.media.state,
    ].where((item) => item != null && item.isNotEmpty).cast<String>().toList();

    if (infoItems.isEmpty) return const SizedBox();
    return Wrap(
      spacing: 6.0,
      runSpacing: 3.0,
      children: infoItems
          .map((item) => Container(
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
              ))
          .toList(),
    );
  }

  /// 构建标签栏
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          _buildTabButton('选集', 0),
          const SizedBox(width: 4.0),
          _buildTabButton('简介', 1),
        ],
      ),
    );
  }

  /// 构建倍速播放按钮行
  Widget _buildPlaybackSpeedRow() {
    final speeds = [0.75, 1.0, 1.25, 1.5, 2.0, 3.0];
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.speed, size: 16.0, color: Colors.white70),
          const SizedBox(width: 8.0),
          ...speeds.map((speed) => _buildSpeedButton(speed)),
        ],
      ),
    );
  }

  /// 构建标签按钮
  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
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
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 4.0,
                      offset: const Offset(0, 1),
                    )
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

  /// 构建倍速按钮
  Widget _buildSpeedButton(double speed) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _controller.setPlaybackSpeed(speed);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: _controller.playbackSpeed.value == speed
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: Text(
            '${speed}x',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _controller.playbackSpeed.value == speed
                  ? Colors.red
                  : Colors.white70,
              fontSize: 12.0,
              fontWeight: _controller.playbackSpeed.value == speed
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建标签内容
  Widget _buildTabContent(int currentIndex) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildEpisodeSelector(currentIndex);
      case 1:
        return _buildDescription();
      default:
        return const SizedBox();
    }
  }

  /// 构建剧集选择器
  Widget _buildEpisodeSelector(int currentIndex) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '剧集选择',
                      style: TextStyle(
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
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 4.0,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Text(
                  '第${currentIndex + 1}集',
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
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
                  final isSelected = index == currentIndex;
                  return GestureDetector(
                    onTap: () {
                      widget.onEpisodeChanged(index);
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
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: isSelected
                              ? Colors.red.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 1),
                                )
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

  /// 构建描述内容
  Widget _buildDescription() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.media.description != null) ...[
            _buildSectionCard('简介', _buildDescriptionContent()),
            const SizedBox(height: 20.0),
          ],
          _buildSectionCard('统计信息', _buildStatsGrid()),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          )
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
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
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
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Icon(icon, color: color, size: 16.0),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
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
    _controller.toggleInfoCard();
  }
}
