// bottom_navigation_bar.dart
// 功能: 底部导航栏组件，包含首页、历史、设置三个导航按钮和一个可展开的搜索按钮
// 创建日期: 2023-11-07

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:vision_x_flutter/theme/colors.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final String currentPath;

  const BottomNavigationBarWidget({super.key, required this.currentPath});

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget>
    with WidgetsBindingObserver {
  // 常量定义
  static const double _containerHeight = 56.0;
  static const double _containerBorderRadius = 28.0;
  static const double _selectedContainerHeight = 48.0;
  static const double _selectedContainerBorderRadius = 24.0;
  static const double _prefixIconMinSize = 48.0;
  static const double _iconSize = 24.0;
  static const double _paddingAll = 4.0;
  static const double _borderWidth = 0.5;
  static const double _boxShadowBlurRadius = 2.0;
  static const double _boxShadowOffset = 1.0;
  static const double _contentPaddingVertical = 8.0;
  static const double _contentPaddingHorizontal = 0.0;
  static const double _bottomPaddingOffset = 16.0;
  static const double _maxColumnWidthOffset = 90.0;
  static const double _horizontalPadding = 16.0;
  static const double _minColumnWidth = 100.0; // 添加最小宽度限制
  static const double _borderAlphaDark = 0.3;
  static const double _borderAlphaLight = 0.2;
  static const double _commonAlpha = 0.1;
  static const double _selectedItemAlphaDark = 0.2;

  static const Duration _animationDuration = Duration(milliseconds: 200);

  final TextEditingController _searchController = TextEditingController();
  String? _lastActivePath;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeSelectedIndex();
    searchDataSource.addListener(_onSearchDataSourceChanged);
    _searchController.text = searchDataSource.searchQuery;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchDataSource.removeListener(_onSearchDataSourceChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // 当系统配置发生变化时刷新界面
    setState(() {});
  }

  @override
  void didChangePlatformBrightness() {
    // 当系统亮度发生变化时刷新界面
    setState(() {});
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
      setState(() {
        _searchController.text = searchDataSource.searchQuery;
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _lastActivePath = widget.currentPath;
      GoRouter.of(context).go('/search');
      searchDataSource.setSearchExpanded(!searchDataSource.isSearchExpanded);

      if (!searchDataSource.isSearchExpanded) {
        searchDataSource.clearSearch();
        _searchController.clear();
      }
    });
  }

  void _toggleMenu() {
    setState(() {
      if (_lastActivePath != null) {
        GoRouter.of(context).go(_lastActivePath!);
      }
      searchDataSource.setSearchExpanded(false);
      _searchController.clear();
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      final paths = ['/', '/history', '/settings'];
      final path = paths[index];

      _lastActivePath = path;
      GoRouter.of(context).go(path);
    });
  }

  Widget _buildNavButton(int index, IconData icon) {
    final theme = Theme.of(context);
    final isActive = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavItemTapped(index),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(_containerBorderRadius),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isActive
                  ? theme.primaryColor
                  : theme.brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black54,
              size: _iconSize,
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
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.menu,
            color: theme.primaryColor,
            size: _iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return InkWell(
      onTap: _toggleSearch,
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Icon(
            Icons.search,
            color: _getIconColor(),
            size: _iconSize,
            semanticLabel: '搜索',
          ),
        ),
      ),
    );
  }

  Color _getIconColor() {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.white60
        : Colors.black54;
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextField(
      controller: _searchController,
      style: TextStyle(
          color: theme.textTheme.bodyLarge?.color ??
              (theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black)),
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(
            color: isDarkMode
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText),
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: _getIconColor()),
        prefixIconConstraints: const BoxConstraints(
          minWidth: _prefixIconMinSize,
          minHeight: _prefixIconMinSize,
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: _contentPaddingVertical,
            horizontal: _contentPaddingHorizontal),
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

  Color _getBackgroundColor() {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? theme.scaffoldBackgroundColor
        : theme.cardColor;
  }

  // 获取边框颜色
  Color _getBorderColor() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 使用更自然的边框颜色，与主题更协调
    return isDarkMode
        ? theme.dividerColor.withValues(alpha: _borderAlphaDark)
        : theme.dividerColor.withValues(alpha: _borderAlphaLight);
  }

  Widget _buildNavigationContainer(double maxWidth) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: _animationDuration,
      width: searchDataSource.isSearchExpanded ? _containerHeight : maxWidth,
      height: _containerHeight,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(_containerBorderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: _borderWidth, // 更细的边框
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withValues(alpha: _commonAlpha),
            offset: const Offset(0, _boxShadowOffset),
            blurRadius: _boxShadowBlurRadius,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_paddingAll),
        child: Stack(
          children: [
            // 滑动的选中背景
            AnimatedAlign(
              duration: _animationDuration,
              curve: Curves.easeInOut,
              alignment: searchDataSource.isSearchExpanded
                  ? Alignment.centerRight
                  : Alignment((_selectedIndex - 1) * 1.0, 0),
              child: Container(
                width: searchDataSource.isSearchExpanded ? 0 : (maxWidth / 3),
                height: _selectedContainerHeight,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(_selectedContainerBorderRadius),
                  color: theme.brightness == Brightness.dark
                      ? AppColors.bottomNavSelectedItem
                          .withValues(alpha: _selectedItemAlphaDark)
                      : theme.primaryColor.withValues(alpha: _commonAlpha),
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: _animationDuration,
              firstChild: _buildNavigationButtons(),
              secondChild: _buildMenuButton(),
              crossFadeState: searchDataSource.isSearchExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContainer(double maxWidth) {
    return AnimatedContainer(
      duration: _animationDuration,
      width: searchDataSource.isSearchExpanded ? maxWidth : _containerHeight,
      height: _containerHeight,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(_containerBorderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: _borderWidth, // 更细的边框
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withValues(alpha: _commonAlpha),
            offset: const Offset(0, _boxShadowOffset),
            blurRadius: _boxShadowBlurRadius,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_paddingAll),
        child: AnimatedCrossFade(
          duration: _animationDuration,
          firstChild: _buildSearchButton(),
          secondChild: _buildSearchField(),
          crossFadeState: searchDataSource.isSearchExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 确保maxColumnWidth不会是负数，设置一个最小值
    final maxColumnWidth = 
        screenWidth > _maxColumnWidthOffset 
            ? screenWidth - _maxColumnWidthOffset 
            : _minColumnWidth;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomPadding = MediaQuery.of(context).padding.bottom +
        viewInsets.bottom +
        _bottomPaddingOffset;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        // 使用渐变背景替代纯色背景，透明度范围在0-0.4之间
        gradient: LinearGradient(
          colors: [
            theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
            theme.scaffoldBackgroundColor.withValues(alpha: 1.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(
          bottom: bottomPadding,
          left: _horizontalPadding,
          right: _horizontalPadding),
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