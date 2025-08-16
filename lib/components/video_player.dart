import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:vision_x_flutter/models/media_detail.dart';

class CustomVideoPlayer extends StatefulWidget {
  final MediaDetail media;
  final Episode episode;
  final Function(Episode episode)? onEpisodeChanged;

  const CustomVideoPlayer({
    super.key,
    required this.media,
    required this.episode,
    this.onEpisodeChanged,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  int _currentEpisodeIndex = 0;

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
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.episode.url),
    );

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      showControls: true,
      allowFullScreen: true,
      allowMuting: true,
      autoInitialize: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            'An error occurred: $errorMessage',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    
    setState(() {});
  }

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
        
        // Dispose the old controllers
        _chewieController.dispose();
        _videoPlayerController.dispose();
        
        // Initialize with new episode
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializePlayer();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法切换到该集数')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _chewieController.videoPlayerController == null 
            ? const Center(child: CircularProgressIndicator())
            : Chewie(controller: _chewieController),
        ),
        _buildEpisodeControls(),
      ],
    );
  }

  Widget _buildEpisodeControls() {
    final currentSource = widget.media.surces.firstWhere(
      (source) => source.name == widget.media.sourceName,
      orElse: () => widget.media.surces.first,
    );
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentEpisodeIndex > 0
              ? IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () => _changeEpisode(_currentEpisodeIndex - 1),
                )
              : const SizedBox(width: 48),
          Text(
            currentSource.episodes[_currentEpisodeIndex].title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _currentEpisodeIndex < currentSource.episodes.length - 1
              ? IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => _changeEpisode(_currentEpisodeIndex + 1),
                )
              : const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}