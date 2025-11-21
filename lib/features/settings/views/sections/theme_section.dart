import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import '../../widgets/settings_card.dart';
import '../../providers/settings_provider.dart';

/// 主题设置区块
/// 
/// 用于设置应用的主题样式
class ThemeSection extends ConsumerWidget {
  /// 构造函数
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final settingsState = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsCard(
      title: '主题设置',
      content: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            RadioListTile<int>(
              activeColor: Theme.of(context).primaryColor,
              title: const Text('跟随系统'),
              value: 0,
              groupValue: settingsState.settings.selectedTheme,
              onChanged: (int? value) {
                if (value != null) {
                  settingsNotifier.updateTheme(value, context);
                }
              },
            ),
            RadioListTile<int>(
              activeColor: Theme.of(context).primaryColor,
              title: const Text('浅色模式'),
              value: 1,
              groupValue: settingsState.settings.selectedTheme,
              onChanged: (int? value) {
                if (value != null) {
                  settingsNotifier.updateTheme(value, context);
                }
              },
            ),
            RadioListTile<int>(
              activeColor: Theme.of(context).primaryColor,
              title: const Text('深色模式'),
              value: 2,
              groupValue: settingsState.settings.selectedTheme,
              onChanged: (int? value) {
                if (value != null) {
                  settingsNotifier.updateTheme(value, context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}