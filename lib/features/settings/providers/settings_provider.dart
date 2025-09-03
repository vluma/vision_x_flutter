import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../repositories/settings_repository.dart';
import 'settings_state.dart';
import '../../../core/themes/theme_provider.dart';
import '../../../services/api_service.dart';

/// 设置仓库提供者
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// 设置状态提供者
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

/// 设置状态管理器
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(SettingsState.initial()) {
    // 初始化时加载设置
    loadSettings();
  }

  /// 加载设置
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final settings = await _repository.loadSettings();
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '加载设置失败: $e',
      );
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      await _repository.saveSettings(state.settings);
    } catch (e) {
      state = state.copyWith(
        errorMessage: '保存设置失败: $e',
      );
    }
  }

  /// 切换播放源选择
  void toggleSource(String sourceKey, BuildContext context) {
    final currentSources = Set<String>.from(state.settings.selectedSources);
    
    if (currentSources.contains(sourceKey)) {
      // 检查是否至少保留一个源
      if (currentSources.length > 1) {
        currentSources.remove(sourceKey);
      } else {
        // 如果只剩一个源，不允许取消选择
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('至少需要选择一个数据源')),
        );
        return;
      }
    } else {
      currentSources.add(sourceKey);
    }

    state = state.copyWith(
      settings: state.settings.copyWith(
        selectedSources: currentSources,
      ),
    );
    
    _saveSettings();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置已自动保存')),
    );
  }

  /// 全选或全不选API
  void selectAllAPIs(bool selectAll, BuildContext context, [bool normalOnly = false]) {
    Set<String> newSources;
    
    if (selectAll) {
      if (normalOnly) {
        // 这里应该只选择普通资源，但我们现在没有区分
        newSources = ApiService.apiSites.keys.toSet();
      } else {
        newSources = ApiService.apiSites.keys.toSet();
      }
    } else {
      // 不允许全不选，至少保留一个源
      if (state.settings.selectedSources.length > 1) {
        newSources = {ApiService.apiSites.keys.first};
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('至少需要选择一个数据源')),
        );
        return;
      }
    }

    state = state.copyWith(
      settings: state.settings.copyWith(
        selectedSources: newSources,
      ),
    );
    
    _saveSettings();
  }

  /// 更新黄色内容过滤开关
  void updateYellowFilter(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        yellowFilterEnabled: value,
      ),
    );
    _saveSettings();
  }

  /// 更新广告过滤开关
  void updateAdFilter(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        adFilterEnabled: value,
      ),
    );
    _saveSettings();
  }

  /// 更新通过元数据过滤广告开关
  void updateAdFilterByMetadata(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        adFilterByMetadata: value,
      ),
    );
    _saveSettings();
  }

  /// 更新通过分辨率过滤广告开关
  void updateAdFilterByResolution(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        adFilterByResolution: value,
      ),
    );
    _saveSettings();
  }

  /// 更新主题设置
  void updateTheme(int value, BuildContext context) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        selectedTheme: value,
      ),
    );
    
    // 通知主应用更新主题
    final themeProvider = ThemeProvider.of(context);
    themeProvider.updateTheme(value);
    
    _saveSettings();
  }

  /// 显示添加自定义API表单
  void showAddCustomApiForm() {
    state = state.copyWith(
      customApiForm: state.customApiForm.copyWith(
        showForm: true,
        isHiddenSource: false,
      ),
    );
  }

  /// 取消添加自定义API
  void cancelAddCustomApi() {
    state = state.copyWith(
      customApiForm: state.customApiForm.copyWith(
        showForm: false,
        isHiddenSource: false,
      ),
    );
  }

  /// 更新是否为隐藏资源站
  void updateIsHiddenSource(bool value) {
    state = state.copyWith(
      customApiForm: state.customApiForm.copyWith(
        isHiddenSource: value,
      ),
    );
  }

  /// 添加自定义API
  void addCustomApi(String name, String url, String detail, BuildContext context) {
    if (name.isNotEmpty && url.isNotEmpty) {
      final newApi = {
        'key': 'custom_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'api': url,
        'detail': detail,
        'isHidden': state.customApiForm.isHiddenSource.toString(),
      };

      final updatedApis = List<Map<String, String>>.from(state.settings.customApis)
        ..add(newApi);

      state = state.copyWith(
        settings: state.settings.copyWith(
          customApis: updatedApis,
        ),
        customApiForm: state.customApiForm.copyWith(
          showForm: false,
          isHiddenSource: false,
        ),
      );

      _saveSettings();

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('自定义API添加成功')),
      );
    }
  }

  /// 删除自定义API
  void removeCustomApi(int index, BuildContext context) {
    final updatedApis = List<Map<String, String>>.from(state.settings.customApis);
    updatedApis.removeAt(index);

    state = state.copyWith(
      settings: state.settings.copyWith(
        customApis: updatedApis,
      ),
    );

    _saveSettings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('自定义API已删除')),
    );
  }
}