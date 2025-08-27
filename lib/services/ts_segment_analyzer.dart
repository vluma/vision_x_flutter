import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// TS 片段分析器 - 用于分析 MPEG-TS 文件
class TsSegmentAnalyzer {
  static final TsSegmentAnalyzer _instance = TsSegmentAnalyzer._internal();
  factory TsSegmentAnalyzer() => _instance;
  TsSegmentAnalyzer._internal();

  final Dio _dio = Dio();

  /// TS 包大小 (MPEG-TS 标准包大小)
  static const int tsPacketSize = 188;

  /// 增强分析 TS 片段 - 获取完整的文件数据进行深度分析
  Future<EnhancedTsSegmentAnalysis> analyzeSegmentEnhanced(String url, {int maxSize = 1024 * 1024 * 10}) async {
    try {
      debugPrint('开始增强分析 TS 片段: $url');

      // 下载完整的 TS 片段文件（限制大小以避免内存溢出）
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Range': 'bytes=0-${maxSize - 1}'},
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final bytes = response.data as Uint8List;
      debugPrint('TS 文件大小: ${bytes.length} 字节');

      final basicAnalysis = _analyzeTsData(bytes, url);
      final detailedAnalysis = _analyzeTsDetailed(bytes, url);

      return EnhancedTsSegmentAnalysis(
        basicAnalysis: basicAnalysis,
        detailedAnalysis: detailedAnalysis,
        rawData: bytes,
      );
    } catch (e) {
      debugPrint('TS 片段增强分析失败: $e');
      throw Exception('TS 片段增强分析失败: $e');
    }
  }

  /// 详细分析 TS 数据结构
  TsDetailedAnalysis _analyzeTsDetailed(Uint8List data, String url) {
    final int dataLength = data.length;
    const int syncByte = 0x47;

    // 分析结果
    int totalPackets = 0;
    int validPackets = 0;
    int invalidPackets = 0;
    int scrambledPackets = 0;
    final Map<int, PidInfo> pidInfos = {};
    final List<PacketInfo> packetInfos = [];

    // 包间隙分析
    int consecutiveValidPackets = 0;
    int maxConsecutiveValid = 0;
    int gapCount = 0;

    // 分析每个 TS 包
    for (int i = 0; i <= dataLength - tsPacketSize; i += tsPacketSize) {
      totalPackets++;

      final bool hasSyncByte = data[i] == syncByte;
      final int pid = ((data[i + 1] & 0x1F) << 8) | data[i + 2];
      final int flags = data[i + 3];
      final bool hasPayload = (flags & 0x10) != 0;
      final bool isScrambled = (flags & 0xc0) != 0; // 加密标志
      final bool hasAdaptationField = (flags & 0x20) != 0;

      if (hasSyncByte) {
        validPackets++;
        consecutiveValidPackets++;

        if (consecutiveValidPackets > maxConsecutiveValid) {
          maxConsecutiveValid = consecutiveValidPackets;
        }

        if (isScrambled) {
          scrambledPackets++;
        }

        // 记录 PID 信息
        if (!pidInfos.containsKey(pid)) {
          pidInfos[pid] = PidInfo(
            pid: pid,
            packetCount: 1,
            type: _getPidType(pid),
            firstAppearance: i ~/ tsPacketSize,
          );
        } else {
          final currentCount = pidInfos[pid]!.packetCount;
          pidInfos[pid] = PidInfo(
            pid: pid,
            packetCount: currentCount + 1,
            type: pidInfos[pid]!.type,
            firstAppearance: pidInfos[pid]!.firstAppearance,
          );
        }

        // 记录包信息（只记录前100个包以节省内存）
        if (packetInfos.length < 100) {
          packetInfos.add(PacketInfo(
            index: i ~/ tsPacketSize,
            pid: pid,
            hasPayload: hasPayload,
            isScrambled: isScrambled,
            hasAdaptationField: hasAdaptationField,
            position: i,
          ));
        }
      } else {
        invalidPackets++;
        consecutiveValidPackets = 0;
        gapCount++;
      }
    }

    // 计算统计信息
    final double validityRate = totalPackets > 0 ? (validPackets / totalPackets) * 100 : 0;
    final double averagePacketSize = validPackets > 0 ? dataLength / validPackets : 0;
    final int uniquePids = pidInfos.length;

    // 识别主要流
    PidInfo? videoPid;
    PidInfo? audioPid;
    final List<PidInfo> otherPids = [];

    for (final pidInfo in pidInfos.values) {
      if (pidInfo.type == PidType.video && (videoPid == null || pidInfo.packetCount > videoPid.packetCount)) {
        videoPid = pidInfo;
      } else if (pidInfo.type == PidType.audio && (audioPid == null || pidInfo.packetCount > audioPid.packetCount)) {
        audioPid = pidInfo;
      } else {
        otherPids.add(pidInfo);
      }
    }

    return TsDetailedAnalysis(
      totalPackets: totalPackets,
      validPackets: validPackets,
      invalidPackets: invalidPackets,
      scrambledPackets: scrambledPackets,
      validityRate: validityRate,
      averagePacketSize: averagePacketSize,
      uniquePids: uniquePids,
      pidInfos: pidInfos,
      packetInfos: packetInfos,
      maxConsecutiveValidPackets: maxConsecutiveValid,
      gapCount: gapCount,
      videoPid: videoPid,
      audioPid: audioPid,
      otherPids: otherPids,
    );
  }

  /// 获取 PID 类型
  PidType _getPidType(int pid) {
    if (pid == 0) return PidType.pat;
    if (pid == 1) return PidType.cat;
    if (pid >= 0x20 && pid <= 0x1FFE) {
      // 这里可以根据更多信息来判断是视频还是音频
      // 暂时返回未知类型
      return PidType.unknown;
    }
    if (pid == 0x1FFF) return PidType.nullPacket;
    return PidType.reserved;
  }

  /// 批量增强分析 TS 片段
  Future<List<EnhancedTsSegmentAnalysis>> analyzeSegmentsEnhanced(List<String> urls, {int maxSize = 1024 * 1024 * 10}) async {
    final results = <EnhancedTsSegmentAnalysis>[];

    for (final url in urls) {
      try {
        final analysis = await analyzeSegmentEnhanced(url, maxSize: maxSize);
        results.add(analysis);
      } catch (e) {
        debugPrint('跳过无法增强分析的片段: $url ($e)');
      }
    }

    return results;
  }

  /// 分析 TS 片段
  Future<TsSegmentAnalysis> analyzeSegment(String url, {int sampleSize = 1024 * 10}) async {
    try {
      // 下载 TS 片段的前 N 字节进行分析
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Range': 'bytes=0-${sampleSize - 1}'},
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final bytes = response.data as Uint8List;
      return _analyzeTsData(bytes, url);
    } catch (e) {
      throw Exception('TS 片段分析失败: $e');
    }
  }

  /// 分析 TS 数据
  TsSegmentAnalysis _analyzeTsData(Uint8List data, String url) {
    final int dataLength = data.length;
    int packetCount = 0;
    int validPackets = 0;
    final Set<int> pids = {};
    final Map<int, int> pidPacketCount = {};
    int pcrCount = 0;
    int patCount = 0;
    int pmtCount = 0;

    // MPEG-TS 同步字节
    const int syncByte = 0x47;

    // 分析 TS 包
    for (int i = 0; i <= dataLength - tsPacketSize; i += tsPacketSize) {
      // 检查同步字节
      if (data[i] != syncByte) {
        continue;
      }

      packetCount++;

      // 解析 TS 包头
      final int pid = ((data[i + 1] & 0x1F) << 8) | data[i + 2];
      final int flags = data[i + 3];

      pids.add(pid);
      pidPacketCount[pid] = (pidPacketCount[pid] ?? 0) + 1;

      // 检查是否有有效负载
      if ((flags & 0x10) != 0) {
        validPackets++;
      }

      // 检查是否是特殊 PID
      if (pid == 0) {
        patCount++;
      } else if (pid >= 0x20 && pid <= 0x1FFE) {
        // 可能是 PMT 或节目数据
        if ((flags & 0x40) != 0) {
          pmtCount++;
        }
      }

      // 检查是否有 PCR
      if ((flags & 0x20) != 0) {
        final adaptationFieldLength = data[i + 4];
        if (adaptationFieldLength > 0 && (data[i + 5] & 0x10) != 0) {
          pcrCount++;
        }
      }
    }

    // 计算统计信息
    final double packetValidity = packetCount > 0 ? (validPackets / packetCount) * 100 : 0;
    final double avgPacketsPerPid = pids.isNotEmpty ? packetCount / pids.length : 0;

    // 检测流类型
    String streamType = 'Unknown';
    if (pids.contains(0)) {
      streamType = 'MPEG-TS';
    }

    // 计算带宽估算 (粗略估算)
    double estimatedBandwidth = 0;
    if (packetCount > 0) {
      // 假设平均包大小为 188 字节，计算每秒包数
      estimatedBandwidth = (packetCount * tsPacketSize * 8) / 10; // 10秒采样
    }

    return TsSegmentAnalysis(
      url: url,
      dataSize: dataLength,
      packetCount: packetCount,
      validPackets: validPackets,
      uniquePids: pids.length,
      pidDistribution: pidPacketCount,
      patCount: patCount,
      pmtCount: pmtCount,
      pcrCount: pcrCount,
      packetValidity: packetValidity,
      avgPacketsPerPid: avgPacketsPerPid,
      streamType: streamType,
      estimatedBandwidth: estimatedBandwidth,
    );
  }

  /// 批量分析多个 TS 片段
  Future<List<TsSegmentAnalysis>> analyzeSegments(List<String> urls, {int sampleSize = 1024 * 10}) async {
    try {
      final results = <TsSegmentAnalysis>[];

      for (final url in urls) {
        try {
          final analysis = await analyzeSegment(url, sampleSize: sampleSize);
          results.add(analysis);
        } catch (e) {
          // 如果单个片段分析失败，继续分析其他片段
          debugPrint('跳过无法分析的片段: $url ($e)');
        }
      }

      return results;
    } catch (e) {
      debugPrint('TS 批量分析过程中出现严重错误: $e');
      // 返回空列表而不是抛出异常
      return [];
    }
  }
}

/// TS 片段分析结果
class TsSegmentAnalysis {
  final String url;
  final int dataSize;
  final int packetCount;
  final int validPackets;
  final int uniquePids;
  final Map<int, int> pidDistribution;
  final int patCount;
  final int pmtCount;
  final int pcrCount;
  final double packetValidity;
  final double avgPacketsPerPid;
  final String streamType;
  final double estimatedBandwidth;

  TsSegmentAnalysis({
    required this.url,
    required this.dataSize,
    required this.packetCount,
    required this.validPackets,
    required this.uniquePids,
    required this.pidDistribution,
    required this.patCount,
    required this.pmtCount,
    required this.pcrCount,
    required this.packetValidity,
    required this.avgPacketsPerPid,
    required this.streamType,
    required this.estimatedBandwidth,
  });

  @override
  String toString() {
    return '''
TS 片段分析结果:
  URL: $url
  数据大小: ${dataSize ~/ 1024} KB
  包数量: $packetCount
  有效包: $validPackets (${packetValidity.toStringAsFixed(1)}%)
  唯一 PID: $uniquePids
  流类型: $streamType
  估算带宽: ${(estimatedBandwidth / 1000).toStringAsFixed(1)} Kbps
  PAT/PMT/PCR: $patCount/$pmtCount/$pcrCount
    ''';
  }
}

/// PID 类型枚举
enum PidType {
  pat,        // Program Association Table
  cat,        // Conditional Access Table
  video,      // 视频流
  audio,      // 音频流
  subtitle,   // 字幕流
  data,       // 数据流
  unknown,    // 未知类型
  nullPacket, // 空包
  reserved,   // 保留
}

/// PID 信息
class PidInfo {
  final int pid;
  final int packetCount;
  final PidType type;
  final int firstAppearance;

  PidInfo({
    required this.pid,
    required this.packetCount,
    required this.type,
    required this.firstAppearance,
  });

  String get typeString {
    switch (type) {
      case PidType.pat: return 'PAT';
      case PidType.cat: return 'CAT';
      case PidType.video: return '视频';
      case PidType.audio: return '音频';
      case PidType.subtitle: return '字幕';
      case PidType.data: return '数据';
      case PidType.nullPacket: return '空包';
      case PidType.reserved: return '保留';
      case PidType.unknown: return '未知';
    }
  }
}

/// 包信息
class PacketInfo {
  final int index;
  final int pid;
  final bool hasPayload;
  final bool isScrambled;
  final bool hasAdaptationField;
  final int position;

  PacketInfo({
    required this.index,
    required this.pid,
    required this.hasPayload,
    required this.isScrambled,
    required this.hasAdaptationField,
    required this.position,
  });
}

/// 详细 TS 分析结果
class TsDetailedAnalysis {
  final int totalPackets;
  final int validPackets;
  final int invalidPackets;
  final int scrambledPackets;
  final double validityRate;
  final double averagePacketSize;
  final int uniquePids;
  final Map<int, PidInfo> pidInfos;
  final List<PacketInfo> packetInfos;
  final int maxConsecutiveValidPackets;
  final int gapCount;
  final PidInfo? videoPid;
  final PidInfo? audioPid;
  final List<PidInfo> otherPids;

  TsDetailedAnalysis({
    required this.totalPackets,
    required this.validPackets,
    required this.invalidPackets,
    required this.scrambledPackets,
    required this.validityRate,
    required this.averagePacketSize,
    required this.uniquePids,
    required this.pidInfos,
    required this.packetInfos,
    required this.maxConsecutiveValidPackets,
    required this.gapCount,
    this.videoPid,
    this.audioPid,
    required this.otherPids,
  });

  /// 获取流健康度评分 (0-100)
  double get healthScore {
    if (totalPackets == 0) return 0;

    double score = 0;

    // 有效性评分 (40%)
    score += (validityRate / 100) * 40;

    // 连续性评分 (30%)
    final continuityScore = maxConsecutiveValidPackets / totalPackets;
    score += continuityScore * 30;

    // PID 多样性评分 (20%)
    final pidScore = uniquePids > 0 ? (uniquePids <= 10 ? uniquePids / 10.0 : 1.0) : 0;
    score += pidScore * 20;

    // 加密状态评分 (10%)
    final encryptionScore = scrambledPackets == 0 ? 1.0 : 0.5;
    score += encryptionScore * 10;

    return score.clamp(0, 100);
  }

  /// 获取健康度描述
  String get healthDescription {
    final score = healthScore;
    if (score >= 90) return '优秀';
    if (score >= 70) return '良好';
    if (score >= 50) return '一般';
    if (score >= 30) return '较差';
    return '严重异常';
  }
}

/// 增强 TS 片段分析结果
class EnhancedTsSegmentAnalysis {
  final TsSegmentAnalysis basicAnalysis;
  final TsDetailedAnalysis detailedAnalysis;
  final Uint8List rawData;

  EnhancedTsSegmentAnalysis({
    required this.basicAnalysis,
    required this.detailedAnalysis,
    required this.rawData,
  });

  String get url => basicAnalysis.url;
  int get dataSize => basicAnalysis.dataSize;
  double get healthScore => detailedAnalysis.healthScore;
  String get healthDescription => detailedAnalysis.healthDescription;

  @override
  String toString() {
    return '''
增强 TS 片段分析结果:
  URL: $url
  文件大小: ${dataSize ~/ 1024} KB
  健康度: $healthDescription (${healthScore.toStringAsFixed(1)}分)
  包统计: ${detailedAnalysis.validPackets}/${detailedAnalysis.totalPackets} (${detailedAnalysis.validityRate.toStringAsFixed(1)}%)
  PID 数量: ${detailedAnalysis.uniquePids}
  主要流:
    视频: ${detailedAnalysis.videoPid?.pid ?? '无'} (${detailedAnalysis.videoPid?.packetCount ?? 0} 包)
    音频: ${detailedAnalysis.audioPid?.pid ?? '无'} (${detailedAnalysis.audioPid?.packetCount ?? 0} 包)
    ''';
  }
}
