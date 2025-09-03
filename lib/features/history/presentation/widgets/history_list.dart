import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'package:vision_x_flutter/features/history/domain/entities/history_record.dart';
import 'package:vision_x_flutter/features/history/presentation/providers/history_providers.dart';
import 'package:vision_x_flutter/features/history/presentation/widgets/history_item_adapter.dart';

/// 历史记录列表组件 - Riverpod版本
class HistoryList extends ConsumerWidget {
  final List<HistoryRecordEntity> records;
  final Future<void> Function() onRefresh;
  final Function(HistoryRecordEntity) onDelete;
  final Function(HistoryRecordEntity) onItemTap;

  const HistoryList({
    super.key,
    required this.records,
    required this.onRefresh,
    required this.onDelete,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: AppSpacing.bottomNavigationBarMargin,
          left: 10,
          right: 10,
        ),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return _buildDismissibleItem(context, ref, record);
        },
      ),
    );
  }

  /// 构建可滑动删除的项目
  Widget _buildDismissibleItem(
    BuildContext context,
    WidgetRef ref,
    HistoryRecordEntity record,
  ) {
    return Dismissible(
      key: ValueKey(
          '${record.media.id}_${record.episode.title}_${record.watchedAt.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(context),
      secondaryBackground: _buildDeleteBackground(context),
      movementDuration: const Duration(milliseconds: 200),
      dismissThresholds: const {
        DismissDirection.endToStart: 0.3,
      },
      confirmDismiss: (direction) => _confirmDelete(context, record),
      onDismissed: (direction) async {
        await ref.read(historyNotifierProvider.notifier).removeHistory(record);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已删除 "${record.media.name}" 的观看记录'),
              action: SnackBarAction(
                label: '撤销',
                onPressed: () {
                  // 重新添加记录
                  ref.read(historyNotifierProvider.notifier).addHistory(
                        record.media,
                        record.episode,
                        record.progress,
                        record.duration,
                      );
                },
              ),
            ),
          );
        }
      },
      child: HistoryItemAdapter(
        record: record,
        onTap: () => onItemTap(record),
        onDelete: () => onDelete(record),
      ),
    );
  }

  /// 构建删除背景
  Widget _buildDeleteBackground(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Icon(
        Icons.delete,
        color: Theme.of(context).colorScheme.onError,
      ),
    );
  }

  /// 确认删除对话框
  Future<bool?> _confirmDelete(
    BuildContext context,
    HistoryRecordEntity record,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${record.media.name}"的观看记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
