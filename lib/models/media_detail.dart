import 'package:flutter/foundation.dart';
import 'dart:convert';

// 媒体详情数据模型
class MediaDetail {
  // 基本信息
  final int id; // 媒体ID
  final String? name; // 媒体名称
  final String? subtitle; // 副标题
  final String? type; // 类型
  final String? category; // 分类
  final String? year; // 年份
  final String? area; // 地区
  final String? language; // 语言
  final String? duration; // 时长
  final String? state; // 状态
  final String? remarks; // 备注
  final String? version; // 版本

  // 人员信息
  final String? actors; // 演员
  final String? director; // 导演
  final String? writer; // 编剧

  // 内容信息
  final String? description; // 描述
  final String? content; // 内容

  // 海报信息
  final String? poster; // 海报
  final String? posterThumb; // 缩略海报
  final String? posterSlide; // 幻灯片海报
  final String? posterScreenshot; // 截图海报

  // 播放信息
  final String? playUrl; // 播放地址
  final String? playFrom; // 播放来源
  final String? playServer; // 播放服务器
  final String? playNote; // 播放备注

  // 评分信息
  final String? score; // 评分
  final int scoreAll; // 总评分
  final int scoreNum; // 评分人数
  final String? doubanScore; // 豆瓣评分
  final int doubanId; // 豆瓣ID

  // 统计信息
  final int hits; // 总播放量
  final int hitsDay; // 日播放量
  final int hitsWeek; // 周播放量
  final int hitsMonth; // 月播放量
  final int up; // 点赞数
  final int down; // 点踩数

  // 时间信息
  final String? time; // 时间
  final int timeAdd; // 添加时间

  // 其他信息
  final String? letter; // 字母
  final String? color; // 颜色
  final String? tag; // 标签
  final String? serial; // 系列
  final String? tv; // 电视台
  final String? weekday; // 星期
  final String? pubdate; // 发布日期

  // 剧集信息
  final int total; // 总集数
  final int isEnd; // 是否完结
  final int trysee; // 试看

  // 来源信息
  final String sourceName; // 来源名称
  final String sourceCode; // 来源代码
  final String? apiUrl; // API地址
  final bool? hasCover; // 是否有封面
  final String? sourceInfo; // 来源信息

  // 数据源列表
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

  // 打印媒体数据用于调试
  void printDebugInfo() {
    debugPrint('=== 媒体数据调试信息 ===');
    debugPrint('ID: $id');
    debugPrint('名称: $name');
    debugPrint('副标题: $subtitle');
    debugPrint('类型: $type');
    debugPrint('分类: $category');
    debugPrint('年份: $year');
    debugPrint('地区: $area');
    debugPrint('语言: $language');
    debugPrint('时长: $duration');
    debugPrint('状态: $state');
    debugPrint('备注: $remarks');
    debugPrint('版本: $version');
    debugPrint('演员: $actors');
    debugPrint('导演: $director');
    debugPrint('编剧: $writer');
    debugPrint('描述: $description');
    debugPrint('内容: $content');

    // 添加海报信息打印
    debugPrint('海报: $poster');
    debugPrint('缩略海报: $posterThumb');
    debugPrint('幻灯片海报: $posterSlide');
    debugPrint('截图海报: $posterScreenshot');

    // 添加播放信息打印
    debugPrint('播放地址: $playUrl');
    debugPrint('播放来源: $playFrom');
    debugPrint('播放服务器: $playServer');
    debugPrint('播放备注: $playNote');

    debugPrint('评分: $score');
    debugPrint('总评分: $scoreAll');
    debugPrint('评分人数: $scoreNum');
    debugPrint('豆瓣评分: $doubanScore');
    debugPrint('豆瓣ID: $doubanId');
    debugPrint('播放量: $hits');
    debugPrint('日播放量: $hitsDay');
    debugPrint('周播放量: $hitsWeek');
    debugPrint('月播放量: $hitsMonth');
    debugPrint('点赞数: $up');
    debugPrint('点踩数: $down');
    debugPrint('时间: $time');
    debugPrint('添加时间: $timeAdd');
    debugPrint('字母: $letter');
    debugPrint('颜色: $color');
    debugPrint('标签: $tag');
    debugPrint('系列: $serial');
    debugPrint('电视台: $tv');
    debugPrint('星期: $weekday');
    debugPrint('发布日期: $pubdate');
    debugPrint('剧集总数: $total');
    debugPrint('是否完结: $isEnd');
    debugPrint('试看: $trysee');
    debugPrint('来源名称: $sourceName');
    debugPrint('来源代码: $sourceCode');
    debugPrint('API地址: $apiUrl');
    debugPrint('是否有封面: $hasCover');
    debugPrint('来源信息: $sourceInfo');
    debugPrint('=== 数据源信息 ===');
    for (int i = 0; i < surces.length; i++) {
      final source = surces[i];
      debugPrint('数据源 $i: ${source.name}');
      debugPrint('  剧集数量: ${source.episodes.length}');
      for (int j = 0; j < source.episodes.length; j++) {
        final episode = source.episodes[j];
        debugPrint('    剧集 $j: ${episode.title} (${episode.url})');
      }
    }
  }

  /// 从API原始数据映射到MediaDetail对象
  /// [item] 原始API数据项
  /// [apiName] API名称
  /// [apiCode] API代码
  /// [apiUrl] API地址
  static MediaDetail fromApiData(
      dynamic item, String apiName, String apiCode, String apiUrl) {
    final sources = _parseEpisodes(item['vod_play_url']?.toString() ?? '');

    return MediaDetail(
      id: _parseInt(item['vod_id']),
      name: item['vod_name']?.toString(),
      subtitle: item['vod_sub']?.toString(),
      type: item['type_name']?.toString(),
      category: item['vod_class']?.toString(),
      year: item['vod_year']?.toString(),
      area: item['vod_area']?.toString(),
      language: item['vod_lang']?.toString(),
      duration: item['vod_duration']?.toString(),
      state: item['vod_state']?.toString(),
      remarks: item['vod_remarks']?.toString(),
      version: item['vod_version']?.toString(),
      actors: item['vod_actor']?.toString(),
      director: item['vod_director']?.toString(),
      writer: item['vod_writer']?.toString(),
      description: item['vod_blurb']?.toString(),
      content: item['vod_content']?.toString(),
      poster: _validateImageUrl(item['vod_pic']?.toString()),
      posterThumb: _validateImageUrl(item['vod_pic_thumb']?.toString()),
      posterSlide: _validateImageUrl(item['vod_pic_slide']?.toString()),
      posterScreenshot: _validateImageUrl(item['vod_pic_screenshot']?.toString()),
      playUrl: item['vod_play_url']?.toString(),
      playFrom: item['vod_play_from']?.toString(),
      playServer: item['vod_play_server']?.toString(),
      playNote: item['vod_play_note']?.toString(),
      score: item['vod_score']?.toString(),
      scoreAll: _parseInt(item['vod_score_all']),
      scoreNum: _parseInt(item['vod_score_num']),
      doubanScore: item['vod_douban_score']?.toString(),
      doubanId: _parseInt(item['vod_douban_id']),
      hits: _parseInt(item['vod_hits']),
      hitsDay: _parseInt(item['vod_hits_day']),
      hitsWeek: _parseInt(item['vod_hits_week']),
      hitsMonth: _parseInt(item['vod_hits_month']),
      up: _parseInt(item['vod_up']),
      down: _parseInt(item['vod_down']),
      time: item['vod极速资源_time']?.toString(),
      timeAdd: _parseInt(item['vod_time_add']),
      letter: item['vod_letter']?.toString(),
      color: item['vod_color']?.toString(),
      tag: item['vod_tag']?.toString(),
      serial: item['vod_serial']?.toString(),
      tv: item['vod_tv']?.toString(),
      weekday: item['vod_weekday']?.toString(),
      pubdate: item['vod_pubdate']?.toString(),
      total: _parseInt(item['vod_total']),
      isEnd: _parseInt(item['vod_isend']),
      trysee: _parseInt(item['vod_trysee']),
      sourceName: apiName,
      sourceCode: apiCode,
      apiUrl: apiUrl,
      hasCover: item['vod_pic'] != null && item['vod_pic'].toString().startsWith('http'),
      sourceInfo: null,
      surces: sources,
    );
  }

  /// 解析整数值的辅助方法
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// 验证图片URL是否有效
  static String? _validateImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return null;
  }

  /// 解析剧集信息
  static List<Source> _parseEpisodes(String playUrl) {
    if (playUrl.isEmpty) return [];

    try {
      List<Source> sources = [];
      final sourceStrings = playUrl.split(r'$$$');

      for (var sourceStr in sourceStrings) {
        final trimmedSource = sourceStr.trim();
        if (trimmedSource.isEmpty) continue;

        final episodeStrings = trimmedSource.split('#');
        List<Episode> episodes = [];
        String sourceType = 'unknown';

        for (var episodeStr in episodeStrings) {
          final trimmedEpisode = episodeStr.trim();
          if (trimmedEpisode.isEmpty) continue;

          final parts = trimmedEpisode.split(r'$');
          if (parts.length < 2) continue;

          final title = parts[0].trim();
          final url = parts[1].trim();

          if (!url.startsWith('http://') && !url.startsWith('https://')) {
            continue;
          }

          String type = 'unknown';
          if (url.contains('.m3u8')) {
            type = 'm3u8';
          } else if (url.contains('.mp4')) {
            type = 'mp4';
          } else if (url.contains('.flv')) {
            type = 'flv';
          }

          if (sourceType == 'unknown' && type != 'unknown') {
            sourceType = type;
          }

          episodes.add(Episode(
            title: title,
            url: url,
            index: episodes.length,
            type: type,
          ));
        }

        if (episodes.isNotEmpty && sourceType != 'unknown') {
          sources.add(Source(
            name: sourceType,
            episodes: episodes,
          ));
        }
      }

      return sources;
    } catch (e) {
      return [];
    }
  }
}

// 数据源模型
class Source {
  final String name; // 数据源名称
  final List<Episode> episodes; // 剧集列表

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

// 剧集模型
class Episode {
  final String title; // 剧集标题
  final String url; // 播放地址
  final int? index; // 索引
  final String type; // 类型

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
