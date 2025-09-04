import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/shared/widgets/custom_card.dart';
import 'package:vision_x_flutter/shared/widgets/loading_animation.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';

/// 媒体网格项组件 - 聚合模式
class MediaGridItem extends StatelessWidget {
  final MediaDetail media;
  final VoidCallback onTap;
  final VoidCallback onDetailTap;

  const MediaGridItem({
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 海报图片
            _buildImageContainer(context, imageUrl, isDarkMode),

            // 内容信息
            _buildContent(context, theme, isDarkMode),
          ],
        ),
      ),
    );
  }

  // 构建图片容器
  Widget _buildImageContainer(
      BuildContext context, String? imageUrl, bool isDarkMode) {
    final theme = Theme.of(context);
    return Container(
      width: 70,
      height: 100,
      margin: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor?.withValues(alpha: 0.1) ??
                Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingAnimation(),
                errorWidget: (context, url, error) => Container(
                  color: theme.cardTheme.color?.withValues(alpha: 0.7),
                  child: const Center(
                    child: Icon(
                      Icons.movie,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : Container(
                color: theme.cardTheme.color?.withValues(alpha: 0.7),
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );
  }

  // 构建内容区域
  Widget _buildContent(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题和基本信息
            _buildTitleAndInfo(theme, isDarkMode),

            // 简介
            _buildDescription(context, isDarkMode),

            const SizedBox(height: 2),

            // 底部信息
            Flexible(
              child: _buildBottomInfo(theme, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  // 构建标题和基本信息
  Widget _buildTitleAndInfo(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          media.name ?? '未知片名',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 9,
            color: theme.textTheme.bodyLarge?.color,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // 年份、区域和类型信息
        _buildYearAreaType(theme, isDarkMode),

        const SizedBox(height: 4),

        // 评分和来源
        _buildRatingAndSource(theme, isDarkMode),
      ],
    );
  }

  // 构建年份、区域和类型信息
  Widget _buildYearAreaType(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        if (media.year != null && media.year!.isNotEmpty)
          Text(
            media.year!,
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        if (media.year != null &&
            media.year!.isNotEmpty &&
            media.area != null &&
            media.area!.isNotEmpty)
          Text(
            ' · ',
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        if (media.area != null && media.area!.isNotEmpty)
          Flexible(
            child: Text(
              media.area!,
              style: TextStyle(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (media.type != null && media.type!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              media.type!,
              style: TextStyle(
                fontSize: 9,
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // 构建评分和来源信息
  Widget _buildRatingAndSource(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        // 评分
        if (media.score != null && media.score!.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 3),
              Text(
                media.score!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        // 来源信息
        if (media.sourceName.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.cardTheme.color?.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              media.sourceName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
      ],
    );
  }

  // 构建简介
  Widget _buildDescription(BuildContext context, bool isDarkMode) {
    if (media.description == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Text(
      media.description!,
      style: TextStyle(
        fontSize: 11,
        color: theme.textTheme.bodySmall?.color,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // 构建底部信息
  Widget _buildBottomInfo(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 演员信息
        if (media.actors != null && media.actors!.isNotEmpty)
          Expanded(
            child: Text(
              media.actors!,
              style: TextStyle(
                fontSize: 10,
                color: theme.textTheme.labelSmall?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // 详情按钮
        TextButton(
          onPressed: onDetailTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor:
                theme.textButtonTheme.style?.foregroundColor?.resolve({}),
          ),
          child: const Text(
            '详情',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
