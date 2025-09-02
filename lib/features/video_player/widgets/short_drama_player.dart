import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vision_x_flutter/components/video_player.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/video_player_controller.dart';

/// 短剧模式播放器
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

  Widget _buildShortDramaPlayer(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            scrollDirection: Axis.vertical,
            itemCount: controller.totalEpisodes,
            onPageChanged: controller.changeEpisode,
            itemBuilder: (context, index) =>
                _buildShortDramaEpisodeItem(index, context),
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

  Widget _buildShortDramaEpisodeItem(int index, BuildContext context) {
    final episode = controller.currentSource.episodes[index];

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          SizedBox.expand(
            child: Stack(
              children: [
                _buildShortDramaVideoPlayer(episode, index, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortDramaVideoPlayer(
      Episode episode, int index, BuildContext context) {
    return CustomVideoPlayer(
      key: ValueKey(episode.url),
      media: controller.media,
      episode: episode,
      onProgressUpdate: controller.updateProgress,
      onPlaybackCompleted: controller.playNextEpisode,
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
    );
  }

  Widget _buildShortDramaInfoCard() {
    return _ShortDramaInfoCard(
      media: controller.media,
      currentEpisodeIndex: controller.currentEpisodeIndex.value,
      totalEpisodes: controller.totalEpisodes,
      onEpisodeChanged: controller.changeEpisode,
    );
  }
}

// 短剧信息卡片组件
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

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    if (_isExpanded) {
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
        child: _buildExpandedContent(Theme.of(context)),
      );
    }

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
        child: _buildHeader(Theme.of(context)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
          child: Row(
            children: [
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
                  color: Colors.white.withOpacity(0.1),
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
          child: _buildTabBar(theme),
        ),
        const SizedBox(height: 16.0),
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
          )
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
                      color: Colors.red.withOpacity(0.3),
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
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4.0,
                      offset: const Offset(0, 1),
                    )
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

  Widget _buildDescription(ThemeData theme) {
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
            color: Colors.black.withOpacity(0.2),
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
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.3), width: 1.0),
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
                child: Icon(icon, color: color, size: 16.0),
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
    setState(() => _isExpanded = !_isExpanded);
  }
}
