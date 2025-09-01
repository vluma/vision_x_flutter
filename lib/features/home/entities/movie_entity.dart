/// 电影实体类
/// 定义电影数据的核心结构

class MovieEntity {
  final String id;
  final String title;
  final String poster;
  final double rating;
  final int year;
  final String? director;
  final List<String>? casts;
  final String? genre;
  final String? description;

  const MovieEntity({
    required this.id,
    required this.title,
    required this.poster,
    required this.rating,
    required this.year,
    this.director,
    this.casts,
    this.genre,
    this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}