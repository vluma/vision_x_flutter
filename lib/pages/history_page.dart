import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/components/history_item.dart';
import 'package:vision_x_flutter/models/history_record.dart';
import 'package:vision_x_flutter/services/history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with WidgetsBindingObserver {
  List<HistoryRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 页面每次构建时都刷新历史记录（例如从其他页面返回时）
    _refreshHistory();
  }

  Future<void> _refreshHistory() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('观看历史'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // 清空所有历史记录
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认清空'),
                    content: const Text('确定要清空所有观看历史吗？'),
                    actions: [
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          HistoryService().clearHistory();
                          _refreshHistory();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Text('暂无观看历史'),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final record = _history[index];
                    return HistoryItem(
                      record: record,
                      onTap: () {
                        // 跳转到视频播放页面，传递起始位置
                        context.push('/history/video', extra: {
                          'media': record.media,
                          'episode': record.episode,
                          'startPosition': record.progress, // 传递观看进度作为起始位置
                        });
                      },
                      onDelete: () => _deleteHistory(record),
                    );
                  },
                ),
    );
  }
}