import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/features/navigation/index.dart';

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
    return ChangeNotifierProvider(
      create: (context) => NavigationProvider(),
      child: Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar:
            BottomNavigationBarWidget(currentPath: currentPath),
      ),
    );
  }
}
