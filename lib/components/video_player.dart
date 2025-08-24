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
  final Function(int)? onVideoDurationReceived; // 添加视频时长回调
  final int startPosition; // 添加起始位置参数

  const CustomVideoPlayer({
    super.key,
    required this.media,
    required this.episode,
    this.onProgressUpdate,
    this.onPlaybackCompleted, // 添加播放完成回调参数
    this.onVideoDurationReceived, // 添加视频时长回调参数
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
  bool _hasReportedDuration = false; // 添加时长报告标志
  
  // 添加播放速度变量
  double _playbackSpeed = 1.0;
  // 添加快进快退速度变量
  double _seekSpeed = 0.0;
  Timer? _seekTimer;

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
    
    // 报告视频总时长
    if (!_hasReportedDuration) {
      _hasReportedDuration = true;
      final duration = _videoPlayerController.value.duration.inSeconds;
      widget.onVideoDurationReceived?.call(duration);
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
      // 添加播放速度控制选项
      playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
      // 移除了对不存在的 CustomMaterialControls 的引用
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
  
  
  // 长按手势处理
  void _handleLongPressStart(LongPressStartDetails details) {
    // 判断触摸点在屏幕的左半部分还是右半部分
    if (details.localPosition.dx < MediaQuery.of(context).size.width / 2) {
      // 左半部分 - 快退
      _startSeeking(false);
    } else {
      // 右半部分 - 快进
      _startSeeking(true);
    }
  }
  
  // 长按移动处理
  void _handleLongPressMove(LongPressMoveUpdateDetails details) {
    // 判断触摸点在屏幕的左半部分还是右半部分
    if (details.localPosition.dx < MediaQuery.of(context).size.width / 2) {
      // 如果之前是快进状态，需要切换到快退
      if (_seekSpeed > 0) {
        _stopSeeking();
        _startSeeking(false);
      } else if (_seekSpeed == 0) {
        // 如果之前没有操作，开始快退
        _startSeeking(false);
      }
    } else {
      // 如果之前是快退状态，需要切换到快进
      if (_seekSpeed < 0) {
        _stopSeeking();
        _startSeeking(true);
      } else if (_seekSpeed == 0) {
        // 如果之前没有操作，开始快进
        _startSeeking(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isPlayerInitialized
        ? GestureDetector(
            onLongPressStart: _handleLongPressStart,
            onLongPressMoveUpdate: _handleLongPressMove,
            onLongPressEnd: (details) {
              // 松开时停止快进快退
              _stopSeeking();
            },
            child: Chewie(controller: _chewieController),
          )
        : const Center(child: CircularProgressIndicator());
  }

  // 开始快进或快退
  void _startSeeking(bool isForward) {
    // 设置倍速 (快退1.5倍速，快进2倍速)
    _seekSpeed = isForward ? 2.0 : -1.5;
    
    // 取消之前的计时器
    _seekTimer?.cancel();
    
    // 开始新的计时器，每100毫秒更新一次位置
    _seekTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_videoPlayerController.value.isInitialized && 
          !_isDisposing && 
          _seekSpeed != 0) {
        final currentPosition = _videoPlayerController.value.position;
        final duration = _videoPlayerController.value.duration;
        
        // 根据倍速计算新位置
        final positionChange = _seekSpeed * 100; // 100毫秒的进度变化
        final newPosition = currentPosition + Duration(milliseconds: positionChange.toInt());
        
        // 确保位置在有效范围内
        if (newPosition < Duration.zero) {
          _videoPlayerController.seekTo(Duration.zero);
        } else if (newPosition > duration) {
          _videoPlayerController.seekTo(duration);
        } else {
          _videoPlayerController.seekTo(newPosition);
        }
      }
    });
  }
  
  // 停止快进或快退
  void _stopSeeking() {
    _seekSpeed = 0.0;
    _seekTimer?.cancel();
  }

  @override
  void dispose() {
    _isDisposing = true;
    _progressTimer?.cancel();
    _seekTimer?.cancel();
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

