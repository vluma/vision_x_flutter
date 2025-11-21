import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import '../providers/settings_provider.dart';
import 'sections/data_source_section.dart';
import 'sections/custom_api_section.dart';
import 'sections/theme_section.dart';
import 'sections/feature_switch_section.dart';
import 'sections/general_functions_section.dart';

/// 设置页面
/// 
/// 应用的设置界面，包含数据源设置、自定义API、主题设置、功能开关等
class SettingsPage extends ConsumerWidget {
  /// 构造函数
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听设置状态
    final settingsState = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : const _SettingsContent(),
    );
  }
}

/// 设置页面内容
class _SettingsContent extends ConsumerWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: AppSpacing.pageMargin.copyWith(
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DataSourceSection(),
            SizedBox(height: AppSpacing.md),
            CustomApiSection(),
            SizedBox(height: AppSpacing.md),
            ThemeSection(),
            SizedBox(height: AppSpacing.md),
            FeatureSwitchSection(),
            SizedBox(height: AppSpacing.md),
            GeneralFunctionsSection(),
          ],
        ),
      ),
    );
  }
}