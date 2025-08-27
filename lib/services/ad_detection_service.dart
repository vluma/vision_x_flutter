import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'hls_parser_service.dart';

/// 智能广告检测服务
class AdDetectionService {
  static final AdDetectionService _instance = AdDetectionService._internal();
  factory AdDetectionService() => _instance;
  AdDetectionService._internal();

  final Dio _dio = Dio();

  /// 广告检测配置
  static const Map<String, dynamic> _config = {
    'durationThreshold': 30, // 短片段阈值（秒）
    'patternThreshold': 0.8, // 相似度阈值
    'urlPatterns': [
      r'ad[s]?',
      r'commercial',
      r'sponsor',
      r'promo',
      r'广告',
      r'赞助',
      r'推广',
      r'商业',
      r'宣传',
      r'banner',
      r'interstitial',
      r'preroll',
      r'midroll',
      r'postroll',
    ],
    'titlePatterns': [
      r'广告',
      r'赞助',
      r'推广',
      r'商业',
      r'宣传',
      r'AD',
      r'SPONSOR',
      r'PROMO',
    ],
    'contentAnalysis': {
      'enabled': true,
      'sampleSize': 1024, // 分析样本大小（字节）
      'timeout': 5000, // 超时时间（毫秒）
    },
  };

  /// 检测片段是否为广告
  Future<AdDetectionResult> detectAd(HlsSegment segment) async {
    final scores = <String, double>{};
    
    // 1. URL 模式检测
    scores['url'] = _detectUrlPattern(segment.url);
    
    // 2. 标题模式检测
    if (segment.title != null) {
      scores['title'] = _detectTitlePattern(segment.title!);
    }
    
    // 3. 时长检测
    scores['duration'] = _detectDurationPattern(segment.duration);
    
    // 4. 内容分析（可选，需要下载片段头部进行分析）
    if (_config['contentAnalysis']['enabled']) {
      try {
        scores['content'] = await _analyzeContent(segment.url);
      } catch (e) {
        // 内容分析失败，不影响其他检测
        scores['content'] = 0.0;
      }
    }
    
    // 5. 计算综合得分
    final totalScore = _calculateTotalScore(scores);
    
    // 6. 判断是否为广告
    final isAd = totalScore >= _config['patternThreshold'];
    
    return AdDetectionResult(
      isAd: isAd,
      score: totalScore,
      details: scores,
      segment: segment,
    );
  }

  /// URL 模式检测
  double _detectUrlPattern(String url) {
    final urlLower = url.toLowerCase();
    double maxScore = 0.0;
    
    for (final pattern in _config['urlPatterns']) {
      final regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(urlLower)) {
        // 计算匹配强度
        final matches = regex.allMatches(urlLower);
        final score = matches.length / urlLower.length;
        maxScore = max(maxScore, score);
      }
    }
    
    return maxScore;
  }

  /// 标题模式检测
  double _detectTitlePattern(String title) {
    final titleLower = title.toLowerCase();
    double maxScore = 0.0;
    
    for (final pattern in _config['titlePatterns']) {
      final regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(titleLower)) {
        final matches = regex.allMatches(titleLower);
        final score = matches.length / titleLower.length;
        maxScore = max(maxScore, score);
      }
    }
    
    return maxScore;
  }

  /// 时长模式检测
  double _detectDurationPattern(double duration) {
    // 广告通常较短，但也有例外
    if (duration <= _config['durationThreshold']) {
      return 0.7; // 短片段可能是广告
    } else if (duration <= 60) {
      return 0.3; // 中等长度，可能性较低
    } else {
      return 0.1; // 长片段，不太可能是广告
    }
  }

  /// 内容分析
  Future<double> _analyzeContent(String url) async {
    try {
      // 只下载文件头部进行分析
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Range': 'bytes=0-${_config['contentAnalysis']['sampleSize'] - 1}'},
          receiveTimeout: Duration(milliseconds: _config['contentAnalysis']['timeout']),
        ),
      );
      
      final bytes = response.data as List<int>;
      return _analyzeBytes(bytes);
    } catch (e) {
      // 分析失败，返回中性分数
      return 0.5;
    }
  }

  /// 字节分析
  double _analyzeBytes(List<int> bytes) {
    if (bytes.isEmpty) return 0.5;
    
    // 1. 检查文件头（视频格式检测）
    final header = bytes.take(16).toList();
    final headerHex = header.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    
    // 检查是否为常见的视频格式
    final videoFormats = [
      '66747970', // MP4
      '000001',   // MPEG
      '474e55',   // FLV
      '52494646', // AVI
    ];
    
    bool isVideoFormat = false;
    for (final format in videoFormats) {
      if (headerHex.startsWith(format)) {
        isVideoFormat = true;
        break;
      }
    }
    
    if (!isVideoFormat) {
      return 0.8; // 非视频格式，可能是广告
    }
    
    // 2. 检查文件大小模式
    final size = bytes.length;
    if (size < 1024) {
      return 0.6; // 文件太小，可能是广告
    }
    
    // 3. 检查字节模式（简单的熵分析）
    final entropy = _calculateEntropy(bytes);
    if (entropy < 0.3) {
      return 0.7; // 低熵，可能是广告或损坏文件
    }
    
    return 0.2; // 看起来像正常视频
  }

  /// 计算熵
  double _calculateEntropy(List<int> bytes) {
    if (bytes.isEmpty) return 0.0;
    
    final frequency = <int, int>{};
    for (final byte in bytes) {
      frequency[byte] = (frequency[byte] ?? 0) + 1;
    }
    
    double entropy = 0.0;
    final total = bytes.length;
    
    for (final count in frequency.values) {
      final probability = count / total;
      entropy -= probability * log(probability) / log(2);
    }
    
    return entropy / 8.0; // 归一化到 0-1
  }

  /// 计算综合得分
  double _calculateTotalScore(Map<String, double> scores) {
    if (scores.isEmpty) return 0.0;
    
    // 加权平均
    final weights = {
      'url': 0.4,
      'title': 0.3,
      'duration': 0.2,
      'content': 0.1,
    };
    
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    for (final entry in scores.entries) {
      final weight = weights[entry.key] ?? 0.1;
      totalScore += entry.value * weight;
      totalWeight += weight;
    }
    
    return totalWeight > 0 ? totalScore / totalWeight : 0.0;
  }

  /// 批量检测
  Future<List<AdDetectionResult>> detectAds(List<HlsSegment> segments) async {
    final results = <AdDetectionResult>[];
    
    for (final segment in segments) {
      final result = await detectAd(segment);
      results.add(result);
    }
    
    return results;
  }

  /// 获取检测统计
  AdDetectionStats getStats(List<AdDetectionResult> results) {
    final ads = results.where((r) => r.isAd).toList();
    final nonAds = results.where((r) => !r.isAd).toList();
    
    return AdDetectionStats(
      totalSegments: results.length,
      adSegments: ads.length,
      nonAdSegments: nonAds.length,
      adPercentage: results.isNotEmpty ? ads.length / results.length : 0.0,
      averageAdScore: ads.isNotEmpty ? ads.map((r) => r.score).reduce((a, b) => a + b) / ads.length : 0.0,
      averageNonAdScore: nonAds.isNotEmpty ? nonAds.map((r) => r.score).reduce((a, b) => a + b) / nonAds.length : 0.0,
    );
  }

  /// 更新检测规则
  void updateConfig(Map<String, dynamic> newConfig) {
    // 这里可以实现动态配置更新
    // 为了简化，我们暂时不实现这个功能
  }
}

/// 广告检测结果
class AdDetectionResult {
  final bool isAd;
  final double score;
  final Map<String, double> details;
  final HlsSegment segment;

  AdDetectionResult({
    required this.isAd,
    required this.score,
    required this.details,
    required this.segment,
  });

  @override
  String toString() {
    return 'AdDetectionResult(isAd: $isAd, score: ${score.toStringAsFixed(2)}, segment: ${segment.url})';
  }
}

/// 广告检测统计
class AdDetectionStats {
  final int totalSegments;
  final int adSegments;
  final int nonAdSegments;
  final double adPercentage;
  final double averageAdScore;
  final double averageNonAdScore;

  AdDetectionStats({
    required this.totalSegments,
    required this.adSegments,
    required this.nonAdSegments,
    required this.adPercentage,
    required this.averageAdScore,
    required this.averageNonAdScore,
  });

  @override
  String toString() {
    return 'AdDetectionStats('
        'total: $totalSegments, '
        'ads: $adSegments (${(adPercentage * 100).toStringAsFixed(1)}%), '
        'avgAdScore: ${averageAdScore.toStringAsFixed(2)}, '
        'avgNonAdScore: ${averageNonAdScore.toStringAsFixed(2)})';
  }
}


