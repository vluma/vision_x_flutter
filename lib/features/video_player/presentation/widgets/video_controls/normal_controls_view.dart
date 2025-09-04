import 'package:flutter/material.dart' hide BackButton;
import 'package:video_player/video_player.dart' as vp;
import 'package:vision_x_flutter/features/video_player/domain/models/video_player_models.dart';
import 'package:vision_x_flutter/features/video_player/presentation/widgets/video_controls/video_control_widgets.dart';

/// 普通控制界面
/// 针对长视频和电视剧场景优化的控制界面
class NormalControlsView extends StatelessWidget {
  final vp.VideoPlayerController controller;
  final VideoPlayState playerState;
  final VideoPlayerUIState uiState;
  final VideoPlayerConfig config;
  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final ValueChanged<double>? onSeek;
  final VoidCallback? onToggleFullScreen;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onPrevEpisode;
  final ValueChanged<double>? onSpeedChanged;

  const NormalControlsView({
    super.key,
    required this.controller,
    required this.playerState,
    required this.uiState,
    required this.config,
    this.onPlayPause,
    this.onBack,
    this.onSeek,
    this.onToggleFullScreen,
    this.onNextEpisode,
    this.onPrevEpisode,
    this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 顶部控制栏
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopControls(),
        ),
        
        // 中央播放/暂停按钮
        Center(
          child: GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
        
        // 底部控制栏
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomControls(),
        ),
      ],
    );
  }
  
  /// 构建顶部控制栏
  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          BackButton(
            onPressed: onBack,
            color: Colors.white,
            size: 24,
          ),
          
          const SizedBox(width: 16),
          
          // 标题
          if (config.title != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    config.title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (config.episodeTitle != null)
                    Text(
                      config.episodeTitle!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          
          const Spacer(),
          
          // 全屏按钮
          IconButton(
            icon: Icon(
              config.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
              size: 24,
            ),
            onPressed: onToggleFullScreen,
          ),
        ],
      ),
    );
  }
  
  /// 构建底部控制栏
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条
          VideoProgressBar(
            controller: controller,
            height: 3,
            expandedHeight: 6,
            onSeek: onSeek,
          ),
          
          const SizedBox(height: 8),
          
          // 时间显示和播放控制
          Row(
            children: [
              // 播放/暂停按钮
              PlayPauseButton(
                isPlaying: playerState.isPlaying,
                onPressed: onPlayPause,
              ),
              
              // 上一集按钮
              if (onPrevEpisode != null)
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: onPrevEpisode,
                ),
              
              // 下一集按钮
              if (onNextEpisode != null)
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: onNextEpisode,
                ),
              
              const SizedBox(width: 8),
              
              // 时间显示
              TimeDisplay(
                currentTime: playerState.formattedCurrentTime,
                totalTime: playerState.formattedTotalTime,
              ),
              
              const Spacer(),
              
              // 播放速度按钮
              if (onSpeedChanged != null)
                _buildSpeedButton(),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 构建播放速度按钮
  Widget _buildSpeedButton() {
    return PopupMenuButton<double>(
      icon: const Icon(
        Icons.speed,
        color: Colors.white,
        size: 24,
      ),
      onSelected: onSpeedChanged,
      itemBuilder: (context) => VideoPlayerConfig.playbackSpeeds
          .map(
            (speed) => PopupMenuItem<double>(
              value: speed,
              child: Text(
                '${speed}x',
                style: TextStyle(
                  fontWeight: playerState.playbackSpeed == speed
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}