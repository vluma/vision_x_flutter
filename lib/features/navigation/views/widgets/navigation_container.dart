/// 导航容器组件
/// 包含导航按钮和选中指示器的容器
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/core/themes/colors.dart';
import 'package:vision_x_flutter/features/navigation/models/nav_bar_constants.dart';
import 'package:vision_x_flutter/features/navigation/states/navigation_state.dart';
import 'package:vision_x_flutter/features/navigation/viewmodels/navigation_view_model.dart';
import 'nav_button.dart';
import 'menu_button.dart';

/// 导航容器组件
class NavigationContainer extends StatelessWidget {
  final double maxWidth;
  final bool isSearchExpanded;
  final NavigationViewModel viewModel;
  final NavBarTab currentTab;

  const NavigationContainer({
    super.key,
    required this.maxWidth,
    required this.isSearchExpanded,
    required this.viewModel,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectBgWidth = maxWidth / 3 -
        NavBarConstants.borderWidth -
        NavBarConstants.borderWidth;

    return AnimatedContainer(
      duration: NavBarConstants.animationDuration,
      curve: NavBarConstants.animationCurve,
      width: isSearchExpanded ? NavBarConstants.containerHeight : maxWidth,
      height: NavBarConstants.containerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(NavBarConstants.containerBorderRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          width: NavBarConstants.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 2.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(NavBarConstants.paddingAll),
        child: Stack(
          children: [
            // 滑动的选中背景
            TweenAnimationBuilder<double>(
              duration: NavBarConstants.animationDuration,
              curve: NavBarConstants.animationCurve,
              tween: Tween<double>(
                begin: isSearchExpanded ? 1.0 : 0.0,
                end: isSearchExpanded ? 0.0 : (currentTab.index - 1) * 1.0,
              ),
              builder: (context, value, child) {
                final alignment = isSearchExpanded
                    ? Alignment.centerRight
                    : Alignment(value, 0);

                // 计算当前距离目标的距离
                final targetValue = (currentTab.index - 1) * 1.0;
                final distance = (targetValue - value).abs();

                // 距离越小，形变越小
                final intensity = distance.clamp(0.0, 0.3) * 3.0;
                final springScale = 1.0 + (0.08 * intensity);
                final squeeze = 1.0 - (0.05 * intensity);

                // 确保动画完成时完全恢复正常
                final finalScaleX =
                    distance < 0.001 ? 1.0 : springScale.clamp(0.9, 1.1);
                final finalScaleY =
                    distance < 0.001 ? 1.0 : squeeze.clamp(0.92, 1.08);

                // 限制最大形变防止超出范围
                final clampedWidth =
                    (isSearchExpanded ? 0.0 : selectBgWidth * 0.9).toDouble();
                final clampedHeight =
                    (NavBarConstants.selectedContainerHeight * 0.95).toDouble();

                return Align(
                  alignment: alignment,
                  child: Transform.scale(
                    scaleX: isSearchExpanded ? 0.0 : finalScaleX,
                    scaleY: isSearchExpanded ? 0.0 : finalScaleY,
                    child: Container(
                      width: clampedWidth,
                      height: clampedHeight,
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            NavBarConstants.selectedContainerBorderRadius *
                                0.95),
                        color: theme.brightness == Brightness.dark
                            ? AppColors.bottomNavSelectedItem.withValues(
                                alpha: NavBarConstants.selectedItemAlphaDark)
                            : theme.primaryColor
                                .withValues(alpha: NavBarConstants.commonAlpha),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 10.0,
                            offset: const Offset(0, 2),
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // 内容切换
            AnimatedSwitcher(
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
                  ? MenuButton(
                      onTap: () {
                        final currentPath =
                            GoRouterState.of(context).uri.toString();
                        viewModel.toggleSearch(currentPath);
                      },
                    )
                  : _buildNavigationButtons(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建导航按钮组
  Widget _buildNavigationButtons(NavigationViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        NavButton(
          tab: NavBarTab.home,
          isActive: currentTab == NavBarTab.home,
          onTap: () => viewModel.navigateToTab(NavBarTab.home),
        ),
        NavButton(
          tab: NavBarTab.history,
          isActive: currentTab == NavBarTab.history,
          onTap: () => viewModel.navigateToTab(NavBarTab.history),
        ),
        NavButton(
          tab: NavBarTab.settings,
          isActive: currentTab == NavBarTab.settings,
          onTap: () => viewModel.navigateToTab(NavBarTab.settings),
        ),
      ],
    );
  }
}
