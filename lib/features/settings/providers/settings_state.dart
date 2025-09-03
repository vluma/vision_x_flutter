import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';

/// 设置状态类
/// 
/// 包含设置数据和UI状态
@immutable
class SettingsState {
  /// 设置数据模型
  final SettingsModel settings;
  
  /// 自定义API表单状态
  final CustomApiFormModel customApiForm;
  
  /// 是否正在加载
  final bool isLoading;
  
  /// 错误信息
  final String? errorMessage;

  /// 构造函数
  const SettingsState({
    required this.settings,
    required this.customApiForm,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 创建初始状态
  factory SettingsState.initial() {
    return SettingsState(
      settings: SettingsModel.defaultSettings(),
      customApiForm: CustomApiFormModel.initial(),
    );
  }

  /// 复制并修改部分属性
  SettingsState copyWith({
    SettingsModel? settings,
    CustomApiFormModel? customApiForm,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      customApiForm: customApiForm ?? this.customApiForm,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SettingsState &&
      other.settings == settings &&
      other.customApiForm == customApiForm &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage;
  }

  /// 哈希码
  @override
  int get hashCode {
    return settings.hashCode ^
      customApiForm.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode;
  }
}