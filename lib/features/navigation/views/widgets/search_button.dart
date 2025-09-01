/// 搜索按钮组件
/// 搜索功能的UI组件

import 'package:flutter/material.dart';
import 'package:vision_x_flutter/features/navigation/models/nav_bar_constants.dart';

/// 搜索按钮组件
class SearchButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isExpanded;

  const SearchButton({
    super.key,
    required this.onTap,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NavBarConstants.containerBorderRadius),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Icon(
            isExpanded ? Icons.close : Icons.search,
            color: Colors.grey,
            size: NavBarConstants.iconSize,
            semanticLabel: isExpanded ? '关闭搜索' : '搜索',
          ),
        ),
      ),
    );
  }
}