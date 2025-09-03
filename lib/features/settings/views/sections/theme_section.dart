import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/spacing.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_card.dart';

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
      content: ListTile(
        title: Text(
          '主题选择',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        trailing: DropdownButton<int>(
          value: settingsState.settings.selectedTheme,
          dropdownColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(
                '系统默认',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text(
                '浅色主题',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 2,
              child: Text(
                '深色主题',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
          onChanged: (int? value) {
            if (value != null) {
              settingsNotifier.updateTheme(value, context);
            }
          },
        ),
      ),
    );
  }
}