import 'package:flutter/material.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'package:vision_x_flutter/components/custom_card.dart';
import 'package:vision_x_flutter/features/search/widgets/media_grid_item_skeleton.dart';

/// 搜索页面加载骨架屏组件
class SearchLoadingSkeleton extends StatelessWidget {
  final bool isGroupedView;

  const SearchLoadingSkeleton({super.key, this.isGroupedView = false});

  @override
  Widget build(BuildContext context) {
    return isGroupedView ? _buildGroupedSkeleton() : _buildListSkeleton();
  }

  /// 构建分组视图骨架屏
  Widget _buildGroupedSkeleton() {
    return ListView.builder(
      padding: AppSpacing.pageMargin.copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.bottomNavigationBarMargin,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _SourceGroupSkeleton();
      },
    );
  }

  /// 构建列表视图骨架屏
  Widget _buildListSkeleton() {
    return ListView.builder(
      padding: AppSpacing.pageMargin.copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.bottomNavigationBarMargin,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: const MediaGridItemSkeleton(),
        );
      },
    );
  }
}

/// 源分组骨架屏组件
class _SourceGroupSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分组标题骨架
          Container(
            height: 20,
            width: 120,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color?.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          // 分组内容骨架
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _VideoItemSkeleton();
            },
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 视频项骨架屏组件（网格布局）
class _VideoItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return CustomCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 缩略图骨架
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 标题骨架
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          const SizedBox(height: 6),
          
          // 副标题骨架
          Container(
            height: 10,
            width: 80,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          const SizedBox(height: 6),
          
          // 元数据骨架
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 10,
                width: 40,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 10,
                width: 30,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 空状态骨架屏组件
class EmptySearchSkeleton extends StatelessWidget {
  const EmptySearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标骨架
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          
          // 文本骨架
          Container(
            height: 20,
            width: 200,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          Container(
            height: 16,
            width: 150,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}