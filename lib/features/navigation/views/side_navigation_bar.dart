/// PC端侧边栏导航组件
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/features/navigation/models/nav_bar_constants.dart';
import 'package:vision_x_flutter/features/navigation/providers/navigation_provider.dart';
import 'package:vision_x_flutter/features/navigation/states/navigation_state.dart';
import 'package:vision_x_flutter/features/navigation/viewmodels/navigation_view_model.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:flutter/foundation.dart';

/// PC端侧边栏导航组件
class SideNavigationBarWidget extends StatefulWidget {
  final String currentPath;

  const SideNavigationBarWidget({
    super.key,
    required this.currentPath,
  });

  @override
  State<SideNavigationBarWidget> createState() =>
      _SideNavigationBarWidgetState();
}

class _SideNavigationBarWidgetState extends State<SideNavigationBarWidget> {
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
  void didUpdateWidget(covariant SideNavigationBarWidget oldWidget) {
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

  /// 处理搜索输入
  void _handleSearchInput(String value) {
    searchDataSource.setSearchQuery(value);
  }

  /// 处理搜索提交
  void _handleSearchSubmit(String value) {
    if (value.trim().isNotEmpty) {
      searchDataSource.setSearchQuery(value);
      GoRouter.of(context).go('/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, provider, child) {
        final state = provider.state;
        
        return Container(
          width: 250,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo区域
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_circle_fill,
                      size: 32,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Vision X',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              
              // 搜索框
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _handleSearchInput,
                  onSubmitted: _handleSearchSubmit,
                  decoration: InputDecoration(
                    hintText: '搜索...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              
              // 导航菜单
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.home,
                      label: '首页',
                      isSelected: state.currentTab == NavBarTab.home,
                      onTap: () => _viewModel.navigateToTab(NavBarTab.home),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.history,
                      label: '历史记录',
                      isSelected: state.currentTab == NavBarTab.history,
                      onTap: () => _viewModel.navigateToTab(NavBarTab.history),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.settings,
                      label: '设置',
                      isSelected: state.currentTab == NavBarTab.settings,
                      onTap: () => _viewModel.navigateToTab(NavBarTab.settings),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建导航项
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected 
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}