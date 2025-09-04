import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:vision_x_flutter/shared/widgets/loading_animation.dart';

/// 详情页面头部组件
/// 显示海报和基本信息
class DetailHeader extends StatelessWidget {
  final MediaDetail media;

  const DetailHeader({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 海报
          _buildPoster(context),

          const SizedBox(width: 16),

          // 基本信息
          Expanded(
            child: _buildInfoSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: CachedNetworkImage(
        imageUrl: ApiService.handleImageUrl(media.poster ?? ''),
        width: 120,
        height: 160,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 120,
          height: 160,
          color: Theme.of(context).cardColor,
          child: const LoadingAnimation(),
        ),
        errorWidget: (context, url, error) => Container(
          width: 120,
          height: 160,
          color: Theme.of(context).cardColor,
          child: const Icon(
            Icons.movie,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          media.name ?? '未知名称',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),

        // 基本信息列表
        _buildInfoList(context),
      ],
    );
  }

  Widget _buildInfoList(BuildContext context) {
    final infoItems = <Widget>[];

    void addInfoItem(String label, String? value) {
      if (value != null && value.isNotEmpty) {
        infoItems.add(
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
        infoItems.add(const SizedBox(height: 4));
      }
    }

    addInfoItem('年份', media.year);
    addInfoItem('类型', media.type);
    addInfoItem('地区', media.area);
    addInfoItem('语言', media.language);
    addInfoItem('时长', media.duration);
    addInfoItem('评分', media.score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: infoItems,
    );
  }
}
