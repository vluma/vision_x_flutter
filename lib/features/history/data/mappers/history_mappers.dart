import 'package:vision_x_flutter/data/models/history_record.dart' as old;
import 'package:vision_x_flutter/features/history/domain/entities/history_record.dart';

/// 历史记录数据映射器
class HistoryMappers {
  /// 将旧的 HistoryRecord 转换为新的 HistoryRecordEntity
  static HistoryRecordEntity toEntity(old.HistoryRecord record) {
    return HistoryRecordEntity(
      media: record.media,
      episode: record.episode,
      watchedAt: record.watchedAt,
      progress: record.progress,
      duration: record.duration,
    );
  }

  /// 将新的 HistoryRecordEntity 转换为旧的 HistoryRecord
  static old.HistoryRecord fromEntity(HistoryRecordEntity entity) {
    return old.HistoryRecord(
      media: entity.media,
      episode: entity.episode,
      watchedAt: entity.watchedAt,
      progress: entity.progress,
      duration: entity.duration,
    );
  }
}