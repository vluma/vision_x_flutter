import 'package:flutter/material.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'package:vision_x_flutter/components/custom_card.dart';


/// 加载骨架屏组件
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: AppSpacing.pageMargin.copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.xl * 2,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 8,
      itemBuilder: (BuildContext context, int index) {
        return _VideoItemSkeleton();
      },
    );
  }
}

/// 视频项骨架屏组件
class _VideoItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                width: double.infinity,
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 60,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}