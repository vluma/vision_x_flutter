import 'package:flutter/material.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/theme/spacing.dart';
import 'package:vision_x_flutter/pages/search/components/vertical_media_item.dart';
import 'package:vision_x_flutter/pages/search/components/media_grid_item.dart';

/// 来源分组组件
class SourceGroup extends StatelessWidget {
  final String sourceName;
  final List<MediaDetail> mediaList;
  final Function(MediaDetail) onMediaTap;
  final Function(MediaDetail) onDetailTap;

  const SourceGroup({
    super.key,
    required this.sourceName,
    required this.mediaList,
    required this.onMediaTap,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 来源标题
        Container(
          padding: const EdgeInsets.only(
              left: AppSpacing.md, top: AppSpacing.md, bottom: AppSpacing.sm),
          child: Text(
            sourceName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 根据媒体数量采用不同的布局
        _buildMediaLayout(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMediaLayout() {
    if (mediaList.length == 1) {
      // 只有一个媒体项，使用与聚合视图相同的布局
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: MediaGridItem(
          media: mediaList[0],
          onTap: () => onMediaTap(mediaList[0]),
          onDetailTap: () => onDetailTap(mediaList[0]),
        ),
      );
    } else if (mediaList.length == 2) {
      // 两个媒体项，使用Row布局，固定高度180
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 180, // 固定卡片高度
              margin: const EdgeInsets.only(right: 0),
              child: VerticalMediaItem(
                media: mediaList[0],
                onTap: () => onMediaTap(mediaList[0]),
                onDetailTap: () => onDetailTap(mediaList[0]),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 180, // 固定卡片高度
              margin: const EdgeInsets.only(left: 0),
              child: VerticalMediaItem(
                media: mediaList[1],
                onTap: () => onMediaTap(mediaList[1]),
                onDetailTap: () => onDetailTap(mediaList[1]),
              ),
            ),
          ),
        ],
      );
    } else {
      // 三个或以上媒体项，使用图片在上方的布局，固定宽度，可滑动，固定高度180
      return SizedBox(
        height: 180, // 固定卡片高度
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            final media = mediaList[index];
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 0),
              child: VerticalMediaItem(
                media: media,
                onTap: () => onMediaTap(media),
                onDetailTap: () => onDetailTap(media),
              ),
            );
          },
        ),
      );
    }
  }
}