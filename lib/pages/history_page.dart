import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/components/history_item.dart';
import 'package:vision_x_flutter/models/history_record.dart';
import 'package:vision_x_flutter/services/history_service.dart';
import 'package:vision_x_flutter/theme/spacing.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with WidgetsBindingObserver {
  List<HistoryRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addObserver(this);
    
    // 注册刷新回调
    HistoryService.addRefreshCallback(_onHistoryUpdated);
  }

  @override
  void dispose() {
    // 移除刷新回调
    HistoryService.removeRefreshCallback(_onHistoryUpdated);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当应用回到前台时刷新历史记录
    if (state == AppLifecycleState.resumed) {
      _refreshHistory();
    }
  }

  // 历史记录更新时的回调
  void _onHistoryUpdated() {
    debugPrint('历史页面收到更新通知');
    if (mounted) {
      _refreshHistory();
    }
  }

  Future<void> _refreshHistory() async {
    if (!mounted) return;
    
    debugPrint('开始刷新历史数据');
    try {
      final history = await HistoryService().getHistory();
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
        debugPrint('历史数据刷新完成，共${history.length}条记录');
      }
    } catch (e) {
      debugPrint('刷新历史数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载历史记录失败')),
        );
      }
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await HistoryService().getHistory();
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载历史记录失败')),
        );
      }
    }
  }

  void _deleteHistory(HistoryRecord record) async {
    await HistoryService().removeHistory(record);
    _refreshHistory(); // 重新加载数据

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已删除记录')),
      );
    }
  }

  Future<void> _confirmClearAll() async {
    if (_history.isEmpty) return;

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
      _refreshHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已清空所有观看历史')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听HistoryService的变化
    return Consumer<HistoryService>(
      builder: (context, historyService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('观看历史'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: _confirmClearAll,
                tooltip: '清空历史记录',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _history.isEmpty
                  ? Center(
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
                            onPressed: _refreshHistory,
                            icon: const Icon(Icons.refresh),
                            label: const Text('刷新'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: AppSpacing.bottomNavigationBarMargin, left: 10, right: 10),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final record = _history[index];
                          return Dismissible(
                            key: ValueKey(
                                '${record.media.id}_${record.episode.title}_${record.watchedAt.millisecondsSinceEpoch}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 5,
                              ),
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
                            ),
                            // 添加次要背景，模仿iOS风格
                            secondaryBackground: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
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
                            ),
                            // 添加移动时的动画效果
                            movementDuration: const Duration(milliseconds: 200),
                            dismissThresholds: const {
                              DismissDirection.endToStart: 0.3,
                            },
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('确认删除'),
                                  content: Text(
                                      '确定要删除"${record.media.name}"的观看记录吗？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('删除'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              _deleteHistory(record);
                            },
                            child: HistoryItem(
                              record: record,
                              onTap: () {
                                // 跳转到视频播放页面，传递起始位置
                                context.push('/history/video', extra: {
                                  'media': record.media,
                                  'episode': record.episode,
                                  'startPosition':
                                      record.progress, // 传递观看进度作为起始位置
                                });
                              },
                              onDelete: () => _deleteHistory(record),
                            ),
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }
}
