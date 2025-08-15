class MediaDetail {
  final int id;
  final String? name;
  final String? subtitle;
  final String? type;
  final String? category;
  final String? year;
  final String? area;
  final String? language;
  final String? duration;
  final String? state;
  final String? remarks;
  final String? version;
  final String? actors;
  final String? director;
  final String? writer;
  final String? description;
  final String? content;
  final String? poster;
  final String? posterThumb;
  final String? posterSlide;
  final String? posterScreenshot;
  final String? playUrl;
  final String? playFrom;
  final String? playServer;
  final String? playNote;
  final String? score;
  final int scoreAll;
  final int scoreNum;
  final String? doubanScore;
  final int doubanId;
  final int hits;
  final int hitsDay;
  final int hitsWeek;
  final int hitsMonth;
  final int up;
  final int down;
  final String? time;
  final int timeAdd;
  final String? letter;
  final String? color;
  final String? tag;
  final String? serial;
  final String? tv;
  final String? weekday;
  final String? pubdate;
  final int total;
  final int isEnd;
  final int trysee;
  final String sourceName;
  final String sourceCode;
  final String? apiUrl;
  final bool? hasCover;
  final String? sourceInfo;
  final List<Source> surces;

  MediaDetail({
    required this.id,
    this.name,
    this.subtitle,
    this.type,
    this.category,
    this.year,
    this.area,
    this.language,
    this.duration,
    this.state,
    this.remarks,
    this.version,
    this.actors,
    this.director,
    this.writer,
    this.description,
    this.content,
    this.poster,
    this.posterThumb,
    this.posterSlide,
    this.posterScreenshot,
    this.playUrl,
    this.playFrom,
    this.playServer,
    this.playNote,
    this.score,
    required this.scoreAll,
    required this.scoreNum,
    this.doubanScore,
    required this.doubanId,
    required this.hits,
    required this.hitsDay,
    required this.hitsWeek,
    required this.hitsMonth,
    required this.up,
    required this.down,
    this.time,
    required this.timeAdd,
    this.letter,
    this.color,
    this.tag,
    this.serial,
    this.tv,
    this.weekday,
    this.pubdate,
    required this.total,
    required this.isEnd,
    required this.trysee,
    required this.sourceName,
    required this.sourceCode,
    this.apiUrl,
    this.hasCover,
    this.sourceInfo,
    required this.surces,
  });

  factory MediaDetail.fromJson(Map<String, dynamic> json) {
    var surcesList = <Source>[];
    if (json['surces'] != null) {
      surcesList = (json['surces'] as List)
          .map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return MediaDetail(
      id: json['id'] ?? 0,
      name: json['name'],
      subtitle: json['subtitle'],
      type: json['type'],
      category: json['category'],
      year: json['year'],
      area: json['area'],
      language: json['language'],
      duration: json['duration'],
      state: json['state'],
      remarks: json['remarks'],
      version: json['version'],
      actors: json['actors'],
      director: json['director'],
      writer: json['writer'],
      description: json['description'],
      content: json['content'],
      poster: json['poster'],
      posterThumb: json['posterThumb'],
      posterSlide: json['posterSlide'],
      posterScreenshot: json['posterScreenshot'],
      playUrl: json['playUrl'],
      playFrom: json['playFrom'],
      playServer: json['playServer'],
      playNote: json['playNote'],
      score: json['score'],
      scoreAll: json['scoreAll'] ?? 0,
      scoreNum: json['scoreNum'] ?? 0,
      doubanScore: json['doubanScore'],
      doubanId: json['doubanId'] ?? 0,
      hits: json['hits'] ?? 0,
      hitsDay: json['hitsDay'] ?? 0,
      hitsWeek: json['hitsWeek'] ?? 0,
      hitsMonth: json['hitsMonth'] ?? 0,
      up: json['up'] ?? 0,
      down: json['down'] ?? 0,
      time: json['time'],
      timeAdd: json['timeAdd'] ?? 0,
      letter: json['letter'],
      color: json['color'],
      tag: json['tag'],
      serial: json['serial'],
      tv: json['tv'],
      weekday: json['weekday'],
      pubdate: json['pubdate'],
      total: json['total'] ?? 0,
      isEnd: json['isEnd'] ?? 0,
      trysee: json['trysee'] ?? 0,
      sourceName: json['sourceName'] ?? '',
      sourceCode: json['sourceCode'] ?? '',
      apiUrl: json['apiUrl'],
      hasCover: json['hasCover'],
      sourceInfo: json['sourceInfo'],
      surces: surcesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'type': type,
      'category': category,
      'year': year,
      'area': area,
      'language': language,
      'duration': duration,
      'state': state,
      'remarks': remarks,
      'version': version,
      'actors': actors,
      'director': director,
      'writer': writer,
      'description': description,
      'content': content,
      'poster': poster,
      'posterThumb': posterThumb,
      'posterSlide': posterSlide,
      'posterScreenshot': posterScreenshot,
      'playUrl': playUrl,
      'playFrom': playFrom,
      'playServer': playServer,
      'playNote': playNote,
      'score': score,
      'scoreAll': scoreAll,
      'scoreNum': scoreNum,
      'doubanScore': doubanScore,
      'doubanId': doubanId,
      'hits': hits,
      'hitsDay': hitsDay,
      'hitsWeek': hitsWeek,
      'hitsMonth': hitsMonth,
      'up': up,
      'down': down,
      'time': time,
      'timeAdd': timeAdd,
      'letter': letter,
      'color': color,
      'tag': tag,
      'serial': serial,
      'tv': tv,
      'weekday': weekday,
      'pubdate': pubdate,
      'total': total,
      'isEnd': isEnd,
      'trysee': trysee,
      'sourceName': sourceName,
      'sourceCode': sourceCode,
      'apiUrl': apiUrl,
      'hasCover': hasCover,
      'sourceInfo': sourceInfo,
      'surces': surces.map((e) => e.toJson()).toList(),
    };
  }
}

class Source {
  final String name;
  final List<Episode> episodes;

  Source({
    required this.name,
    required this.episodes,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    var episodesList = <Episode>[];
    if (json['episodes'] != null) {
      episodesList = (json['episodes'] as List)
          .map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Source(
      name: json['name'] ?? '',
      episodes: episodesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}

class Episode {
  final String title;
  final String url;
  final int? index;
  final String type;

  Episode({
    required this.title,
    required this.url,
    this.index,
    required this.type,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      index: json['index'],
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'index': index,
      'type': type,
    };
  }
}