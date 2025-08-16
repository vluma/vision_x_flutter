import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vision_x_flutter/models/media_detail.dart';

class VideoPlayerPage extends StatefulWidget {
  final MediaDetail media;
  final Episode episode;

  const VideoPlayerPage({
    super.key,
    required this.media,
    required this.episode,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    try {
      // 创建视频播放控制器，根据URL类型选择合适的格式
      if (widget.episode.url.toLowerCase().contains('.m3u8')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.episode.url),
          formatHint: VideoFormat.hls,
        );
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.episode.url));
      }

      // 添加监听器以捕获可能的错误
      _controller.addListener(() {
        if (_controller.value.hasError) {
          setState(() {
            _errorMessage = '播放过程中发生错误: ${_controller.value.errorDescription}';
          });
        }
      });

      // 初始化视频播放器
      await _controller.initialize();
      
      setState(() {
        _isInitialized = true;
      });

      // 自动播放视频
      await _controller.play();
    } catch (error) {
      print('视频播放器初始化错误: $error');
      
      setState(() {
        _errorMessage = '播放器初始化失败，请检查网络连接或稍后重试\n错误详情: $error';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.media.name ?? '视频播放'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = '';
                        });
                        _initializeVideoPlayer();
                      },
                      child: const Text('重试'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '尝试播放: ${widget.episode.url}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : !_isInitialized
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('正在初始化视频播放器...'),
                    ],
                  ),
                )
              : AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
      floatingActionButton: _isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}