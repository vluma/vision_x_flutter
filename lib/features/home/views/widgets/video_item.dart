import 'package:flutter/material.dart';
import 'package:vision_x_flutter/core/themes/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/shared/widgets/loading_animation.dart';
import 'package:vision_x_flutter/features/home/models/douban_movie.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/shared/widgets/custom_card.dart';

/// 单个视频项组件
class VideoItem extends StatefulWidget {
  final DoubanMovie movie;
  final VoidCallback onTap;

  const VideoItem({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  bool _isPressed = false;

  void _setPressed(bool pressed) {
    if (mounted) {
      setState(() {
        _isPressed = pressed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String imageUrl = ApiService.handleImageUrl(widget.movie.cover);

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  child: Stack(
                    fit: StackFit.expand, // 使子组件填充整个Stack
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
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
                      // NEW 标签
                      if (widget.movie.isNew)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      // 评分显示
                      if (widget.movie.rate.isNotEmpty &&
                          double.tryParse(widget.movie.rate) != null &&
                          double.parse(widget.movie.rate) > 0)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.darkBackground.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.yellow, size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  widget.movie.rate,
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
                      // 豆瓣详情页链接
                      if (widget.movie.url.isNotEmpty)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: GestureDetector(
                            onTap: () {
                              // 通过路由跳转到 WebView 页面
                              context.push('/webview', extra: {
                                'url': widget.movie.url,
                                'title': widget.movie.title,
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.darkBackground.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.link,
                                      color: Colors.white, size: 12),
                                  SizedBox(width: 3),
                                  Text(
                                    '详情',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // 标题部分
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
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
      ),
    );
  }
}