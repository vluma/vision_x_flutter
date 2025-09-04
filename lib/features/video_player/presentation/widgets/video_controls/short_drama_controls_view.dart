import 'package:flutter/material.dart' hide BackButton;
import 'package:video_player/video_player.dart' as vp;
import 'package:vision_x_flutter/features/video_player/domain/models/video_player_models.dart';
import 'package:vision_x_flutter/features/video_player/presentation/widgets/video_controls/video_control_widgets.dart';

/// 短剧控制界面
/// 针对短视频和短剧场景优化的控制界面
class ShortDramaControlsView extends StatelessWidget {
  final vp.VideoPlayerController controller;
  final VideoPlayState playerState;
  final VideoPlayerUIState uiState;
  final VoidCallback? onPlayPause;
  final VoidCallback? onBack;
  final ValueChanged<double>? onSeek;

  const ShortDramaControlsView({
    super.key,
    required this.controller,
    required this.playerState,
    required this.uiState,
    this.onPlayPause,
    this.onBack,
    this.onSeek,
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
          
          const Spacer(),
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
              // 时间显示
              TimeDisplay(
                currentTime: playerState.formattedCurrentTime,
                totalTime: playerState.formattedTotalTime,
              ),
              
              const Spacer(),
              
              // 播放/暂停按钮
              PlayPauseButton(
                isPlaying: playerState.isPlaying,
                onPressed: onPlayPause,
              ),
            ],
          ),
        ],
      ),
    );
  }
}