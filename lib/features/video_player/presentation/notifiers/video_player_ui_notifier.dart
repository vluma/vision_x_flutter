import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/video_player/domain/models/video_player_models.dart';

/// 视频播放器UI状态管理
class VideoPlayerUINotifier extends StateNotifier<VideoPlayerUIState> {
  Timer? _controlsVisibilityTimer;
  
  VideoPlayerUINotifier() : super(const VideoPlayerUIState());
  
  /// 显示控制界面
  void showControls() {
    if (state.isLocked) return;
    
    state = state.copyWith(controlsVisible: true);
    _resetControlsVisibilityTimer();
  }
  
  /// 隐藏控制界面
  void hideControls() {
    if (state.isLocked) return;
    
    state = state.copyWith(controlsVisible: false);
    _cancelControlsVisibilityTimer();
  }
  
  /// 切换控制界面显示状态
  void toggleControls() {
    if (state.isLocked) return;
    
    state = state.copyWith(controlsVisible: !state.controlsVisible);
    
    if (state.controlsVisible) {
      _resetControlsVisibilityTimer();
    } else {
      _cancelControlsVisibilityTimer();
    }
  }
  
  /// 切换锁定状态
  void toggleLock() {
    final newLockedState = !state.isLocked;
    
    state = state.copyWith(
      isLocked: newLockedState,
      controlsVisible: newLockedState ? false : state.controlsVisible,
    );
    
    if (newLockedState) {
      _cancelControlsVisibilityTimer();
    } else if (state.controlsVisible) {
      _resetControlsVisibilityTimer();
    }
  }
  
  /// 显示大播放按钮
  void showBigPlayButton() {
    state = state.copyWith(showBigPlayButton: true);
  }
  
  /// 隐藏大播放按钮
  void hideBigPlayButton() {
    state = state.copyWith(showBigPlayButton: false);
  }
  
  /// 显示跳转指示器
  void showSeekIndicator() {
    state = state.copyWith(showSeekIndicator: true);
  }
  
  /// 隐藏跳转指示器
  void hideSeekIndicator() {
    state = state.copyWith(showSeekIndicator: false);
  }
  
  /// 显示速度指示器
  void showSpeedIndicator(double speed) {
    state = state.copyWith(
      showSpeedIndicator: true,
      currentSpeed: speed,
    );
    
    // 3秒后自动隐藏
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        hideSpeedIndicator();
      }
    });
  }
  
  /// 隐藏速度指示器
  void hideSpeedIndicator() {
    state = state.copyWith(showSpeedIndicator: false);
  }
  
  /// 重置控制界面可见性定时器
  void _resetControlsVisibilityTimer() {
    _cancelControlsVisibilityTimer();
    
    _controlsVisibilityTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !state.isLocked) {
        state = state.copyWith(controlsVisible: false);
      }
    });
  }
  
  /// 取消控制界面可见性定时器
  void _cancelControlsVisibilityTimer() {
    _controlsVisibilityTimer?.cancel();
    _controlsVisibilityTimer = null;
  }
  
  @override
  void dispose() {
    _cancelControlsVisibilityTimer();
    super.dispose();
  }
}