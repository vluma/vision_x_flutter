/// 搜索容器组件
/// 包含搜索功能的容器
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/features/navigation/models/nav_bar_constants.dart';
import 'package:vision_x_flutter/features/navigation/viewmodels/navigation_view_model.dart';
import 'search_button.dart';
import 'search_field.dart';

/// 搜索容器组件
class SearchContainer extends StatelessWidget {
  final double maxWidth;
  final bool isSearchExpanded;
  final NavigationViewModel viewModel;
  final TextEditingController searchController;

  const SearchContainer({
    super.key,
    required this.maxWidth,
    required this.isSearchExpanded,
    required this.viewModel,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: NavBarConstants.animationDuration,
      curve: NavBarConstants.animationCurve,
      width: isSearchExpanded ? maxWidth : NavBarConstants.containerHeight,
      height: NavBarConstants.containerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(NavBarConstants.containerBorderRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: NavBarConstants.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 2.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(NavBarConstants.paddingAll),
        child: AnimatedSwitcher(
          duration: NavBarConstants.animationDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: isSearchExpanded
              ? GestureDetector(
                  onTap: () {
                    final currentPath = GoRouterState.of(context).uri.toString();
                    viewModel.toggleSearch(currentPath);
                  },
                  child: SearchField(controller: searchController),
                )
              : SearchButton(
                  onTap: () {
                    final currentPath = GoRouterState.of(context).uri.toString();
                    viewModel.toggleSearch(currentPath);
                  },
                  isExpanded: isSearchExpanded,
                ),
        ),
      ),
    );
  }
}