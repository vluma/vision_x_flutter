import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/models/history_record.dart';
import 'package:intl/intl.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: record.media.poster ?? '',
            width: 60,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 60,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.movie, color: Colors.grey),
            ),
            errorWidget: (context, url, error) => Container(
              width: 60,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.movie, color: Colors.grey),
            ),
          ),
        ),
        title: Text(
          record.media.name ?? '未知影片',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              record.episode.title,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(record.watchedAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (record.progress > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '观看至 ${Duration(seconds: record.progress).toString().split('.').first}',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}