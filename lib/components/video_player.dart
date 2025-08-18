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
  final int startPosition; // 添加起始位置参数
  final Function(Episode episode)? onEpisodeChanged; // 添加剧集切换回调

  const CustomVideoPlayer({
    super.key,
    required this.media,
    required this.episode,
    this.onProgressUpdate,
    this.startPosition = 0, // 默认从头开始
    this.onEpisodeChanged,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isPlayerInitialized = false;
  Timer? _progressTimer;
  int _currentEpisodeIndex = 0;
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    _currentEpisodeIndex = _getCurrentEpisodeIndex();
    _initializePlayer();
  }

  int _getCurrentEpisodeIndex() {
    try {
      final currentSource = widget.media.surces.firstWhere(
        (source) => source.name == widget.media.sourceName,
        orElse: () => widget.media.surces.first,
      );
      return currentSource.episodes.indexWhere(
        (episode) => episode.url == widget.episode.url,
      );
    } catch (e) {
      return 0;
    }
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
  
  void _startProgressTracking() {
    // 每30秒更新一次进度
    _progressTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_videoPlayerController.value.isInitialized && !_isDisposing) {
        final position = _videoPlayerController.value.position.inSeconds;
        widget.onProgressUpdate?.call(position);
      }
    });
  }

  // 切换剧集
  void _changeEpisode(int index) {
    try {
      final currentSource = widget.media.surces.firstWhere(
        (source) => source.name == widget.media.sourceName,
        orElse: () => widget.media.surces.first,
      );
      
      if (index >= 0 && index < currentSource.episodes.length) {
        setState(() {
          _currentEpisodeIndex = index;
        });
        
        final newEpisode = currentSource.episodes[index];
        widget.onEpisodeChanged?.call(newEpisode);
        
        // 先标记为未初始化
        setState(() {
          _isPlayerInitialized = false;
        });
        
        // 异步初始化新播放器
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _reinitializePlayer(newEpisode);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法切换到该集数')),
        );
      }
    }
  }
  
  // 重新初始化播放器
  Future<void> _reinitializePlayer(Episode newEpisode) async {
    // 安全地销毁旧控制器
    await _disposeControllers();
    
    // 更新widget的episode值（通过回调）
    widget.onEpisodeChanged?.call(newEpisode);
    
    // 初始化新控制器
    if (mounted) {
      await _initializePlayer();
    }
  }
  
  // 安全地销毁控制器
  Future<void> _disposeControllers() async {
    _isDisposing = true;
    _progressTimer?.cancel();
    
    try {
      // 先尝试同步销毁
      _chewieController.dispose();
    } catch (e) {
      // 忽略销毁错误
    }
    
    try {
      // 再尝试同步销毁
      await _videoPlayerController.dispose();
    } catch (e) {
      // 忽略销毁错误
    }
    
    _isDisposing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 视频播放器
        Expanded(
          child: _isPlayerInitialized
              ? Chewie(controller: _chewieController)
              : const Center(child: CircularProgressIndicator()),
        ),
        // 剧集选择器
        if (widget.media.surces.isNotEmpty) _buildEpisodeSelector(),
      ],
    );
  }

  // 构建剧集选择器
  Widget _buildEpisodeSelector() {
    try {
      final currentSource = widget.media.surces.firstWhere(
        (source) => source.name == widget.media.sourceName,
        orElse: () => widget.media.surces.first,
      );

      return Container(
        height: 50,
        color: Colors.black87,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: currentSource.episodes.length,
          itemBuilder: (context, index) {
            final episode = currentSource.episodes[index];
            final isSelected = index == _currentEpisodeIndex;
            
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blue : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _changeEpisode(index),
                child: Text(
                  episode.title,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    _progressTimer?.cancel();
    
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