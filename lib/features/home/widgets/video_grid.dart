import 'package:flutter/material.dart';
import 'package:vision_x_flutter/core/themes/colors.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'package:vision_x_flutter/data/models/douban_movie.dart';
import 'package:vision_x_flutter/components/custom_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/components/loading_animation.dart';
import 'package:vision_x_flutter/services/api_service.dart';

/// 视频网格组件，支持下拉刷新和上拉加载更多
class VideoGrid extends StatefulWidget {
  final List<DoubanMovie> movies;
  final bool hasMoreData;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<DoubanMovie> onItemTap;

  const VideoGrid({
    super.key,
    required this.movies,
    required this.hasMoreData,
    required this.isLoading,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onItemTap,
  });

  @override
  State<VideoGrid> createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  final ScrollController _scrollController = ScrollController();
  List<DoubanMovie> _previousMovies = [];

  @override
  void initState() {
    super.initState();
    _previousMovies = widget.movies;
  }

  @override
  void didUpdateWidget(covariant VideoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检测数据是否刷新或排序，如果是则滚动到顶部
    if (_shouldScrollToTop(oldWidget.movies, widget.movies)) {
      _scrollToTop();
    }
    _previousMovies = widget.movies;
  }

  bool _shouldScrollToTop(List<DoubanMovie> oldMovies, List<DoubanMovie> newMovies) {
    // 如果数据完全刷新（长度变化或内容完全不同）
    if (oldMovies.length != newMovies.length) {
      return true;
    }
    
    // 如果排序可能发生变化（第一个元素不同）
    if (oldMovies.isNotEmpty && newMovies.isNotEmpty && 
        oldMovies.first.id != newMovies.first.id) {
      return true;
    }
    
    return false;
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 500) {
                  widget.onLoadMore();
                  return true;
                }
                return false;
              },
              child: _buildGridContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridContent() {
    return GridView.builder(
      controller: _scrollController, // 添加滚动控制器
      padding: AppSpacing.pageMargin.copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.bottomNavigationBarMargin,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: widget.movies.length + (widget.hasMoreData ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index == widget.movies.length && widget.hasMoreData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onLoadMore();
          });
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final movie = widget.movies[index];
        return _VideoItem(
          movie: movie,
          onTap: () => widget.onItemTap(movie),
        );
      },
    );
  }
}

/// 单个视频项组件
class _VideoItem extends StatelessWidget {
  final DoubanMovie movie;
  final VoidCallback onTap;

  const _VideoItem({
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String imageUrl = ApiService.handleImageUrl(movie.cover);

    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const LoadingAnimation(),
                      errorWidget: (context, url, error) => Container(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    if (movie.rate.isNotEmpty &&
                        double.tryParse(movie.rate) != null &&
                        double.parse(movie.rate) > 0)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.yellow, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                movie.rate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}