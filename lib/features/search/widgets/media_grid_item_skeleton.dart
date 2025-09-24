import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vision_x_flutter/shared/widgets/custom_card.dart';

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
          _buildSkeletonItem(
            width: 70,
            height: 100,
            color: theme.cardTheme.color?.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .shimmer(
                duration: 1000.ms,
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
              ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSkeletonItem(
                      height: 14,
                      width: double.infinity,
                      color: theme.cardTheme.color?.withOpacity(0.5)),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(
                      height: 12,
                      width: 100,
                      color: theme.cardTheme.color?.withOpacity(0.5)),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(
                      height: 10,
                      width: 70,
                      color: theme.cardTheme.color?.withOpacity(0.5)),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(
                      height: 10,
                      width: 40,
                      color: theme.cardTheme.color?.withOpacity(0.5)),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(
                      height: 10,
                      width: double.infinity,
                      color: theme.cardTheme.color?.withOpacity(0.5)),
                  const SizedBox(height: 2),
                  _buildSkeletonItem(
                      height: 10,
                      width: double.infinity * 0.6,
                      color: theme.cardTheme.color?.withOpacity(0.5)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSkeletonItem(
                          height: 9,
                          width: 50,
                          color: theme.cardTheme.color?.withOpacity(0.5)),
                      _buildSkeletonItem(
                          height: 10,
                          width: 20,
                          color: theme.cardTheme.color?.withOpacity(0.5)),
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

  Widget _buildSkeletonItem({
    required double height,
    required double width,
    required Color? color,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(3),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .shimmer(
          duration: 1000.ms,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
        );
  }
}
