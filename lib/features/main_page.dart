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
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: BottomNavigationBarWidget(currentPath: currentPath),
    );
  }
}
