import 'package:flutter/material.dart';
import 'package:vision_x_flutter/components/loading_animation.dart';

/// 加载状态组件
/// 显示加载动画和提示信息
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimation(sizeRatio: 0.2),
          SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}