import 'package:flutter/material.dart';
import 'package:vision_x_flutter/components/bottom_navigation_bar.dart';

class MainPage extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const MainPage({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    // 确定当前选中的导航索引
    int currentIndex = 0;
    if (currentPath.startsWith('/history')) {
      currentIndex = 2;
    } else if (currentPath.startsWith('/settings')) {
      currentIndex = 3;
    } else if (currentPath.startsWith('/search')) {
      currentIndex = 1;
    } else {
      currentIndex = 0; // 默认为首页
    }

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: BottomNavigationBarWidget(currentPath: currentPath),
    );
  }
}
