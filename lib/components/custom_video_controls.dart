import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';

// MARK: - 常量配置
class VideoControlConfig {
  // 计时器配置
  static const int hideDelayMs = 3000; // 自动隐藏延迟时间（毫秒）

  // 快进快退配置
  static const int seekStepMs = 500; // 每次跳转的毫秒数
  static const int seekIntervalMs = 100; // 跳转间隔毫秒数
  static const double maxSeekSpeedMultiplier = 10.0; // 最大速度倍数
  static const double seekSpeedIncrement = 1.05; // 速度递增倍数

  // UI配置
  static const double backButtonSize = 30.0;
  static const double playButtonSize = 40.0;
  static const double controlButtonSize = 24.0;
  static const double pauseIconSize = 80.0;
  static const double lockButtonSize = 30.0;

  // 间距配置
  static const double topPadding = 8.0;
  static const double sidePadding = 8.0;
  static const double bottomPadding = 52.0;
  static const double gestureExcludeTop = 50.0;
  static const double gestureExcludeSide = 50.0;
  static const double gestureExcludeBottom = 100.0;

  // 颜色配置
  static const Color primaryColor = Color(0xFF00D4FF);
  static const Color backgroundColor = Color(0xFF1E1E1E);
  static const Color cardBackgroundColor = Color(0xFF2A2A2A);
  static const Color gradientStartColor = Color(0xFF00D4FF);
  static const Color gradientEndColor = Color(0xFFE53E3E);
}

class CustomControls extends StatefulWidget {
  final bool? isShortDramaMode; // 短剧模式参数
  final VoidCallback? onBackPressed; // 返回按钮回调
  final VoidCallback? onNextEpisode; // 下一集回调
  final VoidCallback? onPrevEpisode; // 上一集回调
  final String? episodeTitle; // 剧集标题
  final String? mediaTitle; // 媒体标题
  final int currentEpisodeIndex; // 当前剧集索引
  final int totalEpisodes; // 总剧集数
  final VoidCallback? onEpisodeChanged; // 剧集切换回调

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

  // 暂停图标显示状态
  bool _showPauseIcon = false;

  // 锁定屏幕状态
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    // 初始化时启动计时器
    _startHideTimer();

    // 如果初始状态是暂停的，立即显示图标
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_videoPlayerController.value.isPlaying) {
        setState(() {
          _showPauseIcon = true;
        });
      }
    });
  }

  @override
  void dispose() {
    // 清除计时器
    _hideTimer?.cancel();
    _seekTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _chewieController = ChewieController.of(context);
    _videoPlayerController = _chewieController.videoPlayerController;
    _latestValue = _videoPlayerController.value;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // 快进快退指示器
            _buildSeekingIndicator(),

            // 根据模式构建控制层
            _buildControlsByMode(),
            // 手势检测层（排除控制按钮区域）
            if (_isShortDramaMode)
              // 短剧模式：排除左上角返回按钮区域和底部进度条区域
              Positioned(
                top: MediaQuery.of(context).padding.top +
                    50.0, // 排除顶部50px区域（返回按钮）
                left: 50.0, // 排除左侧50px区域（返回按钮）
                right: 0,
                bottom: 100.0, // 排除底部100px区域（进度条）
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _getTapHandler(),
                  onLongPressStart: _handleLongPressStartWithDelay,
                  onLongPressMoveUpdate: _handleLongPressMoveUpdate,
                  onLongPressEnd: _handleLongPressEnd,
                ),
              )
            else if (_isFullScreenMode)
              // 全屏模式：排除控制按钮区域
              Positioned(
                top: MediaQuery.of(context).padding.top + 50.0, // 排除顶部控制栏
                left: 50.0, // 排除左侧锁定按钮
                right: 50.0, // 排除右侧控制按钮
                bottom: 100.0, // 排除底部控制栏
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _getTapHandler(),
                  onLongPressStart: _handleLongPressStartWithDelay,
                  onLongPressMoveUpdate: _handleLongPressMoveUpdate,
                  onLongPressEnd: _handleLongPressEnd,
                ),
              )
            else
              // 普通模式：排除控制按钮区域
              Positioned(
                top: MediaQuery.of(context).padding.top + 50.0, // 排除顶部返回按钮
                left: 50.0, // 排除左侧区域
                right: 50.0, // 排除右侧区域
                bottom: 100.0, // 排除底部控制栏
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _getTapHandler(),
                  onLongPressStart: _handleLongPressStartWithDelay,
                  onLongPressMoveUpdate: _handleLongPressMoveUpdate,
                  onLongPressEnd: _handleLongPressEnd,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // MARK: - 模式判断方法
  bool get _isShortDramaMode => widget.isShortDramaMode == true;
  bool get _isFullScreenMode => _chewieController.isFullScreen;

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
    if (!_showPauseIcon) return const SizedBox();

    return Center(
      child: Icon(
        Icons.play_arrow,
        size: 80.0,
        color: Colors.white.withOpacity(0.5),
      ),
    )
        .animate()
        .scale(
          duration: const Duration(milliseconds: 300),
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        )
        .fadeIn(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
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
      child: Stack(
        children: [
          // 锁定按钮（左侧居中）
          if (_isLocked) _buildLockButton(),
          // 主要内容
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 顶部控制栏（锁定时不显示）
              if (!_isLocked) _buildFullScreenTopBar(),
              // 中间播放/暂停按钮（锁定时不显示）
              if (!_isSeeking && !_isLocked) _buildFullScreenMiddleBar(),
              // 底部控制栏（锁定时只显示进度条）
              if (_isLocked)
                _buildLockedBottomBar()
              else
                _buildFullScreenBottomBar(),
            ],
          ),
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

  // MARK: - 锁定按钮构建方法
  Widget _buildLockButton() {
    return Positioned(
      left: 16.0,
      top: MediaQuery.of(context).size.height / 2 - 30.0,
      child: IconButton(
        icon: Icon(
          _isLocked ? Icons.lock_open : Icons.lock,
          color: Colors.white,
          size: 30.0,
        ),
        onPressed: () {
          setState(() {
            _isLocked = !_isLocked;
          });
          _resetHideTimer();
        },
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
                  icon: Icon(
                    _isLocked ? Icons.lock_open : Icons.lock,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _isLocked = !_isLocked;
                    });
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
            // 右侧按钮 - 普通模式非全屏时不显示任何按钮
            const SizedBox(),
          ],
        ),
      ),
    );
  }

  // MARK: - 中间控制栏构建方法
  Widget _buildFullScreenMiddleBar() {
    return const SizedBox(); // 全屏模式下不显示中间控制栏
  }

  Widget _buildNormalMiddleBar() {
    return Expanded(
      child: Center(
        child: _buildPlayPauseButton(),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      icon: Icon(
        _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 40.0,
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
            child: VideoProgressIndicator(
              _videoPlayerController,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Color(0xFF00D4FF), // 使用蓝色替代红色
                bufferedColor: Colors.white54,
                backgroundColor: Colors.white24,
              ),
            ),
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
                playedColor: Color(0xFF00D4FF), // 使用蓝色替代红色
                bufferedColor: Colors.white54,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
          // 控制按钮行
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // 左侧：播放/暂停按钮和上一集/下一集按钮
                Row(
                  children: <Widget>[
                    // 上一集按钮（根据是否有上一集显示）
                    if (widget.currentEpisodeIndex > 0)
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        onPressed: () {
                          widget.onPrevEpisode?.call();
                          _resetHideTimer();
                        },
                      ),
                    // 播放/暂停按钮
                    _buildPlayPauseButton(),
                    // 下一集按钮（根据是否有下一集显示）
                    if (widget.currentEpisodeIndex < widget.totalEpisodes - 1)
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        onPressed: () {
                          widget.onNextEpisode?.call();
                          _resetHideTimer();
                        },
                      ),
                  ],
                ),
                // 右侧：播放时间显示和控制按钮
                Row(
                  children: <Widget>[
                    // 播放时间显示
                    Text(
                      '${_formatDuration(_videoPlayerController.value.position)} / ${_formatDuration(_videoPlayerController.value.duration)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0), // 添加圆角
              child: VideoProgressIndicator(
                _videoPlayerController,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF00D4FF), // 使用蓝色替代红色
                  bufferedColor: Colors.white54,
                  backgroundColor: Colors.white24,
                ),
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

  // MARK: - 锁定状态底部控制栏
  Widget _buildLockedBottomBar() {
    return SafeArea(
      child: Column(
        children: [
          // 进度条
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0), // 添加圆角
              child: VideoProgressIndicator(
                _videoPlayerController,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF00D4FF), // 使用蓝色替代红色
                  bufferedColor: Colors.white54,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - 指示器和蒙版构建方法
  Widget _buildSeekingIndicator() {
    if (!_isSeeking) return const SizedBox();

    return Center(
      child: Text(
        _isShortDramaMode ? '2.0x倍速播放中...' : '${_isForward ? "快进" : "快退"}中...',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // MARK: - 播放控制方法
  void _toggleShortDramaPlayPause() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      // 暂停时显示图标
      setState(() {
        _showPauseIcon = true;
      });
    } else {
      _videoPlayerController.play();
      // 播放时隐藏图标
      setState(() {
        _showPauseIcon = false;
      });
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
  void _handleLongPressStartWithDelay(LongPressStartDetails details) {
    // 添加延迟处理以降低响应优先级
    Future.delayed(const Duration(milliseconds: 150), () {
      final double touchPosition = details.localPosition.dx;
      final double screenWidth = MediaQuery.of(context).size.width;

      if (_isShortDramaMode) {
        // 短剧模式：只有右侧长按才快进（手势区域已排除返回按钮和进度条）
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
    });
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final double touchPosition = details.localPosition.dx;
    final double screenWidth = MediaQuery.of(context).size.width;

    if (_isShortDramaMode) {
      // 短剧模式：只有右侧长按才快进（手势区域已排除返回按钮和进度条）
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
        backgroundColor: Colors.black87,
        title: const Text(
          '播放速度',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: speeds.map((speed) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _videoPlayerController.setPlaybackSpeed(speed);
              _resetHideTimer();
            },
            child: Text(
              '${speed}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showEpisodeSelector() {
    // 移除剧集选择对话框，改为调用回调函数
    // 实际的剧集选择UI将在 video_player_page.dart 中实现
    widget.onEpisodeChanged?.call();
  }
}

// MARK: - UI组件类
class VideoControlWidgets {
  // 渐变背景装饰
  static BoxDecoration gradientDecoration = const BoxDecoration(
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
  );

  // 进度条颜色配置
  static const VideoProgressColors progressColors = VideoProgressColors(
    playedColor: Color(0xFF00D4FF),
    bufferedColor: Colors.white54,
    backgroundColor: Colors.white24,
  );

  // 构建返回按钮
  static Widget buildBackButton({
    required bool isFullScreen,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        isFullScreen ? Icons.keyboard_arrow_down : Icons.arrow_back,
        color: Colors.white,
        size: VideoControlConfig.backButtonSize,
      ),
      onPressed: onPressed,
    );
  }

  // 构建播放/暂停按钮
  static Widget buildPlayPauseButton({
    required bool isPlaying,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: VideoControlConfig.playButtonSize,
      ),
      onPressed: onPressed,
    );
  }

  // 构建控制按钮
  static Widget buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double? size,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.white,
        size: size ?? VideoControlConfig.controlButtonSize,
      ),
      onPressed: onPressed,
    );
  }

  // 构建时间显示文本
  static Widget buildTimeText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14.0,
      ),
    );
  }

  // 构建进度条
  static Widget buildProgressIndicator(VideoPlayerController controller) {
    return VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      colors: progressColors,
    );
  }
}
