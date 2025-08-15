// bottom_navigation_bar.dart
// 功能: 底部导航栏组件，包含首页、历史、设置三个导航按钮和一个可展开的搜索按钮
// 创建日期: 2023-11-07

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final String currentPath;

  const BottomNavigationBarWidget({super.key, required this.currentPath});

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  static const Duration _animationDuration = Duration(milliseconds: 200);
  bool _isSearchExpanded = false;
  final bool _isMenuExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  bool _isActive(String path) {
    // 修复导航路径判断逻辑
    if (path == '/') {
      return widget.currentPath == '/' || widget.currentPath.startsWith('/?');
    }
    return widget.currentPath.startsWith(path);
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
      }
    });
  }

  void _toggleMenu() {
    setState(() {
      _isSearchExpanded = false;
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
            width: _isSearchExpanded ? 48.0 : maxColumnWidth,
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
                      _buildNavButton(
                          context, '/', '', Icons.home, _isSearchExpanded),
                      _buildNavButton(context, '/history', '', Icons.history,
                          _isSearchExpanded),
                      _buildNavButton(context, '/settings', '', Icons.settings,
                          _isSearchExpanded),
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
                          opacity: _isSearchExpanded ? 1.0 : 0.0,
                          child: Icon(
                            Icons.menu,
                            color: Colors.blue, // 蓝色图标
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  crossFadeState: _isSearchExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                ),
              ),
            ),
          ),

          // 搜索区域 - 使用AnimatedCrossFade避免形状插值
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSearchExpanded ? maxColumnWidth : 48.0,
            height: 48, // 设置固定高度
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8), // 修改背景颜色为白色，透明度80%
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.7), // 水反光颜色边框
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
                          opacity: _isSearchExpanded ? 1.0 : 1.0,
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
                            vertical: 12, horizontal: 16),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          context.go('/search');
                        }
                      },
                    ),
                  ),
                  crossFadeState: _isSearchExpanded
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

  Widget _buildNavButton(BuildContext context, String path, String label,
      IconData icon, bool isSearchExpanded) {
    final isActive = _isActive(path);
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          GoRouter.of(context).go(path);
        },
        child: Container(
          decoration: BoxDecoration(
            color:
                isActive ? Colors.grey[300] : Colors.transparent, // 修改选中样式为灰色背景
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: _animationDuration,
              opacity: isSearchExpanded ? 0.0 : 1.0,
              child: Icon(
                icon,
                color: isActive
                    ? Colors.blue // 修改选中样式为蓝色图标
                    : Colors.grey[700], // 默认为灰色图标
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
