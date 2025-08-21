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
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isActive
                  ? theme.primaryColor
                  : theme.brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black54,
              size: 24,
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
            size: 24,
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
            size: 24,
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
          minWidth: 40,
          minHeight: 40,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        isDense: true,
      ),
      textAlignVertical: TextAlignVertical.center,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          searchDataSource.setSearchQuery(value);
          context.go('/search');
        }
      },
    );
  }

  List<Color> _getGradientColors() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return isDarkMode
        ? [
            theme.cardColor,
            theme.scaffoldBackgroundColor,
          ]
        : [
            theme.cardColor,
            theme.scaffoldBackgroundColor,
          ];
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
        ? theme.dividerColor.withValues(alpha: 0.3)
        : theme.dividerColor.withValues(alpha: 0.2);
  }

  Widget _buildNavigationContainer(double maxWidth) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: searchDataSource.isSearchExpanded ? 48.0 : maxWidth,
      height: 48,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _getBorderColor(),
          width: 0.5, // 更细的边框
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Stack(
          children: [
            // 滑动的选中背景
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: searchDataSource.isSearchExpanded
                  ? Alignment.centerRight
                  : Alignment((_selectedIndex - 1) * 1.0, 0),
              child: Container(
                width: searchDataSource.isSearchExpanded ? 0 : (maxWidth / 3),
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: theme.brightness == Brightness.dark
                      ? AppColors.bottomNavIndicator
                      : theme.primaryColor
                          .withValues(alpha: 0.1), // 浅色模式下使用主色的淡色版本
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
      duration: const Duration(milliseconds: 200),
      width: searchDataSource.isSearchExpanded ? maxWidth : 48.0,
      height: 48,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getBorderColor(),
          width: 0.5, // 更细的边框
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
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
    final maxColumnWidth = MediaQuery.of(context).size.width - 90;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 10.0;
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
      padding: EdgeInsets.only(bottom: bottomPadding, left: 16.0, right: 16.0),
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
