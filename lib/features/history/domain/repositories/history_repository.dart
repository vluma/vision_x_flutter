import 'package:vision_x_flutter/features/history/domain/entities/history_record.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';

/// 历史记录仓库接口
abstract class HistoryRepository {
  /// 获取所有历史记录
  Future<List<HistoryRecordEntity>> getHistory();

  /// 添加或更新历史记录
  Future<void> addHistory(
    MediaDetail media,
    Episode episode,
    int progress, [
    int? duration,
  ]);

  /// 删除单个历史记录
  Future<void> removeHistory(HistoryRecordEntity record);

  /// 清空所有历史记录
  Future<void> clearHistory();

  /// 更新观看进度
  Future<void> updateHistoryProgress(
    MediaDetail media,
    Episode episode,
    int progress, [
    int? duration,
  ]);
}