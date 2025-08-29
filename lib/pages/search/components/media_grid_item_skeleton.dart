import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vision_x_flutter/components/custom_card.dart';

class MediaGridItemSkeleton extends StatefulWidget {
  const MediaGridItemSkeleton({super.key});

  @override
  State<MediaGridItemSkeleton> createState() => _MediaGridItemSkeletonState();
}

class _MediaGridItemSkeletonState extends State<MediaGridItemSkeleton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 100,
            margin: const EdgeInsets.fromLTRB(6, 6, 12, 6),
            decoration: BoxDecoration(
              color: theme.cardTheme.color?.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSkeletonItem(14, double.infinity, theme),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(12, 100, theme),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(10, 70, theme),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(10, 40, theme),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(10, double.infinity, theme),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(10, double.infinity * 0.6, theme),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSkeletonItem(9, 50, theme),
                      _buildSkeletonItem(10, 20, theme),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonItem(double height, double width, ThemeData theme) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.cardTheme.color?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(3),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).custom(
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        final alpha = 0.3 + (value * 0.3);
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: theme.cardTheme.color?.withOpacity(alpha),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}