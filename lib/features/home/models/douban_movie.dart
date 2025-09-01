class DoubanMovie {
  final String id;
  final String title;
  final String cover;
  final String rate;
  final String url;
  final bool isNew;
  final bool playable;
  final String episodesInfo;
  final int coverX;
  final int coverY;

  DoubanMovie({
    required this.id,
    required this.title,
    required this.cover,
    required this.rate,
    required this.url,
    required this.isNew,
    required this.playable,
    required this.episodesInfo,
    required this.coverX,
    required this.coverY,
  });

  factory DoubanMovie.fromJson(Map<String, dynamic> json) {
    return DoubanMovie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      cover: json['cover'] ?? '',
      rate: json['rate'] ?? '0',
      url: json['url'] ?? '',
      isNew: json['is_new'] ?? false,
      playable: json['playable'] ?? false,
      episodesInfo: json['episodes_info'] ?? '',
      coverX: json['cover_x'] ?? 0,
      coverY: json['cover_y'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover': cover,
      'rate': rate,
      'url': url,
      'is_new': isNew,
      'playable': playable,
      'episodes_info': episodesInfo,
      'cover_x': coverX,
      'cover_y': coverY,
    };
  }
}