import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vision_x_flutter/components/video_player.dart';
import 'package:vision_x_flutter/models/media_detail.dart';

class VideoPlayerPage extends StatefulWidget {
  final MediaDetail media;
  late Episode episode;

  VideoPlayerPage({
    super.key,
    required this.media,
    required Episode episode,
  }) : episode = episode;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    Tab(text: '简介'),
    Tab(text: '评论'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: null, // 移除AppBar
      body: Column(
        children: [
          // 视频播放器部分
          SafeArea(
            child: AspectRatio(
              aspectRatio: 16 / 9, // 设置标准16:9宽高比
              child: Stack(
                children: [
                  CustomVideoPlayer(
                    media: widget.media,
                    episode: widget.episode,
                  ),
                  // 顶部返回按钮 (始终显示)
                  Positioned(
                    top: 10,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 导航标签部分
          Expanded(
            child: DefaultTabController(
              length: _tabs.length,
              child: Column(
                children: [
                  Container(
                    color: Colors.black,
                    child: TabBar(
                      tabs: _tabs,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      onTap: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: TabBarView(
                        children: [
                          // 简介内容
                          _buildDescriptionTab(),
                          // 评论内容
                          _buildCommentsTab(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.media.name ?? '未知影片',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.media.year != null || widget.media.area != null)
            Text(
              '${widget.media.year ?? ''} ${widget.media.area ?? ''}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 10),
          if (widget.media.actors != null)
            Text(
              '主演: ${widget.media.actors}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 10),
          if (widget.media.director != null)
            Text(
              '导演: ${widget.media.director}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 10),
          if (widget.media.description != null)
            Text(
              widget.media.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return const Center(
      child: Text(
        '评论功能正在开发中...',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
