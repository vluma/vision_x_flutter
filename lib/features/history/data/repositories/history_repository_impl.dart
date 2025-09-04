import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/features/history/domain/entities/history_record.dart';
import 'package:vision_x_flutter/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  static const String _historyKey = 'watch_history';
  static const int _maxHistoryCount = 100;

  @override
  Future<List<HistoryRecordEntity>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = <HistoryRecordEntity>[];
      final historyData = prefs.getStringList(_historyKey) ?? [];

      for (final item in historyData) {
        try {
          final json = jsonDecode(item);
          historyList.add(
            HistoryRecordEntity(
              media: MediaDetail.fromJson(json['media']),
              episode: Episode.fromJson(json['episode']),
              watchedAt: DateTime.parse(json['watchedAt']),
              progress: json['progress'] ?? 0,
              duration: json['duration'],
            ),
          );
        } catch (e) {
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

  @override
  Future<void> addHistory(
    MediaDetail media,
    Episode episode,
    int progress, [
    int? duration,
  ]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      // 检查是否已存在相同媒体的记录，如果存在则更新
      final existingIndex =
          history.indexWhere((record) => record.media.id == media.id);

      final newRecord = HistoryRecordEntity(
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
      await _saveHistory(prefs, history);
    } catch (e) {
      debugPrint('添加历史记录失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeHistory(HistoryRecordEntity record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      history.removeWhere((item) => item.media.id == record.media.id);

      await _saveHistory(prefs, history);
    } catch (e) {
      debugPrint('删除历史记录失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('清空历史记录失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateHistoryProgress(
    MediaDetail media,
    Episode episode,
    int progress, [
    int? duration,
  ]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      final index = history.indexWhere((record) => record.media.id == media.id);

      if (index >= 0) {
        // 更新观看时间和进度
        history[index] = HistoryRecordEntity(
          media: history[index].media,
          episode: episode,
          watchedAt: DateTime.now(),
          progress: progress,
          duration: duration ?? history[index].duration,
        );

        await _saveHistory(prefs, history);
      }
    } catch (e) {
      debugPrint('更新历史记录进度失败: $e');
      // 不抛出异常，静默处理
    }
  }

  Future<void> _saveHistory(
      SharedPreferences prefs, List<HistoryRecordEntity> history) async {
    final historyJson = history
        .map((record) => jsonEncode({
              'media': record.media.toJson(),
              'episode': record.episode.toJson(),
              'watchedAt': record.watchedAt.toIso8601String(),
              'progress': record.progress,
              'duration': record.duration,
            }))
        .toList();

    await prefs.setStringList(_historyKey, historyJson);
  }
}
