import 'package:flutter/material.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';

/// 详情页面演职人员组件
/// 显示导演和演员信息
class DetailCast extends StatelessWidget {
  final MediaDetail media;

  const DetailCast({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final castWidgets = <Widget>[];

    // 添加导演信息
    if (media.director != null && media.director!.isNotEmpty) {
      castWidgets.add(
        _buildCastItem('导演', media.director!),
      );
    }

    // 添加演员信息
    if (media.actors != null && media.actors!.isNotEmpty) {
      castWidgets.add(
        _buildCastItem('主演', media.actors!),
      );
    }

    // 如果没有演职人员信息，返回空组件
    if (castWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '演职人员',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...castWidgets,
        ],
      ),
    );
  }

  Widget _buildCastItem(String role, String names) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: '$role: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            TextSpan(
              text: names,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
