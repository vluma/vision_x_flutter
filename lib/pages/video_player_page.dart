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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: null, // 移除AppBar
      body: Stack(
        children: [
          CustomVideoPlayer(
            media: widget.media,
            episode: widget.episode,
            onEpisodeChanged: (newEpisode) {
              setState(() {
                widget.episode = newEpisode;
              });
            },
          ),
          // 顶部返回按钮 (始终显示)
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
