import 'package:flutter/material.dart';
import 'package:vision_x_flutter/features/home/models/douban_movie.dart';

/// 视频网格组件
class VideoGrid extends StatelessWidget {
  final List<DoubanMovie> movies;
  final bool hasMoreData;
  final bool isLoading;
  final VoidCallback onRefresh;
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
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        itemCount: movies.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == movies.length) {
            return _buildLoadMoreIndicator();
          }
          
          final movie = movies[index];
          return _buildMovieItem(context, movie);
        },
      ),
    );
  }

  Widget _buildMovieItem(BuildContext context, DoubanMovie movie) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => onItemTap(movie),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 电影海报
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(movie.cover),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              // 电影信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '评分: ${movie.rate}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '年份: ${_extractYearFromTitle(movie.title)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4.0),
                    if (movie.playable)
                      Text(
                        '可播放',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _extractYearFromTitle(String title) {
    final regex = RegExp(r'\((\d{4})\)');
    final match = regex.firstMatch(title);
    return match != null ? int.parse(match.group(1)!) : DateTime.now().year;
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: onLoadMore,
                child: const Text('加载更多'),
              ),
      ),
    );
  }
}