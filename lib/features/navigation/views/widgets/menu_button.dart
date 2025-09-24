/// 菜单按钮组件
/// 菜单功能的UI组件
library;

import 'package:flutter/material.dart';
import 'package:vision_x_flutter/features/navigation/models/nav_bar_constants.dart';

/// 菜单按钮组件
class MenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NavBarConstants.containerBorderRadius),
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Center(
          child: Icon(
            Icons.menu,
            color: theme.primaryColor,
            size: NavBarConstants.iconSize,
          ),
        ),
      ),
    );
  }
}