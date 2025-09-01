import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/history/presentation/providers/history_providers.dart';

/// 空历史记录状态组件 - Riverpod版本
class EmptyHistory extends ConsumerWidget {
  final Future<void> Function() onRefresh;

  const EmptyHistory({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无观看历史',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            '观看的影片会显示在这里',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(historyNotifierProvider.notifier).refreshHistory();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }
}