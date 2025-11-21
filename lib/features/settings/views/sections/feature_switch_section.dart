import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import '../../widgets/settings_card.dart';
import '../../providers/settings_provider.dart';

/// 功能开关设置区块
/// 
/// 用于设置应用的各种功能开关
class FeatureSwitchSection extends ConsumerWidget {
  /// 构造函数
  const FeatureSwitchSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final settingsState = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsCard(
      title: '功能开关',
      content: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 黄色内容过滤
            SwitchListTile(
              activeColor: Theme.of(context).primaryColor,
              title: const Text('过滤黄色内容'),
              subtitle: const Text('开启后将过滤包含黄色内容的视频'),
              value: settingsState.settings.yellowFilterEnabled,
              onChanged: (bool value) {
                settingsNotifier.updateYellowFilter(value);
              },
            ),
            const Divider(height: 1),
            // 广告过滤
            SwitchListTile(
              activeColor: Theme.of(context).primaryColor,
              title: const Text('过滤广告'),
              subtitle: const Text('开启后将过滤视频中的广告内容'),
              value: settingsState.settings.adFilterEnabled,
              onChanged: (bool value) {
                settingsNotifier.updateAdFilter(value);
              },
            ),
            // 广告过滤子选项
            if (settingsState.settings.adFilterEnabled) ...[
              const Divider(height: 1),
              SwitchListTile(
                activeColor: Theme.of(context).primaryColor,
                title: const Text('通过元数据区分过滤广告'),
                subtitle: const Text('通过视频元数据识别并过滤广告'),
                value: settingsState.settings.adFilterByMetadata,
                onChanged: (bool value) {
                  settingsNotifier.updateAdFilterByMetadata(value);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                activeColor: Theme.of(context).primaryColor,
                title: const Text('通过分辨率区分过滤广告'),
                subtitle: const Text('注意：Beta功能，可能导致未知问题'),
                value: settingsState.settings.adFilterByResolution,
                onChanged: (bool value) {
                  settingsNotifier.updateAdFilterByResolution(value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}