/// 导航按钮组件
/// 单个导航标签按钮的UI组件

import 'package:flutter/material.dart';
import 'package:vision_x_flutter/features/navigation/models/nav_bar_constants.dart';
import 'package:vision_x_flutter/features/navigation/states/navigation_state.dart';

/// 导航按钮组件
class NavButton extends StatelessWidget {
  final NavBarTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const NavButton({
    super.key,
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = NavBarConstants.tabIcons[tab];
    final label = NavBarConstants.tabLabels[tab];

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NavBarConstants.containerBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NavBarConstants.containerBorderRadius),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isActive
                  ? theme.primaryColor
                  : theme.brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black54,
              size: NavBarConstants.iconSize,
              semanticLabel: label,
            ),
          ),
        ),
      ),
    );
  }
}