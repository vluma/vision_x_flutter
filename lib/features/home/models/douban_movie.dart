/// 豆瓣电影模型类
/// 用于表示从豆瓣API获取的电影数据
class DoubanMovie {
  /// 电影唯一标识符
  final String id;
  
  /// 电影标题
  final String title;
  
  /// 电影封面图片URL
  final String cover;
  
  /// 电影评分
  final String rate;
  
  /// 电影详情页面URL
  final String url;
  
  /// 是否为新上映电影
  final bool isNew;
  
  /// 是否可播放
  final bool playable;
  
  /// 剧集信息（对于电视剧）
  final String episodesInfo;
  
  /// 封面图片宽度（像素）
  final int coverX;
  
  /// 封面图片高度（像素）
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