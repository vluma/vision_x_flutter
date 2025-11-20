import 'package:flutter/material.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'package:vision_x_flutter/features/home/models/douban_movie.dart';
import 'package:vision_x_flutter/features/home/views/widgets/video_item.dart';

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
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant VideoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检测数据是否刷新或排序，如果是则滚动到顶部
    if (_shouldScrollToTop(oldWidget.movies, widget.movies)) {
      _scrollToTop();
    }
  }

  bool _shouldScrollToTop(
      List<DoubanMovie> oldMovies, List<DoubanMovie> newMovies) {
    // 如果数据完全刷新（长度变化或内容完全不同）
    if (oldMovies.length != newMovies.length) {
      return true;
    }

    // 如果排序可能发生变化（第一个元素不同）
    if (oldMovies.isNotEmpty &&
        newMovies.isNotEmpty &&
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
                // 当滚动接近底部时加载更多数据
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 500) {
                  // 避免重复调用加载更多
                  if (!widget.isLoading && widget.hasMoreData) {
                    widget.onLoadMore();
                  }
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
      controller: _scrollController,
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
        // 显示加载指示器
        if (index == widget.movies.length && widget.hasMoreData) {
          // 确保只调用一次加载更多
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!widget.isLoading) {
              widget.onLoadMore();
            }
          });
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final movie = widget.movies[index];
        return VideoItem(
          movie: movie,
          onTap: () => widget.onItemTap(movie),
        );
      },
    );
  }
}