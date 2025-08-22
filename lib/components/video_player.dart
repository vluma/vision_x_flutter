import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:vision_x_flutter/models/media_detail.dart';

class CustomVideoPlayer extends StatefulWidget {
  final MediaDetail media;
  final Episode episode;
  final Function(int)? onProgressUpdate;
  final Function()? onPlaybackCompleted; // 添加播放完成回调
  final int startPosition; // 添加起始位置参数

  const CustomVideoPlayer({
    super.key,
    required this.media,
    required this.episode,
    this.onProgressUpdate,
    this.onPlaybackCompleted, // 添加播放完成回调参数
    this.startPosition = 0, // 默认从头开始
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isPlayerInitialized = false;
  Timer? _progressTimer;
  bool _isDisposing = false;
  bool _hasCompleted = false; // 添加播放完成标志

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 确保在组件未被销毁时才进行初始化
    if (!mounted || _isDisposing) return;
    
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.episode.url),
    );

    await _videoPlayerController.initialize();
    
    // 如果指定了起始位置，则跳转到该位置
    if (widget.startPosition > 0) {
      await _videoPlayerController.seekTo(Duration(seconds: widget.startPosition));
    }
    
    // 监听播放完成事件
    _videoPlayerController.addListener(_videoPlayerListener);
    
    // 启动进度更新定时器
    _startProgressTracking();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowedScreenSleep: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
    );

    if (mounted) {
      setState(() {
        _isPlayerInitialized = true;
      });
    }
  }
  
  void _videoPlayerListener() {
    // 检查视频是否播放完成
    if (_videoPlayerController.value.position >= _videoPlayerController.value.duration && 
        !_isDisposing && !_hasCompleted) {
      _hasCompleted = true; // 标记为已完成，防止重复触发
      widget.onPlaybackCompleted?.call();
    }
  }
  
  void _startProgressTracking() {
    // 每30秒更新一次进度
    _progressTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_videoPlayerController.value.isInitialized && !_isDisposing) {
        final position = _videoPlayerController.value.position.inSeconds;
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

  @override
  void dispose() {
    _isDisposing = true;
    _progressTimer?.cancel();
    _videoPlayerController.removeListener(_videoPlayerListener);
    
    // 异步销毁控制器，避免在构建过程中销毁
    Future.microtask(() async {
      try {
        _chewieController.dispose();
      } catch (e) {
        // 忽略销毁错误
      }
      
      try {
        await _videoPlayerController.dispose();
      } catch (e) {
        // 忽略销毁错误
      }
    });
    
    super.dispose();
  }
}