import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/models/history_record.dart';
import 'package:intl/intl.dart';
import 'package:vision_x_flutter/components/custom_card.dart';

class HistoryItem extends StatelessWidget {
  final HistoryRecord record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryItem({
    super.key,
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: CustomCard(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.all(6),
          onTap: onTap,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: record.media.poster ?? '',
              width: 50,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.movie,
                  color: Theme.of(context).disabledColor,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.movie,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
          title: Text(
            record.media.name ?? '未知影片',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                record.episode.title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(record.watchedAt),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              if (record.progress > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: LinearProgressIndicator(
                    value: _calculateProgress(),
                    backgroundColor:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                    minHeight: 4,
                  ),
                ),
              if (record.progress > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '观看至 ${Duration(seconds: record.progress).toString().split('.').first}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          // 移除删除按钮，改用右滑删除
        ),
      ),
    );
  }

  double _calculateProgress() {
    // 使用实际的视频总时长计算进度比例
    if (record.duration != null && record.duration! > 0) {
      return (record.progress / record.duration!).clamp(0.0, 1.0);
    }

    // 如果没有总时长信息，则使用估计值
    const estimatedVideoDuration = 2500; // 假设视频大约40分钟
    return (record.progress / estimatedVideoDuration).clamp(0.0, 1.0);
  }
}
