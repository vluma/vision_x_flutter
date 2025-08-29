 // bottom_navigation_bar.dart
// 功能: 底部导航栏组件 - 优化版本
// 优化重点: 性能提升、代码结构、可维护性

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:vision_x_flutter/theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 导航栏常量配置
class NavBarConstants {
  // 尺寸常量
  static const double containerHeight = 56.0;
  static const double containerBorderRadius = 28.0;
  static const double selectedContainerHeight = 48.0;
  static const double selectedContainerBorderRadius = 24.0;
  static const double iconSize = 24.0;
  static const double paddingAll = 4.0;
  static const double borderWidth = 0.5;
  static const double horizontalPadding = 16.0;
  static const double bottomPaddingOffset = 16.0;
  static const double maxColumnWidthOffset = 100.0;
  static const double minColumnWidth = 100.0;

  // 动画配置
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Curve animationCurve = Curves.easeInOut;

  // 颜色透明度
  static const double commonAlpha = 0.1;
  static const double selectedItemAlphaDark = 0.2;

  // 路由路径
  static const List<String> navPaths = ['/', '/history', '/settings'];
}

class BottomNavigationBarWidget extends StatefulWidget {
  final String currentPath;

  const BottomNavigationBarWidget({super.key, required this.currentPath});

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  String? _lastActivePath;
  int _selectedIndex = 0;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeSelectedIndex();
    _setupSearchListeners();
  }

  @override
  void didUpdateWidget(covariant BottomNavigationBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      _initializeSelectedIndex();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    searchDataSource.removeListener(_onSearchDataSourceChanged);
    super.dispose();
  }

  void _setupSearchListeners() {
    searchDataSource.addListener(_onSearchDataSourceChanged);
    _searchController.text = searchDataSource.searchQuery;
    _isSearchExpanded = searchDataSource.isSearchExpanded;
  }

  void _initializeSelectedIndex() {
    if (widget.currentPath.startsWith('/history')) {
      _selectedIndex = 1;
      _lastActivePath = '/history';
    } else if (widget.currentPath.startsWith('/settings')) {
      _selectedIndex = 2;
      _lastActivePath = '/settings';
    } else {
      _selectedIndex = 0;
      _lastActivePath = '/';
    }
  }

  void _onSearchDataSourceChanged() {
    if (_searchController.text != searchDataSource.searchQuery) {
      _searchController.text = searchDataSource.searchQuery;
    }
    if (_isSearchExpanded != searchDataSource.isSearchExpanded) {
      setState(() {
        _isSearchExpanded = searchDataSource.isSearchExpanded;
      });
    }
  }

  void _toggleSearch() {
    final newSearchState = !_isSearchExpanded;
    
    setState(() {
      _lastActivePath = widget.currentPath;
      _isSearchExpanded = newSearchState;
    });

    searchDataSource.setSearchExpanded(newSearchState);
    GoRouter.of(context).go('/search');

    if (!newSearchState) {
      searchDataSource.clearSearch();
      _searchController.clear();
    }
  }

  void _toggleMenu() {
    if (_lastActivePath != null) {
      GoRouter.of(context).go(_lastActivePath!);
    }
    
    setState(() {
      _isSearchExpanded = false;
    });
    
    searchDataSource.setSearchExpanded(false);
    _searchController.clear();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _lastActivePath = NavBarConstants.navPaths[index];
    });

    GoRouter.of(context).go(_lastActivePath!);
  }

  Widget _buildNavButton(int index, IconData icon) {
    final theme = Theme.of(context);
    final isActive = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavItemTapped(index),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavButton(0, Icons.home),
        _buildNavButton(1, Icons.history),
        _buildNavButton(2, Icons.settings),
      ],
    );
  }

  Widget _buildMenuButton() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: _toggleMenu,
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

  Widget _buildSearchButton() {
    return InkWell(
      onTap: _toggleSearch,
      borderRadius: BorderRadius.circular(NavBarConstants.containerBorderRadius),
      child: const SizedBox(
        width: double.infinity,
        child: Center(
          child: Icon(
            Icons.search,
            color: Colors.grey,
            size: NavBarConstants.iconSize,
            semanticLabel: '搜索',
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);

    return TextField(
      controller: _searchController,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        isDense: true,
      ),
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          searchDataSource.setSearchQuery(value);
          context.go('/search');
        }
      },
    );
  }

  Widget _buildNavigationContainer(double maxWidth) {
    final theme = Theme.of(context);
    final selectBgWidth = maxWidth / 3;

    return AnimatedContainer(
      duration: NavBarConstants.animationDuration,
      curve: NavBarConstants.animationCurve,
      width: _isSearchExpanded ? NavBarConstants.containerHeight : maxWidth,
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
        child: Stack(
          children: [
            // 滑动的选中背景
            AnimatedAlign(
              duration: NavBarConstants.animationDuration,
              curve: NavBarConstants.animationCurve,
              alignment: _isSearchExpanded
                  ? Alignment.centerRight
                  : Alignment((_selectedIndex - 1) * 1.0, 0),
              child: AnimatedContainer(
                duration: NavBarConstants.animationDuration,
                curve: NavBarConstants.animationCurve,
                width: _isSearchExpanded ? 0 : selectBgWidth,
                height: NavBarConstants.selectedContainerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NavBarConstants.selectedContainerBorderRadius),
                  color: theme.brightness == Brightness.dark
                      ? AppColors.bottomNavSelectedItem.withOpacity(NavBarConstants.selectedItemAlphaDark)
                      : theme.primaryColor.withOpacity(NavBarConstants.commonAlpha),
                ),
              ),
            ),
            // 内容切换
            AnimatedSwitcher(
              duration: NavBarConstants.animationDuration,
              child: _isSearchExpanded ? _buildMenuButton() : _buildNavigationButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContainer(double maxWidth) {
    return AnimatedContainer(
      duration: NavBarConstants.animationDuration,
      curve: NavBarConstants.animationCurve,
      width: _isSearchExpanded ? maxWidth : NavBarConstants.containerHeight,
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
          child: _isSearchExpanded ? _buildSearchField() : _buildSearchButton(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxColumnWidth = screenWidth > NavBarConstants.maxColumnWidthOffset
        ? screenWidth - NavBarConstants.maxColumnWidthOffset
        : NavBarConstants.minColumnWidth;
    
    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomPadding = MediaQuery.of(context).padding.bottom +
        viewInsets.bottom +
        NavBarConstants.bottomPaddingOffset;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomPadding,
        left: NavBarConstants.horizontalPadding,
        right: NavBarConstants.horizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavigationContainer(maxColumnWidth),
          _buildSearchContainer(maxColumnWidth),
        ],
      ),
    );
  }
}