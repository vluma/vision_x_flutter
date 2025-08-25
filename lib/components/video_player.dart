import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/components/custom_video_controls.dart';

class CustomVideoPlayer extends StatefulWidget {
  final MediaDetail media;
  final Episode episode;
  final Function(int)? onProgressUpdate;
  final Function()? onPlaybackCompleted; // 添加播放完成回调
  final Function(int)? onVideoDurationReceived; // 添加视频时长回调
  final int startPosition; // 添加起始位置参数
  final bool isShortDramaMode; // 添加短剧模式参数
  // 新增控制组件回调参数
  final VoidCallback? onBackPressed; // 返回按钮回调
  final VoidCallback? onNextEpisode; // 下一集回调
  final VoidCallback? onPrevEpisode; // 上一集回调
  final Function(int)? onEpisodeChanged; // 剧集切换回调
  final int currentEpisodeIndex; // 当前剧集索引
  final int totalEpisodes; // 总剧集数
  // 预加载相关参数
  final Function()? onPreloadNextEpisode; // 预加载下一集回调

  const CustomVideoPlayer({
    super.key,
    required this.media,
    required this.episode,
    this.onProgressUpdate,
    this.onPlaybackCompleted, // 添加播放完成回调参数
    this.onVideoDurationReceived, // 添加视频时长回调参数
    this.startPosition = 0, // 默认从头开始
    this.isShortDramaMode = false, // 默认不是短剧模式
    // 新增控制组件回调参数
    this.onBackPressed,
    this.onNextEpisode,
    this.onPrevEpisode,
    this.onEpisodeChanged,
    this.currentEpisodeIndex = 0,
    this.totalEpisodes = 0,
    // 预加载相关参数
    this.onPreloadNextEpisode,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayer;
  late ChewieController _chewieController;
  bool _isPlayerInitialized = false;
  Timer? _progressTimer;
  bool _isDisposing = false;
  bool _hasCompleted = false; // 添加播放完成标志
  bool _hasReportedDuration = false; // 添加时长报告标志
  bool _hasPreloaded = false; // 添加预加载标志

  // 播放状态数据
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isBuffering = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 确保在组件未被销毁时才进行初始化
    if (!mounted || _isDisposing) return;

    _videoPlayer = VideoPlayerController.networkUrl(
      Uri.parse(widget.episode.url),
    );

    await _videoPlayer.initialize();

    // 如果指定了起始位置，则跳转到该位置
    if (widget.startPosition > 0) {
      await _videoPlayer.seekTo(Duration(seconds: widget.startPosition));
    }

    // 报告视频总时长
    if (!_hasReportedDuration) {
      _hasReportedDuration = true;
      final duration = _videoPlayer.value.duration.inSeconds;
      widget.onVideoDurationReceived?.call(duration);
    }

    // 监听播放完成事件
    _videoPlayer.addListener(_videoPlayerListener);

    // 启动进度更新定时器
    _startProgressTracking();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayer,
      autoPlay: true,
      looping: false,
      allowedScreenSleep: false,
      aspectRatio: _videoPlayer.value.aspectRatio,
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
      // 使用自定义控制组件，传递所有必要的参数
      customControls: CustomControls(
        isShortDramaMode: widget.isShortDramaMode,
        onBackPressed: widget.onBackPressed,
        onNextEpisode: widget.onNextEpisode,
        onPrevEpisode: widget.onPrevEpisode,
        onEpisodeChanged: widget.onEpisodeChanged,
        episodeTitle: widget.episode.title,
        mediaTitle: widget.media.name,
        currentEpisodeIndex: widget.currentEpisodeIndex,
        totalEpisodes: widget.totalEpisodes,
      ),
    );

    if (mounted) {
      setState(() {
        _isPlayerInitialized = true;
      });
    }
  }

  void _videoPlayerListener() {
    // 检查视频是否播放完成
    if (_videoPlayer.value.isInitialized &&
        _videoPlayer.value.duration.inMilliseconds > 0 && // 确保视频时长有效
        !_isDisposing &&
        !_hasCompleted) {
      // 检查是否接近或到达视频结尾
      final position = _videoPlayer.value.position;
      final duration = _videoPlayer.value.duration;
      final difference = duration - position;

      // 短剧模式下的预加载逻辑
      if (widget.isShortDramaMode && 
          !_hasPreloaded && 
          widget.currentEpisodeIndex < widget.totalEpisodes - 1) {
        // 当视频播放到90%时开始预加载下一集
        final progressPercentage = position.inMilliseconds / duration.inMilliseconds;
        if (progressPercentage >= 0.9) {
          _hasPreloaded = true;
          widget.onPreloadNextEpisode?.call();
        }
      }

      // 添加调试信息
      if (difference.inMilliseconds <= 5000 &&
          difference.inMilliseconds >= -1000) {
        // print('Video position: $position, duration: $duration, difference: $difference');
      }

      // 如果位置接近或超过持续时间（允许1秒误差）
      if (difference.inMilliseconds <= 1000 &&
          difference.inMilliseconds >= -1000) {
        // print('Video completed. Calling onPlaybackCompleted callback.');
        _hasCompleted = true; // 标记为已完成，防止重复触发
        widget.onPlaybackCompleted?.call();
      }
    }
  }

  void _startProgressTracking() {
    // 每30秒更新一次进度
    _progressTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_videoPlayer.value.isInitialized &&
          !_isDisposing &&
          _videoPlayer.value.isPlaying) {
        final position = _videoPlayer.value.position.inSeconds;
        widget.onProgressUpdate?.call(position);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return _isPlayerInitialized
        ? Chewie(controller: _chewieController)
        : const Center(child: CircularProgressIndicator());
  }

  // MARK: - 播放控制方法
  void play() {
    if (_videoPlayer.value.isInitialized) {
      _videoPlayer.play();
    }
  }

  void pause() {
    if (_videoPlayer.value.isInitialized) {
      _videoPlayer.pause();
    }
  }

  void seekTo(Duration position) {
    if (_videoPlayer.value.isInitialized) {
      _videoPlayer.seekTo(position);
    }
  }

  void setPlaybackSpeed(double speed) {
    if (_videoPlayer.value.isInitialized) {
      _videoPlayer.setPlaybackSpeed(speed);
    }
  }

  void toggleFullScreen() {
    _chewieController.toggleFullScreen();
  }

  void exitFullScreen() {
    _chewieController.exitFullScreen();
  }

  // MARK: - 数据获取方法
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get playbackSpeed => _playbackSpeed;
  bool get isFullScreen => _chewieController.isFullScreen;
  bool get isInitialized => _isPlayerInitialized;
  VideoPlayerController get videoPlayerController => _videoPlayer;
  ChewieController get chewieController => _chewieController;

  @override
  void dispose() {
    _isDisposing = true;
    _progressTimer?.cancel();
    _videoPlayer.removeListener(_videoPlayerListener);

    // 异步销毁控制器，避免在构建过程中销毁
    Future.microtask(() async {
      try {
        _chewieController.dispose();
      } catch (e) {
        // 忽略销毁错误
      }

      try {
        await _videoPlayer.dispose();
      } catch (e) {
        // 忽略销毁错误
      }
    });

    super.dispose();
  }
}
