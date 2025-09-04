import 'package:vision_x_flutter/data/models/media_detail.dart';

/// 视频播放器仓库接口
/// 负责处理视频播放相关的数据操作
abstract class VideoPlayerRepository {
  /// 获取视频源
  Future<String> getVideoUrl(MediaDetail media, Episode episode);
  
  /// 处理视频URL（如广告过滤等）
  Future<String> processVideoUrl(String url, String baseUrl);
  
  /// 记录播放历史
  Future<void> savePlayHistory(MediaDetail media, Episode episode, int position, int duration);
  
  /// 更新播放进度
  Future<void> updatePlayProgress(MediaDetail media, Episode episode, int position, int duration);
  
  /// 获取播放配置
  Future<Map<String, dynamic>> getPlayerConfig();
  
  /// 检查是否启用广告过滤
  Future<bool> isAdFilterEnabled();
}