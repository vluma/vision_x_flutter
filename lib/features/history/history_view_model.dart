import 'package:flutter/material.dart';
import 'package:vision_x_flutter/data/models/history_record.dart';
import 'package:vision_x_flutter/services/history_service.dart';

/// 历史记录页面状态管理类
class HistoryViewModel extends ChangeNotifier {
  List<HistoryRecord> _history = [];
  bool _isLoading = true;
  DateTime? _lastRefreshTime;

  List<HistoryRecord> get history => _history;
  bool get isLoading => _isLoading;

  HistoryViewModel() {
    _initialize();
  }

  /// 初始化数据
  Future<void> _initialize() async {
    await _loadHistory();
    _setupListeners();
  }

  /// 设置监听器
  void _setupListeners() {
    HistoryService.addRefreshCallback(_onHistoryUpdated);
  }

  /// 历史记录更新回调
  void _onHistoryUpdated() {
    if (_shouldRefresh()) {
      refreshHistory();
    }
  }

  /// 判断是否需要刷新（防抖机制）
  bool _shouldRefresh() {
    final now = DateTime.now();
    if (_lastRefreshTime == null) return true;
    
    // 1秒防抖间隔
    return now.difference(_lastRefreshTime!) > const Duration(seconds: 1);
  }

  /// 加载历史记录
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final history = await HistoryService().getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
        _lastRefreshTime = DateTime.now();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      rethrow;
    }
  }

  /// 刷新历史记录
  Future<void> refreshHistory() async {
    if (!_shouldRefresh()) return;

    setState(() => _isLoading = true);

    try {
      final history = await HistoryService().getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
        _lastRefreshTime = DateTime.now();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      rethrow;
    }
  }

  /// 删除单个历史记录
  Future<void> deleteHistory(HistoryRecord record) async {
    try {
      await HistoryService().removeHistory(record);
      await refreshHistory();
    } catch (e) {
      rethrow;
    }
  }

  /// 确认清空所有历史记录
  Future<void> confirmClearAll() async {
    if (_history.isEmpty) return;

    // 对话框需要在UI层面处理，这里只提供清空功能
    // 实际项目中可以通过其他方式触发对话框
    await HistoryService().clearHistory();
    await refreshHistory();
  }

  /// 辅助方法：更新状态并通知监听器
  void setState(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  @override
  void dispose() {
    HistoryService.removeRefreshCallback(_onHistoryUpdated);
    super.dispose();
  }
}