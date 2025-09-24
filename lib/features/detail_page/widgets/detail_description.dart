import 'package:flutter/material.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';

/// 详情页面简介组件
/// 显示媒体描述信息
class DetailDescription extends StatelessWidget {
  final MediaDetail media;

  const DetailDescription({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final description = media.description ?? media.content ?? '暂无简介';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '简介',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: Colors.grey[800],
                ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
