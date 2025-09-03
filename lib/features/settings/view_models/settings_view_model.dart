import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/settings_state.dart';

/// 设置视图模型
/// 
/// 负责处理设置页面的业务逻辑，连接视图和状态管理
class SettingsViewModel {
  final WidgetRef _ref;

  /// 构造函数
  SettingsViewModel(this._ref);

  /// 获取当前设置状态
  SettingsState get state => _ref.read(settingsProvider);

  /// 获取设置状态流
  Stream<SettingsState> get stateStream => _ref.watch(settingsProvider.notifier).stream;

  /// 切换主题模式
  void toggleThemeMode(BuildContext context) {
    final currentTheme = state.settings.selectedTheme;
    final newTheme = (currentTheme + 1) % 3; // 循环切换0,1,2
    
    _ref.read(settingsProvider.notifier).updateTheme(newTheme, context);
  }

  /// 获取当前主题模式名称
  String getThemeModeName() {
    switch (state.settings.selectedTheme) {
      case 0:
        return '跟随系统';
      case 1:
        return '浅色模式';
      case 2:
        return '深色模式';
      default:
        return '未知模式';
    }
  }

  /// 切换黄色内容过滤
  void toggleYellowFilter(bool value) {
    _ref.read(settingsProvider.notifier).updateYellowFilter(value);
  }

  /// 切换广告过滤
  void toggleAdFilter(bool value) {
    _ref.read(settingsProvider.notifier).updateAdFilter(value);
  }

  /// 切换广告过滤子选项 - 元数据过滤
  void toggleAdFilterByMetadata(bool value) {
    _ref.read(settingsProvider.notifier).updateAdFilterByMetadata(value);
  }

  /// 切换广告过滤子选项 - 分辨率过滤
  void toggleAdFilterByResolution(bool value) {
    _ref.read(settingsProvider.notifier).updateAdFilterByResolution(value);
  }

  /// 切换数据源选择
  void toggleSource(String sourceKey, BuildContext context) {
    _ref.read(settingsProvider.notifier).toggleSource(sourceKey, context);
  }

  /// 全选或全不选数据源
  void selectAllDataSources(bool selectAll, BuildContext context, [bool normalOnly = false]) {
    _ref.read(settingsProvider.notifier).selectAllAPIs(selectAll, context, normalOnly);
  }

  /// 添加自定义API
  void addCustomApi(String name, String url, String detail, BuildContext context) {
    _ref.read(settingsProvider.notifier).addCustomApi(name, url, detail, context);
  }

  /// 移除自定义API
  void removeCustomApi(int index, BuildContext context) {
    _ref.read(settingsProvider.notifier).removeCustomApi(index, context);
  }

  /// 显示添加自定义API表单
  void showAddCustomApiForm() {
    _ref.read(settingsProvider.notifier).showAddCustomApiForm();
  }

  /// 取消添加自定义API
  void cancelAddCustomApi() {
    _ref.read(settingsProvider.notifier).cancelAddCustomApi();
  }

  /// 更新是否为隐藏资源站
  void updateIsHiddenSource(bool value) {
    _ref.read(settingsProvider.notifier).updateIsHiddenSource(value);
  }

  /// 重置所有设置
  Future<void> resetAllSettings() async {
    // 通过notifier方法重置设置
    final notifier = _ref.read(settingsProvider.notifier);
    await notifier.loadSettings(); // 这会重置为默认设置并保存
  }
}