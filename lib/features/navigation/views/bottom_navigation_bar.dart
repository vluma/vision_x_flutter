/// 底部导航栏组件
/// 主导航栏组件，整合所有导航功能
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/features/navigation/models/nav_bar_constants.dart';
import 'package:vision_x_flutter/features/navigation/providers/navigation_provider.dart';
import 'package:vision_x_flutter/features/navigation/viewmodels/navigation_view_model.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:vision_x_flutter/core/themes/colors.dart';
import 'widgets/navigation_container.dart';
import 'widgets/search_container.dart';

/// 底部导航栏组件
class BottomNavigationBarWidget extends StatefulWidget {
  final String currentPath;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentPath,
  });

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  late final TextEditingController _searchController;
  late final NavigationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _setupViewModel();
    _setupSearchListeners();
  }

  @override
  void didUpdateWidget(covariant BottomNavigationBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.handlePathChange(widget.currentPath);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    searchDataSource.removeListener(_onSearchDataSourceChanged);
    super.dispose();
  }

  /// 设置视图模型
  void _setupViewModel() {
    final provider = Provider.of<NavigationProvider>(context, listen: false);
    final router = GoRouter.of(context);
    _viewModel = NavigationViewModel(provider, router);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.handlePathChange(widget.currentPath);
    });
  }

  /// 设置搜索监听器
  void _setupSearchListeners() {
    searchDataSource.addListener(_onSearchDataSourceChanged);
    _searchController.text = searchDataSource.searchQuery;
  }

  /// 搜索数据源变化回调
  void _onSearchDataSourceChanged() {
    if (_searchController.text != searchDataSource.searchQuery) {
      _searchController.text = searchDataSource.searchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxColumnWidth = screenWidth > NavBarConstants.maxColumnWidthOffset
        ? screenWidth - NavBarConstants.maxColumnWidthOffset
        : NavBarConstants.minColumnWidth;

    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomPadding =
        viewInsets.bottom + NavBarConstants.bottomPaddingOffset;

    return Consumer<NavigationProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        return Stack(
          children: [
            // 渐变背景 - 从底部到屏幕一半高度
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkBackground.withValues(alpha: 1)
                          : AppColors.lightBackground.withValues(alpha: 1),
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkBackground.withValues(alpha: 0.5)
                          : AppColors.lightBackground.withValues(alpha: 0.5),
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkBackground.withValues(alpha: 0.0)
                          : AppColors.lightBackground.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // 底部导航栏内容
            Container(
              padding: EdgeInsets.only(
                bottom: bottomPadding,
                left: NavBarConstants.horizontalPadding,
                right: NavBarConstants.horizontalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NavigationContainer(
                    maxWidth: maxColumnWidth,
                    isSearchExpanded: state.isSearchExpanded,
                    viewModel: _viewModel,
                    currentTab: state.currentTab,
                  ),
                  SearchContainer(
                    maxWidth: maxColumnWidth,
                    isSearchExpanded: state.isSearchExpanded,
                    viewModel: _viewModel,
                    searchController: _searchController,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
