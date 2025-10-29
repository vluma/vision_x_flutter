import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HLS 解析器服务 - 集成 Better Player HLS 解析器
class HlsParserService {
  static final HlsParserService _instance = HlsParserService._internal();
  factory HlsParserService() => _instance;
  HlsParserService._internal();

  final Dio _dio = Dio();

  // 广告过滤设置
  bool _adFilterEnabled = true; // 全局广告过滤开关
  bool _adFilterByMetadata = true; // 合并码率和不连续标记检测

  /// 释放资源
  void dispose() {
    try {
      _dio.close();
      debugPrint('HlsParserService 资源已释放');
    } catch (e) {
      debugPrint('释放HlsParserService资源时出错: $e');
    }
  }

  /// 加载广告过滤设置
  Future<void> _loadAdFilterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _adFilterEnabled = prefs.getBool('ad_filter_enabled') ?? true;
    _adFilterByMetadata = prefs.getBool('ad_filter_by_metadata') ?? true;
  }

  /// 解析主播放列表 - 使用 Dio 获取内容
  Future<HlsMasterPlaylist> parseMasterPlaylist(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      final data = response.data as String;
      debugPrint('主播放列表解析元数据: $data');
      return _parseMasterPlaylistContent(data, url);
    } catch (e) {
      throw HlsParserException('解析主播放列表失败: $e');
    }
  }

  /// 解析媒体播放列表 - 使用 Dio 获取内容
  Future<HlsMediaPlaylist> parseMediaPlaylist(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      final data = response.data as String;
      debugPrint('视频解析元数据: $data');
      final result = _parseMediaPlaylistContent(data, url);
      debugPrint('媒体播放列表解析成功: ${result.segments.length} 个片段');
      return result;
    } catch (e, stackTrace) {
      debugPrint('媒体播放列表解析失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      throw HlsParserException('解析媒体播放列表失败: $e');
    }
  }

  /// 获取 HLS 文件内容（通用方法）
  Future<String> fetchHlsContent(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      return response.data as String;
    } catch (e) {
      throw HlsParserException('获取 HLS 内容失败: $e');
    }
  }

  /// 过滤广告并重新构建播放列表
  Future<String> filterAdsAndRebuild(String originalUrl) async {
    try {
      await _loadAdFilterSettings();

      // 如果全局广告过滤被禁用，直接返回原始播放列表内容
      if (!_adFilterEnabled) {
        debugPrint('广告过滤功能已禁用，跳过广告检测');
        final response = await _dio.get(originalUrl);
        return response.data as String;
      }

      // 解析主播放列表
      final masterPlaylist = await parseMasterPlaylist(originalUrl);
      debugPrint('主播放列表解析成功: ${masterPlaylist.variants.length} 个流');
      // 选择最佳质量的流
      final bestVariant = _selectBestVariant(masterPlaylist.variants);
      if (bestVariant == null) {
        throw HlsParserException('没有找到可用的视频流');
      }

      // 解析媒体播放列表
      final mediaPlaylist = await parseMediaPlaylist(bestVariant.url);

      // 检测和过滤广告片段
      final filteredSegments =
          await _detectAndFilterAds(mediaPlaylist, bestVariant);

      // 重新构建播放列表
      return _rebuildPlaylist(mediaPlaylist, filteredSegments, bestVariant.url);
    } catch (e) {
      throw HlsParserException('过滤广告失败: $e');
    }
  }