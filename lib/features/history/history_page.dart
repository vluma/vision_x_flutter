import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/features/history/history_view_model.dart';
import 'package:vision_x_flutter/features/history/widgets/history_list.dart';
import 'package:vision_x_flutter/features/history/widgets/empty_history.dart';
import 'package:vision_x_flutter/features/history/widgets/loading_indicator.dart';
import 'package:vision_x_flutter/services/history_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryViewModel(),
      child: const _HistoryPageContent(),
    );
  }
}

class _HistoryPageContent extends StatelessWidget {
  const _HistoryPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('观看历史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _confirmClearAll(context, viewModel),
            tooltip: '清空历史记录',
          ),
        ],
      ),
      body: _buildContent(context, viewModel),
    );
  }

  /// 确认清空所有历史记录
  Future<void> _confirmClearAll(BuildContext context, HistoryViewModel viewModel) async {
    if (viewModel.history.isEmpty) return;

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
      await HistoryService().clearHistory();
      await viewModel.refreshHistory();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已清空所有观看历史')),
        );
      }
    }
  }

  Widget _buildContent(BuildContext context, HistoryViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingIndicator();
    }

    if (viewModel.history.isEmpty) {
      return EmptyHistory(onRefresh: viewModel.refreshHistory);
    }

    return HistoryList(
      history: viewModel.history,
      onRefresh: viewModel.refreshHistory,
      onDelete: viewModel.deleteHistory,
      onItemTap: (record) {
        context.push('/history/video', extra: {
          'media': record.media,
          'episode': record.episode,
          'startPosition': record.progress,
        });
      },
    );
  }
}