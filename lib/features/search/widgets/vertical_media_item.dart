import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/shared/widgets/custom_card.dart';
import 'package:vision_x_flutter/shared/widgets/loading_animation.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';

/// 垂直媒体项组件 - 分组模式
class VerticalMediaItem extends StatelessWidget {
  final MediaDetail media;
  final VoidCallback onTap;
  final VoidCallback onDetailTap;

  const VerticalMediaItem({
    super.key,
    required this.media,
    required this.onTap,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String? imageUrl = media.poster;

    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 海报图片 - 使用Expanded让图片高度自适应
            Expanded(
              child: _buildImageContainer(context, imageUrl, isDarkMode),
            ),

            // 标题 - 高度根据行数自适应
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                media.name ?? '未知片名',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 年份、地区、分类信息 - 固定高度
            Container(
              height: 20, // 固定底部时间行高度
              padding: const EdgeInsets.only(top: 4),
              child: _buildYearAreaType(theme, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  // 构建图片容器（带评分和详情按钮）
  Widget _buildImageContainer(
      BuildContext context, String? imageUrl, bool isDarkMode) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor?.withOpacity(0.1) ??
                Colors.black.withOpacity(0.1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 图片
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const LoadingAnimation(),
                    errorWidget: (context, url, error) => Container(
                      color: theme.cardTheme.color?.withOpacity(0.7),
                      child: const Center(
                        child: Icon(
                          Icons.movie,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: theme.cardTheme.color?.withOpacity(0.7),
                    child: const Center(
                      child: Icon(
                        Icons.movie,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),

          // 评分（左下角）
          if (media.score != null && media.score!.isNotEmpty)
            Positioned(
              bottom: 3,
              left: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 10,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      media.score!,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 详情按钮（右下角）
          Positioned(
            bottom: 3,
            right: 3,
            child: GestureDetector(
              onTap: onDetailTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  '详情',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建年份、区域和类型信息
  Widget _buildYearAreaType(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 年份和区域
        Expanded(
          child: Text(
            [
              if (media.year != null && media.year!.isNotEmpty) media.year,
              if (media.area != null && media.area!.isNotEmpty) media.area,
            ].join(' · '),
            style: TextStyle(
              fontSize: 9,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 类型标签
        if (media.type != null && media.type!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              media.type!,
              style: TextStyle(
                fontSize: 8,
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
