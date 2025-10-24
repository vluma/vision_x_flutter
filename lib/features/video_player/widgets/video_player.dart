import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController _videoPlayer;
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

  @override
  void initState() {
    super.initState();
    
    // 使用初始状态
    _isFullScreen = widget.initialFullScreen;
    _uiState = UIState(
      isFullScreen: widget.initialFullScreen,
      isLocked: widget.initialLocked,
      currentSpeed: widget.initialSpeed,
    );
    
    debugPrint('CustomVideoPlayer 初始化: 全屏=$_isFullScreen, 锁定=${_uiState.isLocked}, 速度=${_uiState.currentSpeed}');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
      
      // 如果初始状态是全屏，应用系统级全屏设置
      if (widget.initialFullScreen) {
        debugPrint('应用初始全屏设置');
        _enterFullScreen();
        // 通知外部全屏状态变化
        widget.onFullScreenChanged?.call(true);
      }
      
      // 监听VideoPlayerController的倍速变化
      _setupSpeedListener();
    });
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _isDisposing = true;
    _progressTimer?.cancel();
    
    // 立即停止视频播放，防止内存泄漏
    if (_isPlayerInitialized) {
      try {
        _videoPlayer.pause();
        _videoPlayer.removeListener(_videoPlayerListener);
      } catch (e) {
        debugPrint('停止视频播放时出错: $e');
      }
    }
    
    // 移除倍速监听器
    final provider = VideoPlayerControllerProvider.of(context);
    if (provider != null) {
      provider.controller.playbackSpeed.removeListener(_onSpeedChanged);
    }

    // 更新最终进度
    _updateFinalProgress();
    
    // 恢复屏幕方向，避免退出应用时卡在横屏
    if (!_isDesktopPlatform()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    
    // 恢复系统UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    // 立即销毁控制器，防止内存泄漏
    if (_isPlayerInitialized) {
      try {
        _videoPlayer.dispose();
      } catch (e) {
        debugPrint('销毁视频播放器时出错: $e');
      }
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当剧集切换时，更新视频源
    if (oldWidget.episode.url != widget.episode.url && _isPlayerInitialized) {
      _updateVideoSource();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      if (!mounted || _isDisposing) return;

      // 处理视频URL（检测和过滤广告）
      await _processVideoUrlWithHlsParser();

      // 使用处理后的URL或原始URL
      final videoUrl = _processedVideoUrl ?? widget.episode.url;

      _videoPlayer = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await _videoPlayer.initialize();

      // 如果指定了起始位置，则跳转到该位置
      if (widget.startPosition > 0) {
        await _videoPlayer.seekTo(Duration(seconds: widget.startPosition));
      }

      // 报告视频总时长
      _reportVideoDuration();

      // 记录初始历史
      _recordInitialHistory();

      // 监听播放完成事件
      _videoPlayer.addListener(_videoPlayerListener);

      // 启动进度更新定时器
      _startProgressTracking();

      if (mounted) {
        setState(() {
          _isPlayerInitialized = true;
        });
        // 自动开始播放
        _videoPlayer.play();
        // 启动控制栏自动隐藏定时器
        _startHideControlsTimer();
      }
    } catch (e) {
      _handleInitializationError(e.toString());
    }
  }

  /// 更新视频源（用于剧集切换时保持全屏状态）
  Future<void> _updateVideoSource() async {
    try {
      if (!mounted || _isDisposing) return;

      // 保存当前状态
      final wasPlaying = _videoPlayer.value.isPlaying;
      final currentPosition = _videoPlayer.value.position;
      final wasFullScreen = _isFullScreen;
      final wasLocked = _uiState.isLocked;

      debugPrint('更新视频源: 播放状态=$wasPlaying, 位置=${currentPosition.inSeconds}秒, 全屏状态=$wasFullScreen, 锁定状态=$wasLocked');

      // 处理新的视频URL
      await _processVideoUrlWithHlsParser();
      final videoUrl = _processedVideoUrl ?? widget.episode.url;

      // 创建新的视频控制器
      final newVideoPlayer = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await newVideoPlayer.initialize();

      // 如果指定了起始位置，则跳转到该位置
      if (widget.startPosition > 0) {
        await newVideoPlayer.seekTo(Duration(seconds: widget.startPosition));
      }

      // 安全地更新控制器
      _videoPlayer.removeListener(_videoPlayerListener);
      await _videoPlayer.dispose();
      _videoPlayer = newVideoPlayer;
      _videoPlayer.addListener(_videoPlayerListener);

      // 恢复播放状态
      if (wasPlaying) {
        _videoPlayer.play();
      }

      // 报告新的视频时长
      _reportVideoDuration();

      // 记录新的历史
      _recordInitialHistory();

      if (mounted) {
        setState(() {
          _isPlayerInitialized = true;
          // 恢复全屏状态
          if (wasFullScreen) {
            _isFullScreen = true;
            _uiState = _uiState.copyWith(
              isFullScreen: true,
              isLocked: wasLocked,
            );
            debugPrint('在setState中恢复全屏状态: _isFullScreen=$_isFullScreen, uiState.isFullScreen=${_uiState.isFullScreen}');
          }
        });
        
        // 如果之前是全屏状态，重新应用全屏设置
        if (wasFullScreen) {
          debugPrint('恢复全屏状态: 重新应用全屏设置');
          // 使用 Future.microtask 确保在下一个事件循环中执行
          Future.microtask(() {
            if (mounted) {
              _enterFullScreen();
              // 通知外部全屏状态变化
              widget.onFullScreenChanged?.call(true);
              debugPrint('全屏状态恢复完成: _isFullScreen=$_isFullScreen, uiState.isFullScreen=${_uiState.isFullScreen}');
            }
          });
        }
      }
    } catch (e) {
      debugPrint('更新视频源失败: $e');
      _handleInitializationError(e.toString());
    }
  }

  /// 使用HLS解析器处理视频URL
  Future<void> _processVideoUrlWithHlsParser() async {
    try {
      setState(() {
        _isProcessingVideo = true;
      });

      // 获取基础URL用于拼接可能不完整的视频URL
      final baseUrl = widget.media.apiUrl ?? '';
      debugPrint('基础URL: $baseUrl');

      // 处理可能不完整的视频URL
      final resolvedUrl = baseUrl.isNotEmpty
          ? _resolveIncompleteUrl(widget.episode.url, baseUrl)
          : widget.episode.url;
      debugPrint('解析后的URL: $resolvedUrl');

      // 判断是否为HLS流
      if (_isHlsStream(resolvedUrl)) {
        // 检查广告过滤是否启用
        final prefs = await SharedPreferences.getInstance();
        final isAdFilterEnabled = prefs.getBool('ad_filter_enabled') ?? true;

        if (!isAdFilterEnabled) {
          // 广告过滤已禁用，直接使用原始URL
          debugPrint('广告过滤功能已禁用，跳过广告检测');
          _processedVideoUrl = resolvedUrl;
        } else {
          // 广告过滤已启用，执行广告过滤
          try {
            final processedPlaylist =
                await _hlsParserService.filterAdsAndRebuild(resolvedUrl);
            // 将处理后的播放列表保存到本地文件
            final processedUrl = await _saveProcessedPlaylist(processedPlaylist);

            // 设置处理后的URL
            _processedVideoUrl = processedUrl;
            debugPrint('HLS解析器处理完成，广告已过滤');
          } catch (e) {
            debugPrint('HLS解析器处理失败: $e');
            // 处理失败时使用解析后的URL
            _processedVideoUrl = resolvedUrl;
          }
        }
      } else {
        // 非HLS流，使用解析后的URL
        _processedVideoUrl = resolvedUrl;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingVideo = false;
        });
      }
    }
  }

  /// 保存处理后的播放列表到本地文件
  Future<String> _saveProcessedPlaylist(String playlist) async {
    try {
      // 获取文档目录
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'processed_playlist_${DateTime.now().millisecondsSinceEpoch}.m3u8';
      final filePath = '${directory.path}/$fileName';

      // 将播放列表写入文件
      final file = File(filePath);
      await file.writeAsString(playlist);

      // 返回文件路径
      return file.uri.toString();
    } catch (e) {
      debugPrint('保存处理后的播放列表失败: $e');
      rethrow;
    }
  }

  /// 判断是否为HLS流
  bool _isHlsStream(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.m3u8') ||
        lowerUrl.contains('application/vnd.apple.mpegurl') ||
        lowerUrl.contains('application/x-mpegurl');
  }

  /// 处理可能不完整的URL，与源地址拼接
  String _resolveIncompleteUrl(String url, String baseUrl) {
    // 如果URL已经是完整格式，直接返回
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    try {
      // 处理相对路径URL
      final baseUri = Uri.parse(baseUrl);

      // 如果是绝对路径（以/开头）
      if (url.startsWith('/')) {
        return '${baseUri.scheme}://${baseUri.host}$url';
      }

      // 处理相对路径
      final pathSegments = List<String>.from(baseUri.pathSegments);

      // 移除空的路径段
      pathSegments.removeWhere((element) => element.isEmpty);

      // 移除最后一级文件名，准备添加相对路径
      if (pathSegments.isNotEmpty && !baseUri.path.endsWith('/')) {
        pathSegments.removeLast();
      }

      // 分割并添加相对URL路径
      final relativeSegments =
          url.split('/').where((element) => element.isNotEmpty).toList();
      pathSegments.addAll(relativeSegments);

      return '${baseUri.scheme}://${baseUri.host}/${pathSegments.join('/')}';
    } catch (e) {
      debugPrint('URL解析错误: $e');
      // 如果解析失败，返回原始URL
      return url;
    }
  }

  void _reportVideoDuration() {
    if (!_hasReportedDuration) {
      _hasReportedDuration = true;
      final duration = _videoPlayer.value.duration.inSeconds;
      widget.onVideoDurationReceived?.call(duration);
    }
  }

  void _handleInitializationError(String error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  void _videoPlayerListener() {
    if (!_shouldCheckCompletion()) return;

    final position = _videoPlayer.value.position;
    final duration = _videoPlayer.value.duration;
    final difference = duration - position;

    // 检查预加载
    _checkPreloadCondition(position, duration);

    // 检查播放完成
    _checkPlaybackCompletion(difference);
  }

  bool _shouldCheckCompletion() {
    return _videoPlayer.value.isInitialized &&
        _videoPlayer.value.duration.inMilliseconds > 0 &&
        !_isDisposing &&
        !_hasCompleted;
  }

  void _checkPreloadCondition(Duration position, Duration duration) {
    if (widget.isShortDramaMode &&
        !_hasPreloaded &&
        widget.currentEpisodeIndex < widget.totalEpisodes - 1) {
      final progressPercentage =
          position.inMilliseconds / duration.inMilliseconds;
      if (progressPercentage >= 0.9) {
        _hasPreloaded = true;
        widget.onPreloadNextEpisode?.call();
      }
    }
  }

  void _checkPlaybackCompletion(Duration difference) {
    if (difference.inMilliseconds <= 1000 && difference.inMilliseconds >= -1000) {
      _hasCompleted = true;
      widget.onPlaybackCompleted?.call();
    }
  }

  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_shouldUpdateProgress()) {
        final position = _videoPlayer.value.position.inSeconds;
        _updateProgressAndHistory(position);
      }
    });
  }

  bool _shouldUpdateProgress() {
    return _videoPlayer.value.isInitialized &&
        !_isDisposing &&
        _videoPlayer.value.isPlaying;
  }

  void _updateProgressAndHistory(int position) {
    widget.onProgressUpdate?.call(position);
    _updateHistoryProgress(position);
  }

  // 历史记录管理方法
  void _recordInitialHistory() async {
    if (_hasRecordedInitialHistory) return;

    try {
      await HistoryService().addHistory(widget.media, widget.episode,
          widget.startPosition, _videoPlayer.value.duration.inSeconds);
      _hasRecordedInitialHistory = true;
    } catch (e) {
      // 历史记录失败，静默处理
    }
  }

  void _updateHistoryProgress(int progress) {
    if (!_hasRecordedInitialHistory) return;

    try {
      HistoryService().updateHistoryProgress(widget.media, widget.episode,
          progress, _videoPlayer.value.duration.inSeconds);
    } catch (e) {
      // 历史记录更新失败，静默处理
    }
  }

  void _updateFinalProgress() {
    if (_hasRecordedInitialHistory) {
      final position = _videoPlayer.value.position.inSeconds;
      HistoryService().updateHistoryProgress(widget.media, widget.episode,
          position, _videoPlayer.value.duration.inSeconds);
    }
  }

  // 处理键盘事件
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.space) {
      _togglePlayPause();
    }
  }

  // 切换播放/暂停状态
  void _togglePlayPause() {
    if (_videoPlayer.value.isPlaying) {
      _videoPlayer.pause();
    } else {
      _videoPlayer.play();
    }
    // 重新启动隐藏定时器
    _startHideControlsTimer();
  }

  // 切换全屏状态
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _uiState = _uiState.copyWith(isFullScreen: _isFullScreen);
    });

    // 系统级全屏处理
    if (_isFullScreen) {
      _enterFullScreen();
    } else {
      _exitFullScreen();
    }

    // 重新启动隐藏定时器
    _startHideControlsTimer();

    // 通知外部全屏状态变化
    widget.onFullScreenChanged?.call(_isFullScreen);
  }

  // 进入全屏模式
  void _enterFullScreen() {
    debugPrint('_enterFullScreen() 被调用');
    // 隐藏系统UI（状态栏、导航栏等）
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    debugPrint('系统UI已隐藏');
    
    // 设置屏幕方向为横屏（仅移动端）
    if (!_isDesktopPlatform()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      debugPrint('屏幕方向已设置为横屏');
    }
    
    // 在桌面端同时切换窗口全屏
    if (_isDesktopPlatform()) {
      WindowManager.setFullScreen(true);
      debugPrint('桌面端窗口已设置为全屏');
    }
  }

  // 退出全屏模式
  void _exitFullScreen() {
    // 恢复系统UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    
    // 恢复屏幕方向（仅移动端）
    if (!_isDesktopPlatform()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    
    // 在桌面端同时退出窗口全屏
    if (_isDesktopPlatform()) {
      WindowManager.setFullScreen(false);
    }
  }

  /// 检查是否为桌面平台
  bool _isDesktopPlatform() {
    return !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  }

  // 切换锁定状态
  void _toggleLock() {
    setState(() {
      _uiState = _uiState.copyWith(isLocked: !_uiState.isLocked);
    });
    // 通知父组件锁定状态变化
    if (widget.onFullScreenChanged != null) {
      // 这里可以添加一个专门的回调来处理锁定状态
      // 暂时通过全屏状态回调来传递
    }
  }

  // 设置播放速度
  void _setPlaybackSpeed(double speed) {
    _videoPlayer.setPlaybackSpeed(speed);
    setState(() {
      _uiState = _uiState.copyWith(currentSpeed: speed);
    });
    // 通知父组件播放速度变化
    if (widget.onFullScreenChanged != null) {
      // 这里可以添加一个专门的回调来处理播放速度
      // 暂时通过全屏状态回调来传递
    }
  }

  /// 设置倍速监听器
  void _setupSpeedListener() {
    // 获取VideoPlayerControllerProvider
    final provider = VideoPlayerControllerProvider.of(context);
    if (provider != null) {
      // 监听倍速变化
      provider.controller.playbackSpeed.addListener(_onSpeedChanged);
    }
  }

  /// 倍速变化回调
  void _onSpeedChanged() {
    final provider = VideoPlayerControllerProvider.of(context);
    if (provider != null && _isPlayerInitialized) {
      final speed = provider.controller.playbackSpeed.value;
      _setPlaybackSpeed(speed);
    }
  }

  /// 启动控制栏自动隐藏定时器
  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _videoPlayer.value.isPlaying) {
        setState(() {
          _uiState = _uiState.copyWith(controlsVisible: false);
        });
      }
    });
  }

  /// 显示控制栏并重新启动隐藏定时器
  void _showControls() {
    setState(() {
      _uiState = _uiState.copyWith(controlsVisible: true);
    });
    _startHideControlsTimer();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          const Text(
            '视频加载失败',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? '未知错误',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _retryInitialization,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    // 如果正在处理视频，显示处理状态
    if (_isProcessingVideo) {
      return Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 添加背景图片
              if (widget.media.poster != null &&
                  widget.media.poster!.isNotEmpty &&
                  !_imageLoadError)
                Image.network(
                  widget.media.poster!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      _isImageLoading = false;
                      return child;
                    } else {
                      return Container();
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    _imageLoadError = true;
                    return Container();
                  },
                ),
              // 处理状态信息
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimation(
                    showBackground: false,
                    sizeRatio: 0.2,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '正在准备视频...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '请稍候，这可能需要几秒钟',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 只在短剧模式下显示海报图片
    if (widget.isShortDramaMode &&
        widget.media.poster != null &&
        widget.media.poster!.isNotEmpty) {
      return Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 海报图片
              if (!_imageLoadError)
                Image.network(
                  widget.media.poster!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      _isImageLoading = false;
                      return child;
                    } else {
                      return const LoadingAnimation(
                        showBackground: true,
                        backgroundColor: Colors.black,
                        sizeRatio: 0.2,
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    _isImageLoading = false;
                    _imageLoadError = true;
                    return _buildDefaultLoadingWidget();
                  },
                ),
              // 加载动画（在图片加载期间显示）
              if (_isImageLoading)
                const LoadingAnimation(
                  showBackground: false,
                  sizeRatio: 0.2,
                ),
            ],
          ),
        ),
      );
    } else {
      // 非短剧模式或没有海报时显示默认加载控件
      return Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: _buildDefaultLoadingWidget(),
      );
    }
  }

  // 构建默认加载控件
  Widget _buildDefaultLoadingWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimation(
            showBackground: false,
            sizeRatio: 0.2,
          ),
          SizedBox(height: 16),
          Text(
            '正在加载视频...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    setState(() {
      _errorMessage = null;
      _isPlayerInitialized = false;
      _isImageLoading = true;
      _imageLoadError = false;
    });
    _initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (!_isPlayerInitialized) {
      return _buildLoadingWidget();
    }

    // 全屏时直接返回全屏播放器，不使用Scaffold
    if (_isFullScreen) {
      return _buildFullScreenPlayer();
    }

    // 非全屏时使用Scaffold
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        child: RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKey: _handleKeyEvent,
          child: GestureDetector(
            onTap: _showControls,
            child: _buildNormalPlayer(),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenPlayer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Focus(
        autofocus: true,
        child: RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKey: _handleKeyEvent,
          child: GestureDetector(
            onTap: _showControls,
            child: Stack(
              children: [
                // 全屏视频播放器 - 占满整个屏幕
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 计算视频的显示尺寸，保持宽高比
                      final videoAspectRatio = _videoPlayer.value.aspectRatio;
                      final screenWidth = constraints.maxWidth;
                      final screenHeight = constraints.maxHeight;
                      final screenAspectRatio = screenWidth / screenHeight;
                      
                      double displayWidth;
                      double displayHeight;
                      
                      if (videoAspectRatio > screenAspectRatio) {
                        // 视频更宽，以屏幕宽度为准
                        displayWidth = screenWidth;
                        displayHeight = screenWidth / videoAspectRatio;
                      } else {
                        // 视频更高，以屏幕高度为准
                        displayHeight = screenHeight;
                        displayWidth = screenHeight * videoAspectRatio;
                      }
                      
                      return Center(
                        child: SizedBox(
                          width: displayWidth,
                          height: displayHeight,
                          child: VideoPlayer(_videoPlayer),
                        ),
                      );
                    },
                  ),
                ),
                // 全屏控制界面
                NormalControls(
                  controller: _videoPlayer,
                  uiState: _uiState,
                  title: widget.media.name,
                  onPlayPause: _togglePlayPause,
                  onToggleFullScreen: _toggleFullScreen,
                  onToggleLock: _toggleLock,
                  onBack: widget.onBackPressed,
                  onSeek: (position) {
                    final duration = _videoPlayer.value.duration;
                    final seekPosition = Duration(
                      milliseconds: (position * duration.inMilliseconds).round(),
                    );
                    _videoPlayer.seekTo(seekPosition);
                  },
                  onShowEpisodeSelector: widget.onShowEpisodeSelector,
                  onSpeedChanged: _setPlaybackSpeed,
                  playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
                  currentSpeed: _uiState.currentSpeed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalPlayer() {
    return Stack(
      children: [
        // 普通视频播放器
        AspectRatio(
          aspectRatio: _videoPlayer.value.aspectRatio,
          child: VideoPlayer(_videoPlayer),
        ),
        // 普通控制界面
        NormalControls(
          controller: _videoPlayer,
          uiState: _uiState,
          title: widget.media.name,
          onPlayPause: _togglePlayPause,
          onToggleFullScreen: _toggleFullScreen,
          onToggleLock: _toggleLock,
          onBack: widget.onBackPressed,
          onSeek: (position) {
            final duration = _videoPlayer.value.duration;
            final seekPosition = Duration(
              milliseconds: (position * duration.inMilliseconds).round(),
            );
            _videoPlayer.seekTo(seekPosition);
          },
        ),
      ],
    );
  }

  // 数据获取方法
  bool get isFullScreen => _isFullScreen;
  bool get isInitialized => _isPlayerInitialized;
  VideoPlayerController get videoPlayerController => _videoPlayer;

}