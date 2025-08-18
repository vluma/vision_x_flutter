// bottom_navigation_bar.dart
// 功能: 底部导航栏组件，包含首页、历史、设置三个导航按钮和一个可展开的搜索按钮
// 创建日期: 2023-11-07

import 'package:flutter/material.dart';
import 'dart:ui';
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

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  static const Duration _animationDuration = Duration(milliseconds: 200);
  final TextEditingController _searchController = TextEditingController();
  String? _lastActivePath; // 保存上次激活的路径
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    searchDataSource.addListener(_onSearchDataSourceChanged);
    _searchController.text = searchDataSource.searchQuery;
    
    // 初始化时设置默认激活路径
    if (_lastActivePath == null) {
      if (widget.currentPath.startsWith('/history')) {
        _lastActivePath = '/history';
      } else if (widget.currentPath.startsWith('/settings')) {
        _lastActivePath = '/settings';
      } else {
        _lastActivePath = '/'; // 默认为主页
      }
    }
  }

  @override
  void dispose() {
    searchDataSource.removeListener(_onSearchDataSourceChanged);
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onSearchDataSourceChanged() {
    if (_searchController.text != searchDataSource.searchQuery) {
      setState(() {
        _searchController.text = searchDataSource.searchQuery;
      });
    }
  }

  bool _isActive(String path) {
    if (path == '/') {
      return widget.currentPath == '/' || widget.currentPath.startsWith('/?');
    }
    return widget.currentPath.startsWith(path);
  }

  void _toggleSearch() {
    setState(() {
      if (_lastActivePath != null) {
        _lastActivePath = widget.currentPath;
      }
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
      // 不再清空搜索内容，保留搜索结果
      // searchDataSource.clearSearch();
      _searchController.clear();
    });
  }

  Widget _buildNavButton(
      BuildContext context, String path, String label, IconData icon) {
    final isActive = _isActive(path);
    final theme = Theme.of(context);

    // 当搜索展开时，检查是否应该保持某个按钮的激活状态
    bool showAsActive = isActive;
    if (searchDataSource.isSearchExpanded && _lastActivePath != null) {
      showAsActive = _lastActivePath!.startsWith(path);
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          // 点击导航按钮时更新最后激活的路径
          setState(() {
            _lastActivePath = path;
          });
          GoRouter.of(context).go(path);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // 移除原来的背景色
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Icon(
              icon,
              color: showAsActive
                  ? AppColors.bottomNavSelectedItem // 修改选中样式为蓝色图标
                  : AppColors.bottomNavUnselectedItem, // 默认为半透明灰色图标
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final maxColumnWidth = MediaQuery.of(context).size.width - 90;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 10.0;

    // 确定当前选中的索引
    int selectedIndex = 0;
    if (_isActive('/history')) {
      selectedIndex = 1;
    } else if (_isActive('/settings')) {
      selectedIndex = 2;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 导航按钮区域 - 带有宽度动画
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: searchDataSource.isSearchExpanded ? 48.0 : maxColumnWidth,
            height: 48, // 设置固定高度
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFe6e6e6),
                  Color(0xFFFFFFFF),
                ],
              ),
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFd9d9d9),
                  offset: Offset(20, 20),
                  blurRadius: 60,
                ),
                BoxShadow(
                  color: Color(0xFFFFFFFF),
                  offset: Offset(-20, -20),
                  blurRadius: 60,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // 添加毛玻璃效果
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
                            : Alignment((selectedIndex - 1) * 1.0, 0),
                        child: Container(
                          width: searchDataSource.isSearchExpanded
                              ? 0
                              : (maxColumnWidth / 3),
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.bottomNavIndicator,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.bottomNavShadowInset1,
                                offset: Offset(20, 20),
                                blurRadius: 60,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: AppColors.bottomNavShadowInset2,
                                offset: Offset(-20, -20),
                                blurRadius: 60,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        duration: _animationDuration,
                        firstChild: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavButton(context, '/', '', Icons.home),
                            _buildNavButton(
                                context, '/history', '', Icons.history),
                            _buildNavButton(
                                context, '/settings', '', Icons.settings),
                          ],
                        ),
                        secondChild: InkWell(
                          onTap: _toggleMenu,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0), // 白色背景，透明度设为0
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: AnimatedOpacity(
                                duration: _animationDuration,
                                opacity: searchDataSource.isSearchExpanded
                                    ? 1.0
                                    : 0.0,
                                child: const Icon(
                                  Icons.menu,
                                  color:
                                      AppColors.bottomNavSelectedItem, // 蓝色图标
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        crossFadeState: searchDataSource.isSearchExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 搜索区域 - 使用AnimatedCrossFade避免形状插值
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: searchDataSource.isSearchExpanded ? maxColumnWidth : 48.0,
            height: 48, // 设置固定高度
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFe6e6e6),
                  Color(0xFFFFFFFF),
                ],
              ),
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.bottomNavShadowInset1,
                  offset: Offset(20, 20),
                  blurRadius: 60,
                ),
                BoxShadow(
                  color: AppColors.bottomNavShadowInset2,
                  offset: Offset(-20, -20),
                  blurRadius: 60,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // 添加毛玻璃效果
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: AnimatedCrossFade(
                    duration: _animationDuration,
                    firstChild: InkWell(
                      onTap: _toggleSearch,
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: AnimatedOpacity(
                            duration: _animationDuration,
                            opacity:
                                searchDataSource.isSearchExpanded ? 1.0 : 1.0,
                            child: const Icon(
                              Icons.search,
                              color: AppColors.bottomNavUnselectedItem,
                              size: 24,
                              semanticLabel: '搜索',
                            ),
                          ),
                        ),
                      ),
                    ),
                    secondChild: SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _searchController,
                        style:
                            const TextStyle(color: AppColors.lightPrimaryText),
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          hintStyle:
                              TextStyle(color: AppColors.lightSecondaryText),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search,
                              color: AppColors.bottomNavUnselectedItem),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                          isDense: true,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            searchDataSource.setSearchQuery(value);
                            context.go('/search');
                          }
                        },
                      ),
                    ),
                    crossFadeState: searchDataSource.isSearchExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
