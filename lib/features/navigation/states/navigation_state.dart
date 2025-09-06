/// 导航状态类
/// 定义导航状态的数据结构和业务逻辑
library;

/// 导航栏标签枚举
enum NavBarTab {
  home,
  history,
  settings,
}

/// 导航栏状态
class NavigationState {
  final NavBarTab currentTab;
  final bool isSearchExpanded;
  final String? lastActivePath;

  const NavigationState({
    this.currentTab = NavBarTab.home,
    this.isSearchExpanded = false,
    this.lastActivePath,
  });

  /// 复制方法，用于状态更新
  NavigationState copyWith({
    NavBarTab? currentTab,
    bool? isSearchExpanded,
    String? lastActivePath,
  }) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      isSearchExpanded: isSearchExpanded ?? this.isSearchExpanded,
      lastActivePath: lastActivePath ?? this.lastActivePath,
    );
  }

  /// 从路径创建状态
  factory NavigationState.fromPath(String path) {
    return NavigationState(
      currentTab: _tabFromPath(path),
      lastActivePath: path,
      isSearchExpanded: false,
    );
  }

  /// 根据路径获取对应的标签
  static NavBarTab _tabFromPath(String path) {
    if (path.startsWith('/history')) {
      return NavBarTab.history;
    } else if (path.startsWith('/settings')) {
      return NavBarTab.settings;
    } else {
      return NavBarTab.home;
    }
  }

  /// 获取标签对应的路径
  static String pathFromTab(NavBarTab tab) {
    switch (tab) {
      case NavBarTab.home:
        return '/';
      case NavBarTab.history:
        return '/history';
      case NavBarTab.settings:
        return '/settings';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationState &&
        other.currentTab == currentTab &&
        other.isSearchExpanded == isSearchExpanded &&
        other.lastActivePath == lastActivePath;
  }

  @override
  int get hashCode {
    return currentTab.hashCode ^
        isSearchExpanded.hashCode ^
        lastActivePath.hashCode;
  }
}
