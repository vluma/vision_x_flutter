import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/features/history/presentation/providers/history_providers.dart';
import 'package:vision_x_flutter/features/history/presentation/widgets/history_list.dart';
import 'package:vision_x_flutter/features/history/presentation/widgets/empty_history.dart';
import 'package:vision_x_flutter/features/history/presentation/widgets/loading_indicator.dart';

/// 历史记录页面 - 使用Riverpod重构
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // 页面初始化时自动加载历史记录
    Future.microtask(() {
      ref.read(historyNotifierProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听历史记录状态变化
    final historyState = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('观看历史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _confirmClearAll(context, ref),
            tooltip: '清空历史记录',
          ),
        ],
      ),
      body: _buildContent(context, ref, historyState),
    );
  }

  /// 构建内容区域
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    HistoryState historyState,
  ) {
    if (historyState.isLoading && historyState.records.isEmpty) {
      return const LoadingIndicator();
    }

    if (historyState.error != null) {
      return _buildErrorState(context, ref, historyState.error!);
    }

    if (historyState.records.isEmpty) {
      return EmptyHistory(
        onRefresh: () => ref.read(historyNotifierProvider.notifier).refreshHistory(),
      );
    }

    return HistoryList(
      records: historyState.records,
      onRefresh: () => ref.read(historyNotifierProvider.notifier).refreshHistory(),
      onDelete: (record) => ref.read(historyNotifierProvider.notifier).removeHistory(record),
      onItemTap: (record) {
        context.push('/history/video', extra: {
          'media': record.media,
          'episode': record.episode,
          'startPosition': record.progress,
        });
      },
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败: $error',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(historyNotifierProvider.notifier).clearError();
              ref.read(historyNotifierProvider.notifier).refreshHistory();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 确认清空所有历史记录
  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final historyState = ref.read(historyNotifierProvider);
    if (historyState.records.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有观看历史吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(historyNotifierProvider.notifier).clearHistory();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已清空所有观看历史')),
        );
      }
    }
  }
}