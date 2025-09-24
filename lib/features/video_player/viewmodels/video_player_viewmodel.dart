import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/video_player_config.dart';

/// 视频播放页面控制器
/// 负责状态管理、业务逻辑和事件处理
class VideoPlayerController {
  final MediaDetail media;
  final Episode initialEpisode;
  final int startPosition;

  // 状态通知器
  final ValueNotifier<Episode> _currentEpisode;
  final ValueNotifier<int> _currentProgress;
  final ValueNotifier<int> _currentEpisodeIndex;
  final ValueNotifier<int?> _videoDuration;
  final ValueNotifier<bool> _isShortDramaMode;
  final ValueNotifier<bool> _isInfoCardExpanded; // 添加信息卡片展开状态
  final ValueNotifier<double> _playbackSpeed; // 添加播放速度状态

  // 数据
  late final Source _currentSource;
  late final PageController _pageController;

  VideoPlayerController({
    required this.media,
    required this.initialEpisode,
    this.startPosition = 0,
  })  : _currentEpisode = ValueNotifier(initialEpisode),
        _currentProgress = ValueNotifier(startPosition),
        _currentEpisodeIndex = ValueNotifier(0),
        _videoDuration = ValueNotifier(null),
        _isShortDramaMode = ValueNotifier(false),
        _isInfoCardExpanded = ValueNotifier(false), // 初始化信息卡片为折叠状态
        _playbackSpeed = ValueNotifier(1.0) { // 初始化播放速度为1.0
    _initialize();
  }

  // Getters for state access
  ValueListenable<Episode> get currentEpisode => _currentEpisode;
  ValueListenable<int> get currentProgress => _currentProgress;
  ValueListenable<int> get currentEpisodeIndex => _currentEpisodeIndex;
  ValueListenable<int?> get videoDuration => _videoDuration;
  ValueListenable<bool> get isShortDramaMode => _isShortDramaMode;
  ValueListenable<bool> get isInfoCardExpanded => _isInfoCardExpanded; // 添加getter
  ValueListenable<double> get playbackSpeed => _playbackSpeed; // 添加播放速度getter
  PageController get pageController => _pageController;

  int get totalEpisodes => _currentSource.episodes.length;
  bool get canPlayNext => _currentEpisodeIndex.value < totalEpisodes - 1;
  bool get canPlayPrev => _currentEpisodeIndex.value > 0;

  void _initialize() {
    _currentSource = _getCurrentSource();
    _currentEpisodeIndex.value = _getCurrentEpisodeIndex();
    _isShortDramaMode.value = _checkShortDramaMode();
    _pageController = PageController(initialPage: _currentEpisodeIndex.value);
  }

  Source get currentSource => _getCurrentSource();

  Source _getCurrentSource() {
    return media.surces.firstWhere(
      (source) => source.name == media.sourceName,
      orElse: () => media.surces.first,
    );
  }

  int _getCurrentEpisodeIndex() {
    try {
      return _currentSource.episodes.indexWhere(
        (episode) => episode.url == initialEpisode.url,
      );
    } catch (e) {
      return 0;
    }
  }

  bool _checkShortDramaMode() {
    return VideoPlayerUtils.isShortDramaMode(media.category, media.type);
  }

  /// 切换剧集
  void changeEpisode(int index) {
    if (index < 0 || index >= totalEpisodes) return;
    if (index == _currentEpisodeIndex.value) return;

    _currentEpisodeIndex.value = index;
    _currentEpisode.value = _currentSource.episodes[index];
    _currentProgress.value = 0;
    _videoDuration.value = null;
  }

  /// 播放下一集
  void playNextEpisode() {
    if (!canPlayNext) return;
    changeEpisode(_currentEpisodeIndex.value + 1);
  }

  /// 播放上一集
  void playPrevEpisode() {
    if (!canPlayPrev) return;
    changeEpisode(_currentEpisodeIndex.value - 1);
  }

  /// 更新播放进度
  void updateProgress(int progress) {
    _currentProgress.value = progress;
  }

  /// 设置视频时长
  void setVideoDuration(int duration) {
    _videoDuration.value = duration;
  }

  /// 预加载下一集
  void preloadNextEpisode() {
    if (!canPlayNext) return;
    // TODO: 实现预加载逻辑
  }

  /// 切换信息卡片展开/折叠状态
  void toggleInfoCard() {
    _isInfoCardExpanded.value = !_isInfoCardExpanded.value;
  }

  /// 设置信息卡片为展开状态
  void expandInfoCard() {
    _isInfoCardExpanded.value = true;
  }

  /// 设置信息卡片为折叠状态
  void collapseInfoCard() {
    _isInfoCardExpanded.value = false;
  }

  /// 设置播放速度
  void setPlaybackSpeed(double speed) {
    _playbackSpeed.value = speed;
  }

  void dispose() {
    _currentEpisode.dispose();
    _currentProgress.dispose();
    _currentEpisodeIndex.dispose();
    _videoDuration.dispose();
    _isShortDramaMode.dispose();
    _isInfoCardExpanded.dispose(); // 添加释放资源
    _playbackSpeed.dispose(); // 释放播放速度资源
    _pageController.dispose();
  }
}
