import 'package:flutter/material.dart';
import 'package:vision_x_flutter/components/swipe_back_gesture.dart';

/// 测试左滑返回功能的页面
class TestSwipePage extends StatelessWidget {
  const TestSwipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SwipeBackGesture(
      onBackPressed: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('左滑返回测试'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Container(
          color: Colors.blue.shade100,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe_left,
                  size: 100,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  '从屏幕左边缘向右滑动',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '或者点击左上角的返回按钮',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
