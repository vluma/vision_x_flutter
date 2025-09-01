import 'package:vision_x_flutter/data/models/media_detail.dart';

class HistoryRecordEntity {
  final MediaDetail media;
  final Episode episode;
  final DateTime watchedAt;
  final int progress;
  final int? duration;

  const HistoryRecordEntity({
    required this.media,
    required this.episode,
    required this.watchedAt,
    required this.progress,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'media': media.toJson(),
        'episode': episode.toJson(),
        'watchedAt': watchedAt.toIso8601String(),
        'progress': progress,
        'duration': duration,
      };

  factory HistoryRecordEntity.fromJson(Map<String, dynamic> json) =>
      HistoryRecordEntity(
        media: MediaDetail.fromJson(json['media']),
        episode: Episode.fromJson(json['episode']),
        watchedAt: DateTime.parse(json['watchedAt']),
        progress: json['progress'],
        duration: json['duration'],
      );

  HistoryRecordEntity copyWith({
    MediaDetail? media,
    Episode? episode,
    DateTime? watchedAt,
    int? progress,
    int? duration,
  }) {
    return HistoryRecordEntity(
      media: media ?? this.media,
      episode: episode ?? this.episode,
      watchedAt: watchedAt ?? this.watchedAt,
      progress: progress ?? this.progress,
      duration: duration ?? this.duration,
    );
  }
}