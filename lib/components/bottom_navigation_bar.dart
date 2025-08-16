// bottom_navigation_bar.dart
// 功能: 底部导航栏组件，包含首页、历史、设置三个导航按钮和一个可展开的搜索按钮
// 创建日期: 2023-11-07

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vision_x_flutter/services/api_service.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final String currentPath;

  const BottomNavigationBarWidget({super.key, required this.currentPath});

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  static const Duration _animationDuration = Duration(milliseconds: 200);
  final bool _isMenuExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String? _lastActivePath; // 保存上次激活的路径
  @override
  void initState() {
    super.initState();
    // 监听搜索数据源的变化
    searchDataSource.addListener(_onSearchDataSourceChanged);
    // 初始化搜索控制器的值
    _searchController.text = searchDataSource.searchQuery;
  }

  @override
  void dispose() {
    searchDataSource.removeListener(_onSearchDataSourceChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchDataSourceChanged() {
    // 当数据源中的搜索查询发生变化时，更新文本字段
    if (_searchController.text != searchDataSource.searchQuery) {
      setState(() {
        _searchController.text = searchDataSource.searchQuery;
      });
    }
  }

  bool _isActive(String path) {
    // 修复导航路径判断逻辑
    if (path == '/') {
      return widget.currentPath == '/' || widget.currentPath.startsWith('/?');
    }
    return widget.currentPath.startsWith(path);
  }

  void _toggleSearch() {
    setState(() {
      if (widget.currentPath.startsWith('/')) {
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
      searchDataSource.clearSearch();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final maxColumnWidth =
        MediaQuery.of(context).size.width - 90; // 32 + 48 + 16 + 10 = 106
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0), // 修改背景颜色为完全透明
      ),
      padding: const EdgeInsets.only(bottom: 34, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 导航按钮区域 - 带有宽度动画
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: searchDataSource.isSearchExpanded ? 48.0 : maxColumnWidth,
            height: 48, // 设置固定高度
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8), // 修改背景颜色为白色，透明度80%
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7), // 改为类似水反光的白色高亮色调
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // 添加毛玻璃效果
                child: AnimatedCrossFade(
                  duration: _animationDuration,
                  firstChild: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavButton(context, '/', '', Icons.home),
                      _buildNavButton(context, '/history', '', Icons.history),
                      _buildNavButton(context, '/settings', '', Icons.settings),
                    ],
                  ),
                  secondChild: InkWell(
                    onTap: _toggleMenu,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0), // 白色背景，透明度设为0
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AnimatedOpacity(
                          duration: _animationDuration,
                          opacity: searchDataSource.isSearchExpanded ? 1.0 : 0.0,
                          child: Icon(
                            Icons.menu,
                            color: Colors.blue, // 蓝色图标
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
              ),
            ),
          ),

          // 搜索区域 - 使用AnimatedCrossFade避免形状插值
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: searchDataSource.isSearchExpanded ? maxColumnWidth : 48.0,
            height: 48, // 设置固定高度
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8), // 修改背景颜色为白色，透明度80%
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7), // 水反光颜色边框
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // 添加毛玻璃效果
                child: AnimatedCrossFade(
                  duration: _animationDuration,
                  firstChild: InkWell(
                    onTap: _toggleSearch,
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: AnimatedOpacity(
                          duration: _animationDuration,
                          opacity: searchDataSource.isSearchExpanded ? 1.0 : 1.0,
                          child: Icon(
                            Icons.search,
                            color: Colors.grey[700],
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
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0),
                      ),
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
        ],
      ),
    );
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
            color: showAsActive
                ? Colors.grey[300]
                : Colors.transparent, // 修改选中样式为灰色背景
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Icon(
              icon,
              color: showAsActive
                  ? Colors.blue // 修改选中样式为蓝色图标
                  : Colors.grey[700], // 默认为灰色图标
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
