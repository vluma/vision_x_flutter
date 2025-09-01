/// 导航提供者
/// 使用ChangeNotifier管理导航状态

import 'package:flutter/material.dart';
import '../states/navigation_state.dart';

/// 导航状态提供者
class NavigationProvider with ChangeNotifier {
  NavigationState _state = const NavigationState();

  NavigationState get state => _state;

  /// 更新当前标签
  void updateTab(NavBarTab tab) {
    _state = _state.copyWith(currentTab: tab);
    notifyListeners();
  }

  /// 切换搜索状态
  void toggleSearch(bool isExpanded) {
    _state = _state.copyWith(isSearchExpanded: isExpanded);
    notifyListeners();
  }

  /// 更新最后活动路径
  void updateLastActivePath(String path) {
    _state = _state.copyWith(lastActivePath: path);
    notifyListeners();
  }

  /// 从路径更新状态
  void updateFromPath(String path) {
    _state = NavigationState.fromPath(path);
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _state = const NavigationState();
    notifyListeners();
  }
}