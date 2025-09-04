import 'package:vision_x_flutter/shared/models/media_detail.dart';

class HistoryRecord {
  final MediaDetail media;
  final Episode episode;
  final DateTime watchedAt;
  final int progress; // 观看进度（秒）
  final int? duration; // 视频总时长（秒）

  HistoryRecord({
    required this.media,
    required this.episode,
    required this.watchedAt,
    required this.progress,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'media': media.toJson(),
      'episode': episode.toJson(),
      'watchedAt': watchedAt.toIso8601String(),
      'progress': progress,
      'duration': duration,
    };
  }

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      media: MediaDetail.fromJson(json['media']),
      episode: Episode.fromJson(json['episode']),
      watchedAt: DateTime.parse(json['watchedAt']),
      progress: json['progress'] ?? 0,
      duration: json['duration'],
    );
  }
}
