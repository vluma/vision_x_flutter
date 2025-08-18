import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/models/history_record.dart';
import 'package:vision_x_flutter/models/media_detail.dart';

class HistoryService {
  static const String _historyKey = 'watch_history';
  static const int _maxHistoryCount = 100; // 最大历史记录数

  static final HistoryService _instance = HistoryService._internal();

  factory HistoryService() => _instance;

  HistoryService._internal();

  // 添加观看记录
  Future<void> addHistory(MediaDetail media, Episode episode, int progress) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // 检查是否已存在相同记录，如果存在则更新
    final existingIndex = history.indexWhere((record) =>
        record.media.id == media.id && record.episode.title == episode.title);

    final newRecord = HistoryRecord(
      media: media,
      episode: episode,
      watchedAt: DateTime.now(),
      progress: progress,
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
  }

  // 获取历史记录
  Future<List<HistoryRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = <HistoryRecord>[];
    final historyData = prefs.getStringList(_historyKey) ?? [];

    for (final item in historyData) {
      try {
        final json = jsonDecode(item);
        historyList.add(HistoryRecord.fromJson(json));
      } catch (e) {
        // 忽略解析错误的记录
        continue;
      }
    }

    return historyList;
  }

  // 删除单个历史记录
  Future<void> removeHistory(HistoryRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.removeWhere((item) =>
        item.media.id == record.media.id &&
        item.episode.title == record.episode.title &&
        item.watchedAt == record.watchedAt);

    final historyJson = history.map((record) => record.toJson()).toList();
    await prefs.setStringList(
        _historyKey, historyJson.map((item) => jsonEncode(item)).toList());
  }

  // 清空所有历史记录
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // 更新观看进度
  Future<void> updateHistoryProgress(
      MediaDetail media, Episode episode, int progress) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    final index = history.indexWhere((record) =>
        record.media.id == media.id && record.episode.title == episode.title);

    if (index >= 0) {
      // 更新观看时间和进度
      history[index] = HistoryRecord(
        media: history[index].media,
        episode: history[index].episode,
        watchedAt: DateTime.now(), // 更新观看时间
        progress: progress, // 更新观看进度
      );

      // 保存更新后的数据
      final historyJson = history.map((record) => record.toJson()).toList();
      await prefs.setStringList(
          _historyKey, historyJson.map((item) => jsonEncode(item)).toList());
    }
  }
}