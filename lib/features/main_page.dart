import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/features/navigation/index.dart';
import 'package:vision_x_flutter/features/navigation/views/side_navigation_bar.dart';

class MainPage extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const MainPage({
    super.key,
    required this.child,
    required this.currentPath,
  });

  bool get _isDesktop {
    // 修改为Web平台也视为桌面平台，以使用桌面布局
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NavigationProvider(),
      child: _isDesktop 
        ? _buildDesktopLayout(context) 
        : _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar:
          BottomNavigationBarWidget(currentPath: currentPath),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigationBarWidget(currentPath: currentPath),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}