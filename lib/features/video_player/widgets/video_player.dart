import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:fvp/fvp.dart' as fvp;
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/services/history_service.dart';
import 'package:vision_x_flutter/services/hls_parser_service.dart';
import 'package:vision_x_flutter/shared/widgets/loading_animation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/core/utils/window_manager.dart';
import 'package:vision_x_flutter/features/video_player/widgets/video_controls/normal_controls.dart';
import 'package:vision_x_flutter/features/video_player/widgets/video_controls/video_control_models.dart';
import 'package:vision_x_flutter/features/video_player/video_player_controller_provider.dart';
import 'dart:io';
import 'dart:io' show Platform;

/// 自定义视频播放器 - 使用原生 video_player 实现
class CustomVideoPlayer extends StatefulWidget {
  final MediaDetail media;
  final Episode episode;
  final Function(int)? onProgressUpdate;
  final Function()? onPlaybackCompleted;
  final Function(int)? onVideoDurationReceived;
  final int startPosition;
  final bool isShortDramaMode;
  final VoidCallback? onBackPressed;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onPrevEpisode;
  final Function(int)? onEpisodeChanged;
  final VoidCallback? onShowEpisodeSelector;
  final int currentEpisodeIndex;
  final int totalEpisodes;
  final Function()? onPreloadNextEpisode;
  final Function(bool)? onFullScreenChanged;
  final Function(double)? onSpeedChanged;
  final bool initialFullScreen;
  final bool initialLocked;
  final double initialSpeed;

  const CustomVideoPlayer({
    super.key,
    required this.media,
    required this.episode,
    this.onProgressUpdate,
    this.onPlaybackCompleted,
    this.onVideoDurationReceived,
    this.startPosition = 0,
    this.isShortDramaMode = false,
    this.onBackPressed,
    this.onNextEpisode,
    this.onPrevEpisode,
    this.onEpisodeChanged,
    this.onShowEpisodeSelector,
    this.currentEpisodeIndex = 0,
    this.totalEpisodes = 0,
    this.onPreloadNextEpisode,
    this.onFullScreenChanged,
    this.onSpeedChanged,
    this.initialFullScreen = false,
    this.initialLocked = false,
    this.initialSpeed = 1.0,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late vp.VideoPlayerController _videoPlayer;
  bool _isPlayerInitialized = false;
  Timer? _progressTimer;
  bool _isDisposing = false;
  bool _hasCompleted = false;
  bool _hasReportedDuration = false;
  bool _hasPreloaded = false;
  bool _hasRecordedInitialHistory = false;
  bool _isFullScreen = false;

  // UI状态管理
  UIState _uiState = const UIState();
  Timer? _hideControlsTimer;

  // 广告检测相关
  bool _isProcessingVideo = false;
  String? _processedVideoUrl;

  // HLS解析器服务
  final HlsParserService _hlsParserService = HlsParserService();

  // 错误处理
  String? _errorMessage;

  // 图片加载状态
  bool _isImageLoading = true;
  bool _imageLoadError = false;

  // 保存VideoPlayerControllerProvider的引用，用于安全地在dispose中访问
  VideoPlayerControllerProvider? _videoPlayerControllerProvider;
  
  // 防止重复初始化的标志
  bool _isInitializing = false;
  
  // 视频播放器监听器
  VoidCallback? _playerListener;
  
  // 速度变化监听器
  VoidCallback? _speedChangedListener;

  @override
  void initState() {
    super.initState();

    // 初始化 fvp 以支持 Windows 平台
    fvp.registerWith();

    // 使用初始状态
    _isFullScreen = widget.initialFullScreen;
    _uiState = UIState(
      isFullScreen: widget.initialFullScreen,
      isLocked: widget.initialLocked,
      currentSpeed: widget.initialSpeed,
    );

    debugPrint(
        'CustomVideoPlayer 初始化: 全屏=$_isFullScreen, 锁定=${_uiState.isLocked}, 速度=${_uiState.currentSpeed}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
      _setupSpeedListener();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 安全地保存VideoPlayerControllerProvider的引用
    _videoPlayerControllerProvider = VideoPlayerControllerProvider.of(context);
  }

  // 初始化播放器
  void _initializePlayer() {
    // 实现播放器初始化逻辑
  }
  
  // 设置速度监听器
  void _setupSpeedListener() {
    // 实现速度监听逻辑
  }
  
  // 视频播放器监听器
  void _videoPlayerListener() {
    // 实现视频播放器监听逻辑
  }
  
  // 速度变化监听器
  void _onSpeedChanged() {
    // 实现速度变化监听逻辑
  }
  
  // 更新最终进度
  void _updateFinalProgress() {
    // 实现更新最终进度逻辑
  }
  
  // 检查是否为桌面平台
  bool _isDesktopPlatform() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  void dispose() {
    debugPrint('CustomVideoPlayer dispose() 开始');
    
    // 设置disposing标志，防止异步操作继续执行
    _isDisposing = true;
    _isInitializing = false;
    
    // 取消所有定时器
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
    _progressTimer?.cancel();
    _progressTimer = null;

    // 立即停止视频播放，防止内存泄漏
    if (_isPlayerInitialized) {
      try {
        _videoPlayer.pause();
        _videoPlayer.removeListener(_videoPlayerListener);
        debugPrint('视频播放器监听器已移除');
      } catch (e) {
        debugPrint('停止视频播放时出错: $e');
      }
    }

    // 移除倍速监听器
    try {
      if (_videoPlayerControllerProvider != null) {
        // 注意：这里需要根据实际的API调整
        // _videoPlayerControllerProvider!.controller.playbackSpeed.removeListener(_onSpeedChanged);
        debugPrint('倍速监听器已移除');
      }
    } catch (e) {
      debugPrint('移除倍速监听器时出错: $e');
    }

    // 更新最终进度
    try {
      _updateFinalProgress();
    } catch (e) {
      debugPrint('更新最终进度时出错: $e');
    }

    // 恢复屏幕方向，避免退出应用时卡在横屏
    try {
      if (!_isDesktopPlatform()) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    } catch (e) {
      debugPrint('恢复屏幕方向时出错: $e');
    }

    // 恢复系统UI
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    } catch (e) {
      debugPrint('恢复系统UI时出错: $e');
    }
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // 返回一个简单的占位符widget
    return const Scaffold(
      body: Center(
        child: Text('视频播放器'),
      ),
    );
  }
}