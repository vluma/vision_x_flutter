import 'package:flutter/material.dart';
import 'package:vision_x_flutter/models/history_record.dart';
import 'package:vision_x_flutter/components/history_item.dart';
import 'package:vision_x_flutter/theme/spacing.dart';

/// 历史记录列表组件
class HistoryList extends StatelessWidget {
  final List<HistoryRecord> history;
  final Future<void> Function() onRefresh;
  final Function(HistoryRecord) onDelete;
  final Function(HistoryRecord) onItemTap;

  const HistoryList({
    super.key,
    required this.history,
    required this.onRefresh,
    required this.onDelete,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: AppSpacing.bottomNavigationBarMargin,
          left: 10,
          right: 10,
        ),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final record = history[index];
          return _buildDismissibleItem(context, record);
        },
      ),
    );
  }

  /// 构建可滑动删除的项目
  Widget _buildDismissibleItem(BuildContext context, HistoryRecord record) {
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
      onDismissed: (direction) => onDelete(record),
      child: HistoryItem(
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
  Future<bool?> _confirmDelete(BuildContext context, HistoryRecord record) {
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