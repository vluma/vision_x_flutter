import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/data/models/history_record.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';

class HistoryService extends ChangeNotifier {
  static const String _historyKey = 'watch_history';
  static const int _maxHistoryCount = 100; // 最大历史记录数

  static final HistoryService _instance = HistoryService._internal();
  
  // 添加一个简单的回调列表
  static final List<Function()> _refreshCallbacks = [];

  factory HistoryService() => _instance;

  HistoryService._internal();

  // 添加刷新回调
  static void addRefreshCallback(Function() callback) {
    _refreshCallbacks.add(callback);
  }

  // 移除刷新回调
  static void removeRefreshCallback(Function() callback) {
    _refreshCallbacks.remove(callback);
  }

  // 通知所有刷新回调
  static void _notifyRefreshCallbacks() {
    for (final callback in _refreshCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('刷新回调执行失败: $e');
      }
    }
  }

  // 添加观看记录
  Future<void> addHistory(MediaDetail media, Episode episode, int progress, [int? duration]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      // 检查是否已存在相同媒体的记录，如果存在则更新
      final existingIndex = history.indexWhere((record) => record.media.id == media.id);

      final newRecord = HistoryRecord(
        media: media,
        episode: episode,
        watchedAt: DateTime.now(),
        progress: progress,
        duration: duration,
      );

      if (existingIndex >= 0) {
        // 更新现有记录
        history[existingIndex] = newRecord;
      } else {
        // 添加新记录
        history.insert(0, newRecord);

        // 限制历史记录数量
        if (history.length > _maxHistoryCount) {
          history.removeRange(_maxHistoryCount, history.length);
        }
      }

      // 保存到本地存储
      final historyJson = history.map((record) => record.toJson()).toList();
      await prefs.setStringList(
          _historyKey, historyJson.map((item) => jsonEncode(item)).toList());
      
      // 通知监听者数据已更新
      notifyListeners();
      
      // 通知刷新回调
      _notifyRefreshCallbacks();
    } catch (e) {
      debugPrint('添加历史记录失败: $e');
      rethrow;
    }
  }

  // 获取历史记录
  Future<List<HistoryRecord>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = <HistoryRecord>[];
      final historyData = prefs.getStringList(_historyKey) ?? [];

      for (final item in historyData) {
        try {
          final json = jsonDecode(item);
          historyList.add(HistoryRecord.fromJson(json));
        } catch (e) {
          // 忽略解析错误的记录
          debugPrint('解析历史记录失败: $e');
          continue;
        }
      }

      // 按观看时间排序，最新的在最上面
      historyList.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
      
      return historyList;
    } catch (e) {
      debugPrint('获取历史记录失败: $e');
      return [];
    }
  }

  // 删除单个历史记录
  Future<void> removeHistory(HistoryRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      history.removeWhere((item) => item.media.id == record.media.id);

      final historyJson = history.map((record) => record.toJson()).toList();
      await prefs.setStringList(
          _historyKey, historyJson.map((item) => jsonEncode(item)).toList());
      
      // 通知监听者数据已更新
      notifyListeners();
      
      // 通知刷新回调
      _notifyRefreshCallbacks();
    } catch (e) {
      debugPrint('删除历史记录失败: $e');
      rethrow;
    }
  }

  // 清空所有历史记录
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      
      // 通知监听者数据已更新
      notifyListeners();
      
      // 通知刷新回调
      _notifyRefreshCallbacks();
    } catch (e) {
      debugPrint('清空历史记录失败: $e');
      rethrow;
    }
  }

  // 更新观看进度
  Future<void> updateHistoryProgress(
      MediaDetail media, Episode episode, int progress, [int? duration]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      final index = history.indexWhere((record) => record.media.id == media.id);

      if (index >= 0) {
        // 更新观看时间和进度
        history[index] = HistoryRecord(
          media: history[index].media,
          episode: episode, // 更新为当前观看的剧集
          watchedAt: DateTime.now(), // 更新观看时间
          progress: progress, // 更新观看进度
          duration: duration ?? history[index].duration, // 更新视频总时长
        );

        // 保存更新后的数据
        final historyJson = history.map((record) => record.toJson()).toList();
        await prefs.setStringList(
            _historyKey, historyJson.map((item) => jsonEncode(item)).toList());
        
        // 通知监听者数据已更新
        notifyListeners();
        
        // 通知刷新回调
        _notifyRefreshCallbacks();
      }
    } catch (e) {
      debugPrint('更新历史记录进度失败: $e');
      // 不抛出异常，静默处理
    }
  }

  // 强制刷新数据（用于手动触发更新）
  Future<void> refreshData() async {
    try {
      // 重新读取数据并通知监听者
      await getHistory();
      notifyListeners();
      
      // 通知刷新回调
      _notifyRefreshCallbacks();
    } catch (e) {
      debugPrint('刷新历史数据失败: $e');
    }
  }
}