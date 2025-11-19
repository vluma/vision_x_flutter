/// 电影分类枚举
enum MovieCategory {
  /// 电影分类
  movie('电影'),
  
  /// 电视剧分类
  tv('电视剧');

  const MovieCategory(this.label);
  
  /// 分类显示标签
  final String label;
  
  @override
  String toString() => label;
}

/// 筛选条件模型
class FilterCriteria {
  /// 分类 (电影/电视剧)
  final MovieCategory category;

  /// 来源标签
  final String source;

  /// 排序方式
  final String sort;

  FilterCriteria({
    required this.category,
    required this.source,
    required this.sort,
  });

  /// 默认筛选条件
  static FilterCriteria get defaultCriteria => FilterCriteria(
        category: MovieCategory.movie,
        source: '热门',
        sort: 'recommend',
      );

  /// 电影分类的默认来源标签
  static List<String> get movieSources => [
        '热门',
        '最新',
        '经典',
        '豆瓣高分',
        '冷门佳片',
        '华语',
        '欧美',
        '韩国',
        '日本',
        '动作',
        '喜剧',
        '爱情',
        '科幻',
        '悬疑',
        '恐怖',
        '治愈',
      ];

  /// 电视剧分类的默认来源标签
  static List<String> get tvSources => [
        '热门',
        '美剧',
        '英剧',
        '韩剧',
        '日剧',
        '国产剧',
        '港剧',
        '日本动画',
        '综艺',
        '纪录片',
      ];

  /// 排序选项
  static List<Map<String, String>> get sortOptions => [
        {'value': 'recommend', 'label': '推荐'},
        {'value': 'time', 'label': '时间'},
        {'value': 'rank', 'label': '评分'},
      ];

  /// 获取当前分类下的来源标签
  List<String> get currentSources =>
      category == MovieCategory.movie ? movieSources : tvSources;

  /// 创建新的筛选条件实例（用于更新）
  FilterCriteria copyWith({
    MovieCategory? category,
    String? source,
    String? sort,
  }) {
    return FilterCriteria(
      category: category ?? this.category,
      source: source ?? this.source,
      sort: sort ?? this.sort,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterCriteria &&
        other.category == category &&
        other.source == source &&
        other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(category, source, sort);
}