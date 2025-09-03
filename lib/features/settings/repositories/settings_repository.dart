import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';
import '../../../services/api_service.dart';

/// 设置仓库
/// 
/// 负责设置数据的持久化存储和读取
class SettingsRepository {
  // SharedPreferences键名
  static const String _selectedSourcesKey = 'selected_sources';
  static const String _customApisKey = 'custom_apis';
  static const String _yellowFilterEnabledKey = 'yellow_filter_enabled';
  static const String _adFilterEnabledKey = 'ad_filter_enabled';
  static const String _adFilterByMetadataKey = 'ad_filter_by_metadata';
  static const String _adFilterByResolutionKey = 'ad_filter_by_resolution';
  static const String _selectedThemeKey = 'selected_theme';

  /// 加载设置
  Future<SettingsModel> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 加载选中的播放源
      final selectedSourcesString = prefs.getString(_selectedSourcesKey) ?? '';
      final Set<String> selectedSources;
      if (selectedSourcesString.isNotEmpty) {
        selectedSources = selectedSourcesString.split(',').toSet();
      } else {
        // 默认选中所有内置源
        selectedSources = ApiService.apiSites.keys.toSet();
      }

      // 加载自定义API
      final customApisJson = prefs.getStringList(_customApisKey) ?? [];
      final List<Map<String, String>> customApis = customApisJson
          .map((json) => Map<String, String>.from(jsonDecode(json)))
          .toList();

      // 加载功能开关设置
      final yellowFilterEnabled = prefs.getBool(_yellowFilterEnabledKey) ?? true;
      final adFilterEnabled = prefs.getBool(_adFilterEnabledKey) ?? false;
      
      // 加载广告过滤子选项
      final adFilterByMetadata = prefs.getBool(_adFilterByMetadataKey) ?? true;
      final adFilterByResolution = prefs.getBool(_adFilterByResolutionKey) ?? true;

      // 加载主题设置
      final selectedTheme = prefs.getInt(_selectedThemeKey) ?? 0;

      return SettingsModel(
        selectedSources: selectedSources,
        customApis: customApis,
        yellowFilterEnabled: yellowFilterEnabled,
        adFilterEnabled: adFilterEnabled,
        adFilterByMetadata: adFilterByMetadata,
        adFilterByResolution: adFilterByResolution,
        selectedTheme: selectedTheme,
      );
    } catch (e) {
      debugPrint('加载设置失败: $e');
      // 返回默认设置
      return SettingsModel.defaultSettings();
    }
  }

  /// 保存设置
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存选中的播放源
      await prefs.setString(_selectedSourcesKey, settings.selectedSources.join(','));

      // 保存自定义API
      final customApisJson = settings.customApis
          .map((api) => jsonEncode(api))
          .toList();
      await prefs.setStringList(_customApisKey, customApisJson);

      // 保存功能开关设置
      await prefs.setBool(_yellowFilterEnabledKey, settings.yellowFilterEnabled);
      await prefs.setBool(_adFilterEnabledKey, settings.adFilterEnabled);
      
      // 保存广告过滤子选项
      await prefs.setBool(_adFilterByMetadataKey, settings.adFilterByMetadata);
      await prefs.setBool(_adFilterByResolutionKey, settings.adFilterByResolution);

      // 保存主题设置
      await prefs.setInt(_selectedThemeKey, settings.selectedTheme);
    } catch (e) {
      debugPrint('保存设置失败: $e');
      rethrow;
    }
  }
}