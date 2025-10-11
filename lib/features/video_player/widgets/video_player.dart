import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui; // 添加ui库导入以使用SystemMouseCursors
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';
import 'package:vision_x_flutter/features/video_player/widgets/video_controls/video_controls.dart';
import 'package:vision_x_flutter/features/video_player/widgets/video_controls/video_control_models.dart'
    as models;
import 'package:vision_x_flutter/services/history_service.dart';
import 'package:vision_x_flutter/services/enhanced_video_service.dart';
import 'package:vision_x_flutter/shared/widgets/loading_animation.dart';
// 添加HLS解析器服务导入
import 'package:vision_x_flutter/services/hls_parser_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 条件导入window_size包，仅在桌面端使用
import 'package:window_size/window_size.dart'
    if (dart.library.html) 'package:window_size/noop_window_size.dart';
import 'package:vision_x_flutter/core/utils/window_manager.dart';

// MARK: - 视频播放器配置
class VideoPlayerConfig {
  // 进度更新间隔
  static const Duration progressUpdateInterval = Duration(seconds: 30);

  // 播放速度选项
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // 预加载阈值（视频播放到90%时开始预加载）
  static const double preloadThreshold = 0.9;

  // 播放完成检测阈值（毫秒）
  static const int completionThresholdMs = 1000;
}

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
  final VoidCallback? onShowEpisodeSelector; // 显示剧集选择器回调
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
    this.onShowEpisodeSelector,
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
  bool _hasRecordedInitialHistory = false; // 添加历史记录标志

  // 广告检测相关
  final EnhancedVideoService _enhancedVideoService = EnhancedVideoService();
  bool _isProcessingVideo = false;
  String? _processedVideoUrl;
  ProcessedVideoResult? _processingResult;

  // 添加HLS解析器服务
  final HlsParserService _hlsParserService = HlsParserService();

  // 播放状态数据
  final bool _isPlaying = false;
  final Duration _currentPosition = Duration.zero;
  final Duration _totalDuration = Duration.zero;
  final bool _isBuffering = false;
  final double _playbackSpeed = 1.0;

  // 错误处理
  String? _errorMessage;

  // 图片加载状态
  bool _isImageLoading = true;
  bool _imageLoadError = false;

  @override
  void initState() {
    super.initState();
    // 添加一个微任务来注册点击事件处理器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  Future<void> _initializePlayer() async {
    try {
      // 确保在组件未被销毁时才进行初始化
      if (!mounted || _isDisposing) return;

      // 处理视频URL（检测和过滤广告）
      await _processVideoUrlWithHlsParser();

      // 使用处理后的URL或原始URL
      final videoUrl = _processedVideoUrl ?? widget.episode.url;

      _videoPlayer = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

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

      // 创建Chewie控制器
      _createChewieController();

      if (mounted) {
        setState(() {
          _isPlayerInitialized = true;
        });
      }
    } catch (e) {
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
            // debugPrint('处理后的播放列表: $processedPlaylist');
            // 将处理后的播放列表保存到本地文件
            final processedUrl =
                await _saveProcessedPlaylist(processedPlaylist);

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

      // 返回文件路径 (在实际应用中，您可能需要启动一个本地HTTP服务器来提供这个文件)
      // 这里我们返回文件URI
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

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayer,
      autoPlay: true,
      looping: false,
      allowedScreenSleep: false,
      aspectRatio: _videoPlayer.value.aspectRatio,
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      playbackSpeeds: VideoPlayerConfig.playbackSpeeds,
      showControls: true, // 确保显示控制栏
      showOptions: true, // 确保显示选项
      showControlsOnInitialize: true, // 初始化时显示控制栏
      customControls: _DynamicVideoControls(
        controller: _videoPlayer,
        controlMode: widget.isShortDramaMode
            ? ControlMode.shortDrama
            : ControlMode.normal,
        title: widget.media.name,
        episodeTitle: widget.episode.title,
        currentEpisodeIndex: widget.currentEpisodeIndex,
        totalEpisodes: widget.totalEpisodes,
        onPlayPause: () {
          if (_videoPlayer.value.isPlaying) {
            _videoPlayer.pause();
          } else {
            _videoPlayer.play();
          }
        },
        onBack: widget.onBackPressed,
        onToggleFullScreen: () {
          debugPrint('CustomVideoPlayer: onToggleFullScreen callback called');
          toggleFullScreen();
        },
        onNextEpisode: widget.onNextEpisode,
        onPrevEpisode: widget.onPrevEpisode,
        onSeek: (position) {
          final duration = _videoPlayer.value.duration;
          final seekPosition = Duration(
            milliseconds: (position * duration.inMilliseconds).round(),
          );
          _videoPlayer.seekTo(seekPosition);
        },
      ),
      placeholder:
          widget.media.poster != null ? _buildPosterPlaceholder() : null,
    );

    // 添加点击播放器区域的事件监听
    _chewieController.addListener(_handlePlayerTap);
  }

  // 处理播放器区域点击事件
  void _handlePlayerTap() {
    // 这个方法会在Chewie控制器状态改变时被调用
    // 我们需要监听特定的点击事件
  }

  // 构建海报占位符
  Widget _buildPosterPlaceholder() {
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
                      // 加载完成
                      _isImageLoading = false;
                      return child;
                    } else {
                      // 加载中
                      return const LoadingAnimation(
                        showBackground: true,
                        backgroundColor: Colors.black,
                        sizeRatio: 0.2,
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // 加载失败
                    _isImageLoading = false;
                    _imageLoadError = true;
                    return _buildDefaultPlaceholder(BoxConstraints.tight(
                        const Size(double.infinity, double.infinity)));
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
      // 非短剧模式或没有海报时显示默认占位符
      return Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  // 构建默认占位符
  Widget _buildDefaultPlaceholder(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      color: Colors.black,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie,
            size: 64,
            color: Colors.white38,
          ),
          SizedBox(height: 16),
          Text(
            '视频加载中...',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
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
      if (progressPercentage >= VideoPlayerConfig.preloadThreshold) {
        _hasPreloaded = true;
        widget.onPreloadNextEpisode?.call();
      }
    }
  }

  void _checkPlaybackCompletion(Duration difference) {
    if (difference.inMilliseconds <= VideoPlayerConfig.completionThresholdMs &&
        difference.inMilliseconds >= -VideoPlayerConfig.completionThresholdMs) {
      _hasCompleted = true;
      widget.onPlaybackCompleted?.call();
    }
  }

  void _startProgressTracking() {
    _progressTimer =
        Timer.periodic(VideoPlayerConfig.progressUpdateInterval, (timer) {
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

  // MARK: - 历史记录管理方法
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
      pause();
    } else {
      play();
    }
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
                      // 加载完成
                      _isImageLoading = false;
                      return child;
                    } else {
                      // 加载中
                      return Container(); // 加载过程中不显示
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // 加载失败
                    _imageLoadError = true;
                    return Container(); // 错误时也不显示
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
                      // 加载完成
                      _isImageLoading = false;
                      return child;
                    } else {
                      // 加载中
                      return const LoadingAnimation(
                        showBackground: true,
                        backgroundColor: Colors.black,
                        sizeRatio: 0.2,
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // 加载失败
                    _isImageLoading = false;
                    _imageLoadError = true;
                    return _buildDefaultLoadingWidget(BoxConstraints.tight(
                        const Size(double.infinity, double.infinity)));
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
        child: _buildDefaultLoadingWidget(
            BoxConstraints.tight(const Size(double.infinity, double.infinity))),
      );
    }
  }

  // 构建默认加载控件
  Widget _buildDefaultLoadingWidget(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
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
    debugPrint('CustomVideoPlayer: toggleFullScreen called');
    _chewieController.toggleFullScreen();

    // 在桌面端同时切换窗口全屏
    _toggleWindowFullScreen();
  }

  void exitFullScreen() {
    debugPrint('CustomVideoPlayer: exitFullScreen called');
    _chewieController.exitFullScreen();

    // 在桌面端同时退出窗口全屏
    _setWindowFullScreen(false);
  }

  /// 切换窗口全屏状态（仅桌面端）
  void _toggleWindowFullScreen() {
    debugPrint(
        'CustomVideoPlayer: _toggleWindowFullScreen called, isDesktop=${_isDesktopPlatform()}');
    // 只在桌面平台执行
    if (_isDesktopPlatform()) {
      debugPrint('CustomVideoPlayer: Calling WindowManager.toggleFullScreen()');
      WindowManager.toggleFullScreen();
    } else {
      debugPrint(
          'CustomVideoPlayer: Not a desktop platform, skipping window full screen');
    }
  }

  /// 设置窗口全屏状态（仅桌面端）
  void _setWindowFullScreen(bool fullScreen) {
    debugPrint(
        'CustomVideoPlayer: _setWindowFullScreen called, fullScreen=$fullScreen, isDesktop=${_isDesktopPlatform()}');
    // 只在桌面平台执行
    if (_isDesktopPlatform()) {
      debugPrint(
          'CustomVideoPlayer: Calling WindowManager.setFullScreen($fullScreen)');
      WindowManager.setFullScreen(fullScreen);
    } else {
      debugPrint(
          'CustomVideoPlayer: Not a desktop platform, skipping window full screen');
    }
  }

  /// 检查是否为桌面平台
  bool _isDesktopPlatform() {
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    debugPrint(
        'CustomVideoPlayer: _isDesktopPlatform result: $isDesktop (kIsWeb=$kIsWeb, Platform.isWindows=${Platform.isWindows}, Platform.isMacOS=${Platform.isMacOS}, Platform.isLinux=${Platform.isLinux})');
    return isDesktop;
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (!_isPlayerInitialized) {
      return _buildLoadingWidget();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        child: RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKey: _handleKeyEvent,
          child: Chewie(
            controller: _chewieController,
          ),
        ),
      ),
    );
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

    // 更新最终进度
    _updateFinalProgress();

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

/// 动态视频控制器，能够响应播放状态变化
class _DynamicVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final ControlMode controlMode;
  final String? title;
  final String? episodeTitle;
  final int currentEpisodeIndex;
  final int totalEpisodes;
  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final VoidCallback? onToggleFullScreen; // 添加全屏切换回调
  final VoidCallback? onNextEpisode;
  final VoidCallback? onPrevEpisode;
  final ValueChanged<double>? onSeek;

  const _DynamicVideoControls({
    required this.controller,
    required this.controlMode,
    this.title,
    this.episodeTitle,
    this.currentEpisodeIndex = 0,
    this.totalEpisodes = 0,
    this.onPlayPause,
    this.onBack,
    this.onToggleFullScreen, // 添加全屏切换回调参数
    this.onNextEpisode,
    this.onPrevEpisode,
    this.onSeek,
  });

  @override
  State<_DynamicVideoControls> createState() => _DynamicVideoControlsState();
}

class _DynamicVideoControlsState extends State<_DynamicVideoControls> {
  bool _controlsVisible = true;
  Timer? _hideTimer;
  bool _isFullScreen = false;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPlayerStateChanged);
    // 初始化时启动隐藏计时器
    _startHideTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在didChangeDependencies中获取并保存chewieController的引用
    _chewieController = ChewieController.of(context);
    if (_chewieController != null) {
      _isFullScreen = _chewieController!.isFullScreen;
      _chewieController!.addListener(_onFullScreenChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPlayerStateChanged);

    // 使用保存的引用而不是重新获取
    if (_chewieController != null) {
      _chewieController!.removeListener(_onFullScreenChanged);
    }

    _hideTimer?.cancel();
    super.dispose();
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFullScreenChanged() {
    // 使用保存的引用
    if (_chewieController != null && mounted) {
      setState(() {
        _isFullScreen = _chewieController!.isFullScreen;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    // 3秒后隐藏控制界面
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _showControls() {
    setState(() {
      _controlsVisible = true;
    });
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isFullScreen && !_controlsVisible
          ? SystemMouseCursors.none // 全屏且控制界面隐藏时隐藏鼠标指针
          : SystemMouseCursors.basic, // 其他情况下显示默认光标
      onEnter: (_) => _showControls(), // 鼠标进入时显示控制界面
      onHover: (event) {
        // 只有在全屏模式下才处理鼠标悬停事件
        if (_isFullScreen) {
          _showControls();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // 确保点击事件能够被正确处理
        onTap: () {
          debugPrint('_DynamicVideoControls: GestureDetector tapped');
          // 点击播放区域时，总是显示控制栏
          _showControls();

          // 如果是在桌面端，则同时切换播放/暂停状态
          if (!kIsWeb &&
              (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
            if (widget.controller.value.isPlaying) {
              widget.controller.pause();
            } else {
              widget.controller.play();
            }
          }
        },
        child: UnifiedVideoControls(
          controller: widget.controller,
          uiState: models.UIState(
            controlsVisible: _controlsVisible,
            showBigPlayButton: !widget.controller.value.isPlaying,
            isFullScreen: _isFullScreen, // 传递全屏状态
          ),
          // 根据全屏状态动态选择控制模式
          controlMode: widget.controlMode == ControlMode.shortDrama
              ? ControlMode.shortDrama
              : _isFullScreen
                  ? ControlMode.fullScreen
                  : ControlMode.normal,
          title: widget.title,
          episodeTitle: widget.episodeTitle,
          currentEpisodeIndex: widget.currentEpisodeIndex,
          totalEpisodes: widget.totalEpisodes,
          onPlayPause: widget.onPlayPause,
          onBack: widget.onBack,
          onToggleFullScreen: widget.onToggleFullScreen, // 确保传递全屏切换回调
          onNextEpisode: widget.onNextEpisode,
          onPrevEpisode: widget.onPrevEpisode,
          onSeek: widget.onSeek,
        ),
      ),
    );
  }
}
