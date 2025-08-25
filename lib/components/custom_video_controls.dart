import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:ui'; // Added for ImageFilter

class CustomControls extends StatefulWidget {
  final bool? isShortDramaMode; // 短剧模式参数
  final VoidCallback? onBackPressed; // 返回按钮回调
  final VoidCallback? onNextEpisode; // 下一集回调
  final VoidCallback? onPrevEpisode; // 上一集回调
  final String? episodeTitle; // 剧集标题
  final String? mediaTitle; // 媒体标题
  final int currentEpisodeIndex; // 当前剧集索引
  final int totalEpisodes; // 总剧集数
  final Function(int)? onEpisodeChanged; // 剧集切换回调

  const CustomControls({
    super.key, 
    bool? isShortDramaMode,
    this.onBackPressed,
    this.onNextEpisode,
    this.onPrevEpisode,
    this.episodeTitle,
    this.mediaTitle,
    this.currentEpisodeIndex = 0,
    this.totalEpisodes = 0,
    this.onEpisodeChanged,
  }) : isShortDramaMode = isShortDramaMode ?? false;

  @override
  State<CustomControls> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls>
    with SingleTickerProviderStateMixin {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  late VideoPlayerValue _latestValue;
  
  // 控制层可见性状态
  bool _isVisible = true;
  // 计时器用于自动隐藏控制层
  Timer? _hideTimer;
  // 自动隐藏的延迟时间（毫秒）
  static const int _hideDelay = 3000; // 3秒后自动隐藏
  
  // 快进快退相关变量
  bool _isSeeking = false;
  bool _isForward = false;
  Timer? _seekTimer;
  // 添加快进快退速度控制
  static const int _seekStepMs = 500; // 每次跳转的毫秒数
  static const int _seekIntervalMs = 100; // 跳转间隔毫秒数
  double _seekSpeedMultiplier = 1.0; // 速度倍数
  DateTime _lastSeekTime = DateTime.now(); // 上次跳转时间

  // 进度条拖动状态
  bool _isProgressDragging = false;
  Duration? _draggingPosition;

  // 暂停图标动画控制器
  late AnimationController _pauseIconAnimationController;
  late Animation<double> _pauseIconScaleAnimation;
  late Animation<double> _pauseIconOpacityAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化时启动计时器
    _startHideTimer();
    
    // 初始化暂停图标动画
    _pauseIconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pauseIconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pauseIconAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _pauseIconOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pauseIconAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // 如果初始状态是暂停的，立即显示图标
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_videoPlayerController.value.isPlaying) {
        _pauseIconAnimationController.value = 1.0;
      }
    });
  }

  @override
  void dispose() {
    // 清除计时器
    _hideTimer?.cancel();
    _seekTimer?.cancel();
    _pauseIconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _chewieController = ChewieController.of(context);
    _videoPlayerController = _chewieController.videoPlayerController;
    _latestValue = _videoPlayerController.value;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _getTapHandler(),
        onLongPressStart: _handleLongPressStart,
        onLongPressMoveUpdate: _handleLongPressMoveUpdate,
        onLongPressEnd: _handleLongPressEnd,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              // 快进快退指示器
              _buildSeekingIndicator(),
              // 进度拖动蒙版
              _buildProgressDraggingOverlay(),
              // 根据模式构建控制层
              _buildControlsByMode(),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - 模式判断方法
  bool get _isShortDramaMode => widget.isShortDramaMode == true;
  bool get _isFullScreenMode => _chewieController.isFullScreen;
  bool get _isNormalMode => !_isShortDramaMode && !_isFullScreenMode;

  // MARK: - 点击处理器
  VoidCallback _getTapHandler() {
    if (_isShortDramaMode) {
      return _toggleShortDramaPlayPause;
    } else {
      return _toggleControls;
    }
  }

  // MARK: - 控制层构建方法
  Widget _buildControlsByMode() {
    if (_isShortDramaMode) {
      return _buildShortDramaControls();
    } else if (_isFullScreenMode) {
      return _buildFullScreenControls();
    } else {
      return _buildNormalControls();
    }
  }

  // MARK: - 短剧模式控制层
  Widget _buildShortDramaControls() {
    return Stack(
      children: [
        // 返回按钮
        Positioned(
          top: MediaQuery.of(context).padding.top + 8.0,
          left: 8.0,
          child: _buildBackButton(),
        ),
        // 播放/暂停图标（暂停时显示）
        if (!_videoPlayerController.value.isPlaying)
          Center(
            child: _buildAnimatedPauseIcon(),
          ),
        // 底部进度条
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildShortDramaBottomBar(),
        ),
      ],
    );
  }

  // MARK: - 动画暂停图标
  Widget _buildAnimatedPauseIcon() {
    return AnimatedBuilder(
      animation: _pauseIconAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pauseIconScaleAnimation.value,
          child: Opacity(
            opacity: _pauseIconOpacityAnimation.value,
            child: Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(60.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20.0,
                    spreadRadius: 5.0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60.0),
                    ),
                    child: Center(
                      child: CustomPlayIcon(
                        size: 60.0,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // MARK: - 全屏模式控制层
  Widget _buildFullScreenControls() {
    if (!_isVisible) return const SizedBox();
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(0, 0, 0, 0.7),
            Color.fromRGBO(0, 0, 0, 0.0),
            Color.fromRGBO(0, 0, 0, 0.0),
            Color.fromRGBO(0, 0, 0, 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // 顶部控制栏
          _buildFullScreenTopBar(),
          // 中间播放/暂停按钮（在快进快退时隐藏）
          if (!_isSeeking) _buildFullScreenMiddleBar(),
          // 底部控制栏
          _buildFullScreenBottomBar(),
        ],
      ),
    );
  }

  // MARK: - 普通模式控制层
  Widget _buildNormalControls() {
    if (!_isVisible) return const SizedBox();
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(0, 0, 0, 0.7),
            Color.fromRGBO(0, 0, 0, 0.0),
            Color.fromRGBO(0, 0, 0, 0.0),
            Color.fromRGBO(0, 0, 0, 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // 顶部控制栏
          _buildNormalTopBar(),
          // 中间播放/暂停按钮（在快进快退时隐藏）
          if (!_isSeeking) _buildNormalMiddleBar(),
          // 底部控制栏
          _buildNormalBottomBar(),
        ],
      ),
    );
  }

  // MARK: - 顶部控制栏构建方法
  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        _isFullScreenMode ? Icons.keyboard_arrow_down : Icons.arrow_back,
        color: Colors.white,
        size: 30.0,
      ),
      onPressed: () {
        if (_isFullScreenMode) {
          _chewieController.exitFullScreen();
        } else {
          widget.onBackPressed?.call();
        }
        _resetHideTimer();
      },
    );
  }

  Widget _buildFullScreenTopBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // 返回按钮
            _buildBackButton(),
            // 标题显示
            Expanded(
              child: Text(
                widget.mediaTitle ?? '视频播放',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 右侧按钮
            Row(
              children: [
                // 锁定屏幕按钮
                IconButton(
                  icon: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  onPressed: () {
                    // TODO: 实现锁定屏幕功能
                    _resetHideTimer();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalTopBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // 返回按钮
            _buildBackButton(),
            // 右侧按钮
            Row(
              children: [
                // 全屏按钮
                IconButton(
                  icon: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  onPressed: () {
                    _chewieController.toggleFullScreen();
                    _resetHideTimer();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - 中间控制栏构建方法
  Widget _buildFullScreenMiddleBar() {
    final bool isFinished = (_latestValue.position >= _latestValue.duration) &&
        _latestValue.duration.inSeconds > 0;

    return Expanded(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // 上一集按钮
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 40.0,
              ),
              onPressed: widget.currentEpisodeIndex > 0 ? () {
                widget.onPrevEpisode?.call();
                _resetHideTimer();
              } : null,
            ),
            // 快退按钮
            IconButton(
              icon: const Icon(
                Icons.replay_10,
                color: Colors.white,
                size: 40.0,
              ),
              onPressed: isFinished ? null : () {
                _chewieController.seekTo(
                  _videoPlayerController.value.position -
                      const Duration(seconds: 10),
                );
                _resetHideTimer();
              },
            ),
            // 播放/暂停按钮
            _buildPlayPauseButton(),
            // 快进按钮
            IconButton(
              icon: const Icon(
                Icons.forward_10,
                color: Colors.white,
                size: 40.0,
              ),
              onPressed: isFinished ? null : () {
                _chewieController.seekTo(
                  _videoPlayerController.value.position +
                      const Duration(seconds: 10),
                );
                _resetHideTimer();
              },
            ),
            // 下一集按钮
            IconButton(
              icon: const Icon(
                Icons.skip_next,
                color: Colors.white,
                size: 40.0,
              ),
              onPressed: widget.currentEpisodeIndex < widget.totalEpisodes - 1 ? () {
                widget.onNextEpisode?.call();
                _resetHideTimer();
              } : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalMiddleBar() {
    final bool isFinished = (_latestValue.position >= _latestValue.duration) &&
        _latestValue.duration.inSeconds > 0;

    return Expanded(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // 快退按钮
            IconButton(
              icon: const Icon(
                Icons.replay_10,
                color: Colors.white,
                size: 40.0,
              ),
              onPressed: isFinished ? null : () {
                _chewieController.seekTo(
                  _videoPlayerController.value.position -
                      const Duration(seconds: 10),
                );
                _resetHideTimer();
              },
            ),
            // 播放/暂停按钮
            _buildPlayPauseButton(),
            // 快进按钮
            IconButton(
              icon: const Icon(
                Icons.forward_10,
                color: Colors.white,
                size: 40.0,
              ),
              onPressed: isFinished ? null : () {
                _chewieController.seekTo(
                  _videoPlayerController.value.position +
                      const Duration(seconds: 10),
                );
                _resetHideTimer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      icon: Icon(
        _videoPlayerController.value.isPlaying
            ? Icons.pause
            : Icons.play_arrow,
        color: Colors.white,
        size: 60.0,
      ),
      onPressed: () {
        if (_videoPlayerController.value.isPlaying) {
          _chewieController.pause();
        } else {
          _chewieController.play();
        }
        _resetHideTimer();
      },
    );
  }

  // MARK: - 底部控制栏构建方法
  Widget _buildShortDramaBottomBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 52.0), // 为卡片留出空间
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildShortDramaProgressBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenBottomBar() {
    return SafeArea(
      child: Column(
        children: [
          // 进度条
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: VideoProgressIndicator(
              _videoPlayerController,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Color.fromARGB(255, 255, 0, 0),
                bufferedColor: Color.fromARGB(130, 255, 255, 255),
                backgroundColor: Color.fromARGB(50, 255, 255, 255),
              ),
            ),
          ),
          // 控制按钮行
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // 播放时间显示
                Text(
                  '${_formatDuration(_videoPlayerController.value.position)} / ${_formatDuration(_videoPlayerController.value.duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
                // 控制按钮
                Row(
                  children: <Widget>[
                    // 播放速度按钮
                    IconButton(
                      icon: const Icon(
                        Icons.speed,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      onPressed: () {
                        _showPlaybackSpeedDialog();
                        _resetHideTimer();
                      },
                    ),
                    // 全屏按钮
                    IconButton(
                      icon: const Icon(
                        Icons.fullscreen_exit,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      onPressed: () {
                        _chewieController.toggleFullScreen();
                        _resetHideTimer();
                      },
                    ),
                    // 选集按钮
                    IconButton(
                      icon: const Icon(
                        Icons.playlist_play,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      onPressed: () {
                        _showEpisodeSelector();
                        _resetHideTimer();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalBottomBar() {
    return SafeArea(
      child: Column(
        children: [
          // 进度条
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: VideoProgressIndicator(
              _videoPlayerController,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Color.fromARGB(255, 255, 0, 0),
                bufferedColor: Color.fromARGB(130, 255, 255, 255),
                backgroundColor: Color.fromARGB(50, 255, 255, 255),
              ),
            ),
          ),
          // 控制按钮行
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // 播放时间显示
                Text(
                  '${_formatDuration(_videoPlayerController.value.position)} / ${_formatDuration(_videoPlayerController.value.duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
                // 控制按钮
                Row(
                  children: <Widget>[
                    // 播放速度按钮
                    IconButton(
                      icon: const Icon(
                        Icons.speed,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      onPressed: () {
                        _showPlaybackSpeedDialog();
                        _resetHideTimer();
                      },
                    ),
                    // 全屏按钮
                    IconButton(
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      onPressed: () {
                        _chewieController.toggleFullScreen();
                        _resetHideTimer();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - 进度条构建方法
  Widget _buildShortDramaProgressBar() {
    return GestureDetector(
      onPanStart: _onProgressPanStart,
      onPanUpdate: _onProgressPanUpdate,
      onPanEnd: _onProgressPanEnd,
      child: Container(
        height: _isProgressDragging ? 8.0 : 4.0, // 拖动时加宽
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_isProgressDragging ? 4.0 : 2.0),
        ),
        child: Stack(
          children: [
            // 背景
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(_isProgressDragging ? 4.0 : 2.0),
              ),
            ),
            // 缓冲进度
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _videoPlayerController,
              builder: (context, value, child) {
                if (value.duration.inMilliseconds == 0) return const SizedBox();
                
                final bufferedProgress = value.buffered.isEmpty 
                    ? 0.0 
                    : value.buffered.last.end.inMilliseconds / value.duration.inMilliseconds;
                
                return FractionallySizedBox(
                  widthFactor: bufferedProgress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(_isProgressDragging ? 4.0 : 2.0),
                    ),
                  ),
                );
              },
            ),
            // 播放进度
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _videoPlayerController,
              builder: (context, value, child) {
                if (value.duration.inMilliseconds == 0) return const SizedBox();
                
                final currentPosition = _isProgressDragging && _draggingPosition != null
                    ? _draggingPosition!
                    : value.position;
                final progress = currentPosition.inMilliseconds / value.duration.inMilliseconds;
                
                return FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(_isProgressDragging ? 4.0 : 2.0),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - 指示器和蒙版构建方法
  Widget _buildSeekingIndicator() {
    if (!_isSeeking) return const SizedBox();
    
    return Center(
      child: Text(
        _isShortDramaMode 
            ? '2.0x倍速播放中...'
            : '${_isForward ? "快进" : "快退"}中...',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressDraggingOverlay() {
    if (!_isProgressDragging || !_isShortDramaMode) return const SizedBox();
    
    return Positioned(
      bottom: 80.0, // 在进度条上方
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _draggingPosition != null 
                  ? _formatDuration(_draggingPosition!)
                  : _formatDuration(_videoPlayerController.value.position),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              ' / ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.0,
              ),
            ),
            Text(
              _formatDuration(_videoPlayerController.value.duration),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - 播放控制方法
  void _toggleShortDramaPlayPause() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      // 暂停时播放动画：由小到大，透明度从0到1
      _pauseIconAnimationController.forward();
    } else {
      _videoPlayerController.play();
      // 播放时反向动画：由大到小，透明度从1到0
      _pauseIconAnimationController.reverse();
    }
  }

  void _toggleControls() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  // MARK: - 长按控制方法
  void _handleLongPressStart(LongPressStartDetails details) {
    final double touchPosition = details.localPosition.dx;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (_isShortDramaMode) {
      // 短剧模式：只有右侧长按才快进
      if (touchPosition > screenWidth / 2) {
        _startSeeking(true);
      }
    } else {
      // 其他模式：左侧快退，右侧快进
      if (touchPosition < screenWidth / 2) {
        _startSeeking(false);
      } else {
        _startSeeking(true);
      }
    }
  }
  
  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final double touchPosition = details.localPosition.dx;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (_isShortDramaMode) {
      // 短剧模式：只有右侧长按才快进
      if (touchPosition > screenWidth / 2) {
        if (!_isSeeking || !_isForward) {
          _stopSeeking();
          _startSeeking(true);
        }
      } else {
        _stopSeeking();
      }
    } else {
      // 其他模式：根据位置更新快进或快退状态
      if (touchPosition < screenWidth / 2) {
        if (_isForward) {
          _stopSeeking();
          _startSeeking(false);
        } else if (!_isSeeking) {
          _startSeeking(false);
        }
      } else {
        if (!_isForward) {
          _stopSeeking();
          _startSeeking(true);
        } else if (!_isSeeking) {
          _startSeeking(true);
        }
      }
    }
  }
  
  void _handleLongPressEnd(LongPressEndDetails details) {
    _stopSeeking();
  }

  // MARK: - 快进快退方法
  void _startSeeking(bool isForward) {
    setState(() {
      _isSeeking = true;
      _isForward = isForward;
    });
    
    _seekTimer?.cancel();
    
    if (_isShortDramaMode) {
      // 短剧模式：使用倍速播放
      _startSpeedPlayback();
    } else {
      // 其他模式：使用跳转方式
      _lastSeekTime = DateTime.now();
      _performSeek();
      
      _seekTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _performSeek();
      });
    }
  }
  
  void _startSpeedPlayback() {
    _videoPlayerController.setPlaybackSpeed(2.0);
    setState(() {
      _isSeeking = true;
    });
  }
  
  void _performSeek() {
    if (!_isSeeking) return;
    
    final currentPosition = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;
    
    final now = DateTime.now();
    final elapsed = now.difference(_lastSeekTime).inMilliseconds;
    _lastSeekTime = now;
    
    if (elapsed > _seekIntervalMs * 3) {
      _seekSpeedMultiplier = 1.0;
    } else {
      _seekSpeedMultiplier = (_seekSpeedMultiplier * 1.05).clamp(1.0, 10.0);
    }
    
    final stepMs = (_seekStepMs * _seekSpeedMultiplier).round();
    
    Duration newPosition;
    if (_isForward) {
      newPosition = currentPosition + Duration(milliseconds: stepMs);
    } else {
      newPosition = currentPosition - Duration(milliseconds: stepMs);
    }
    
    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    } else if (newPosition > duration) {
      newPosition = duration;
    }
    
    _chewieController.seekTo(newPosition);
    _resetHideTimer();
  }
  
  void _stopSeeking() {
    _seekTimer?.cancel();
    
    if (_isShortDramaMode) {
      _videoPlayerController.setPlaybackSpeed(1.0);
    }
    
    setState(() {
      _isSeeking = false;
    });
  }

  // MARK: - 进度条拖动方法
  void _onProgressPanStart(DragStartDetails details) {
    if (!_isShortDramaMode) return;
    
    setState(() {
      _isProgressDragging = true;
    });
    _updateDraggingPosition(details.localPosition.dx);
  }
  
  void _onProgressPanUpdate(DragUpdateDetails details) {
    if (!_isShortDramaMode) return;
    
    _updateDraggingPosition(details.localPosition.dx);
  }
  
  void _onProgressPanEnd(DragEndDetails details) {
    if (!_isShortDramaMode) return;
    
    if (_draggingPosition != null) {
      _chewieController.seekTo(_draggingPosition!);
    }
    
    setState(() {
      _isProgressDragging = false;
      _draggingPosition = null;
    });
  }
  
  void _updateDraggingPosition(double localX) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width - 16.0;
    final progress = (localX / width).clamp(0.0, 1.0);
    final duration = _videoPlayerController.value.duration;
    final newPosition = Duration(milliseconds: (duration.inMilliseconds * progress).round());
    
    setState(() {
      _draggingPosition = newPosition;
    });
  }

  // MARK: - 计时器方法
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(milliseconds: _hideDelay), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
    _startHideTimer();
  }

  // MARK: - 工具方法
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  // MARK: - 对话框方法
  void _showPlaybackSpeedDialog() {
    final speeds = _chewieController.playbackSpeeds;
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('播放速度'),
        children: speeds.map((speed) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现播放速度切换
            },
            child: Text('${speed}x'),
          );
        }).toList(),
      ),
    );
  }

  void _showEpisodeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选集 (${widget.currentEpisodeIndex + 1}/${widget.totalEpisodes})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: widget.totalEpisodes,
            itemBuilder: (context, index) {
              final isSelected = index == widget.currentEpisodeIndex;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  widget.onEpisodeChanged?.call(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.red 
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 14.0,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

// MARK: - 自定义播放图标
class CustomPlayIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CustomPlayIcon({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: PlayIconPainter(color: color),
    );
  }
}

class PlayIconPainter extends CustomPainter {
  final Color color;

  PlayIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 绘制播放图标（三角形）
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final triangleWidth = size.width * 0.6;
    final triangleHeight = size.height * 0.6;
    
    // 绘制向右的三角形播放图标
    path.moveTo(centerX - triangleWidth * 0.2, centerY - triangleHeight * 0.5);
    path.lineTo(centerX - triangleWidth * 0.2, centerY + triangleHeight * 0.5);
    path.lineTo(centerX + triangleWidth * 0.8, centerY);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}