import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/video_player_config.dart';
import 'package:vision_x_flutter/features/video_player/video_player_performance.dart';

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
  final ValueNotifier<bool> _isFullScreen; // 添加全屏状态跟踪

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
        _playbackSpeed = ValueNotifier(1.0), // 初始化播放速度为1.0
        _isFullScreen = ValueNotifier(false) { // 初始化全屏状态为false
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
  ValueListenable<bool> get isFullScreen => _isFullScreen; // 添加全屏状态getter
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
    
    // 获取下一集
    final nextEpisodeIndex = _currentEpisodeIndex.value + 1;
    final nextEpisode = _currentSource.episodes[nextEpisodeIndex];
    
    // 调用性能管理器进行预加载
    VideoPlayerPerformance.preloadEpisode(nextEpisode.url);
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

  /// 设置全屏状态
  void setFullScreen(bool isFullScreen) {
    _isFullScreen.value = isFullScreen;
  }

  void dispose() {
    debugPrint('VideoPlayerController dispose() 开始');
    
    try {
      _currentEpisode.dispose();
      debugPrint('_currentEpisode 已释放');
    } catch (e) {
      debugPrint('释放 _currentEpisode 时出错: $e');
    }
    
    try {
      _currentProgress.dispose();
      debugPrint('_currentProgress 已释放');
    } catch (e) {
      debugPrint('释放 _currentProgress 时出错: $e');
    }
    
    try {
      _currentEpisodeIndex.dispose();
      debugPrint('_currentEpisodeIndex 已释放');
    } catch (e) {
      debugPrint('释放 _currentEpisodeIndex 时出错: $e');
    }
    
    try {
      _videoDuration.dispose();
      debugPrint('_videoDuration 已释放');
    } catch (e) {
      debugPrint('释放 _videoDuration 时出错: $e');
    }
    
    try {
      _isShortDramaMode.dispose();
      debugPrint('_isShortDramaMode 已释放');
    } catch (e) {
      debugPrint('释放 _isShortDramaMode 时出错: $e');
    }
    
    try {
      _isInfoCardExpanded.dispose();
      debugPrint('_isInfoCardExpanded 已释放');
    } catch (e) {
      debugPrint('释放 _isInfoCardExpanded 时出错: $e');
    }
    
    try {
      _playbackSpeed.dispose();
      debugPrint('_playbackSpeed 已释放');
    } catch (e) {
      debugPrint('释放 _playbackSpeed 时出错: $e');
    }
    
    try {
      _isFullScreen.dispose();
      debugPrint('_isFullScreen 已释放');
    } catch (e) {
      debugPrint('释放 _isFullScreen 时出错: $e');
    }
    
    try {
      _pageController.dispose();
      debugPrint('_pageController 已释放');
    } catch (e) {
      debugPrint('释放 _pageController 时出错: $e');
    }
    
    debugPrint('VideoPlayerController dispose() 完成');
  }
}
