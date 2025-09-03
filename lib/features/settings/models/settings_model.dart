import 'package:flutter/foundation.dart';

/// 设置数据模型
/// 
/// 包含所有设置项的数据结构，用于在应用中表示设置状态
class SettingsModel {
  /// 选中的播放源
  final Set<String> selectedSources;

  /// 自定义API源
  final List<Map<String, String>> customApis;

  /// 功能开关 - 黄色内容过滤
  final bool yellowFilterEnabled;

  /// 功能开关 - 广告过滤
  final bool adFilterEnabled;
  
  /// 广告过滤子选项 - 通过元数据过滤
  final bool adFilterByMetadata;

  /// 广告过滤子选项 - 通过分辨率过滤
  final bool adFilterByResolution;

  /// 主题选择 (0: 系统默认, 1: 浅色主题, 2: 深色主题)
  final int selectedTheme;

  /// 构造函数
  const SettingsModel({
    required this.selectedSources,
    required this.customApis,
    required this.yellowFilterEnabled,
    required this.adFilterEnabled,
    required this.adFilterByMetadata,
    required this.adFilterByResolution,
    required this.selectedTheme,
  });

  /// 创建默认设置
  factory SettingsModel.defaultSettings() {
    return const SettingsModel(
      selectedSources: {},
      customApis: [],
      yellowFilterEnabled: true,
      adFilterEnabled: false,
      adFilterByMetadata: true,
      adFilterByResolution: true,
      selectedTheme: 0,
    );
  }

  /// 复制并修改部分属性
  SettingsModel copyWith({
    Set<String>? selectedSources,
    List<Map<String, String>>? customApis,
    bool? yellowFilterEnabled,
    bool? adFilterEnabled,
    bool? adFilterByMetadata,
    bool? adFilterByResolution,
    int? selectedTheme,
  }) {
    return SettingsModel(
      selectedSources: selectedSources ?? this.selectedSources,
      customApis: customApis ?? this.customApis,
      yellowFilterEnabled: yellowFilterEnabled ?? this.yellowFilterEnabled,
      adFilterEnabled: adFilterEnabled ?? this.adFilterEnabled,
      adFilterByMetadata: adFilterByMetadata ?? this.adFilterByMetadata,
      adFilterByResolution: adFilterByResolution ?? this.adFilterByResolution,
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SettingsModel &&
      setEquals(other.selectedSources, selectedSources) &&
      listEquals(other.customApis, customApis) &&
      other.yellowFilterEnabled == yellowFilterEnabled &&
      other.adFilterEnabled == adFilterEnabled &&
      other.adFilterByMetadata == adFilterByMetadata &&
      other.adFilterByResolution == adFilterByResolution &&
      other.selectedTheme == selectedTheme;
  }

  /// 哈希码
  @override
  int get hashCode {
    return selectedSources.hashCode ^
      customApis.hashCode ^
      yellowFilterEnabled.hashCode ^
      adFilterEnabled.hashCode ^
      adFilterByMetadata.hashCode ^
      adFilterByResolution.hashCode ^
      selectedTheme.hashCode;
  }
}

/// 自定义API表单状态模型
class CustomApiFormModel {
  /// 是否显示自定义API表单
  final bool showForm;
  
  /// 是否为隐藏资源站
  final bool isHiddenSource;

  /// 构造函数
  const CustomApiFormModel({
    required this.showForm,
    required this.isHiddenSource,
  });

  /// 创建默认状态
  factory CustomApiFormModel.initial() {
    return const CustomApiFormModel(
      showForm: false,
      isHiddenSource: false,
    );
  }

  /// 复制并修改部分属性
  CustomApiFormModel copyWith({
    bool? showForm,
    bool? isHiddenSource,
  }) {
    return CustomApiFormModel(
      showForm: showForm ?? this.showForm,
      isHiddenSource: isHiddenSource ?? this.isHiddenSource,
    );
  }
}