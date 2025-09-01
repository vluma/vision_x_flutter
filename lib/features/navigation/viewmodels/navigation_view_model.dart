/// 导航视图模型
/// 处理导航相关的业务逻辑

import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import '../providers/navigation_provider.dart';
import '../states/navigation_state.dart';

/// 导航视图模型
class NavigationViewModel {
  final NavigationProvider _provider;
  final GoRouter _router;

  NavigationViewModel(this._provider, this._router);

  /// 导航到指定标签
  void navigateToTab(NavBarTab tab) {
    final path = NavigationState.pathFromTab(tab);
    _provider.updateTab(tab);
    _provider.updateLastActivePath(path);
    _router.go(path);
  }

  /// 切换搜索状态
  void toggleSearch(String currentPath) {
    final currentState = _provider.state;
    final newSearchState = !currentState.isSearchExpanded;

    if (newSearchState) {
      // 展开搜索时先记录当前路径，再切换状态和跳转
      _provider.updateLastActivePath(currentPath);
      _provider.toggleSearch(newSearchState);
      _router.go('/search');
    } else {
      // 收起搜索时先切换状态，再返回之前记录的路径
      _provider.toggleSearch(newSearchState);
      final lastActivePath = _provider.state.lastActivePath;
      if (lastActivePath != null && lastActivePath != '/search') {
        _router.go(lastActivePath);
      } else {
        _router.go('/');
      }
      // 清空搜索数据
      searchDataSource.clearSearch();
    }
  }

  /// 处理路径变化
  void handlePathChange(String path) {
    // 如果是跳转到搜索页面，自动展开搜索框
    if (path == '/search') {
      // 保留当前的其他状态，只更新路径和搜索展开状态
      final currentState = _provider.state;
      _provider.updateLastActivePath(path);
      if (!currentState.isSearchExpanded) {
        _provider.toggleSearch(true);
      }
    } else {
      // 对于非搜索页面，更新完整状态
      _provider.updateFromPath(path);
    }
  }

  /// 获取当前标签
  NavBarTab get currentTab => _provider.state.currentTab;

  /// 棜查是否在搜索状态
  bool get isSearchExpanded => _provider.state.isSearchExpanded;
}