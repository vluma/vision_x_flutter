import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/spacing.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_card.dart';

/// 功能开关设置区块
///
/// 用于控制应用的各种功能开关
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
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 黄色内容过滤
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: isDark ? Colors.white12 : Colors.black12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '黄色内容过滤',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '过滤搜索列表中"伦理"等类型的视频',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeColor: Theme.of(context).primaryColor,
                  value: settingsState.settings.yellowFilterEnabled,
                  onChanged: (bool value) {
                    settingsNotifier.updateYellowFilter(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 分片广告过滤
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: isDark ? Colors.white12 : Colors.black12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '分片广告过滤',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Beta',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.orange.shade200
                                    : Colors.orange.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '关闭可减少旧版浏览器卡顿',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '注意：此功能为Beta版本，可能导致未知问题',
                        style: TextStyle(
                          color: isDark
                              ? Colors.orange.shade200
                              : Colors.orange.shade800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeColor: Theme.of(context).primaryColor,
                  value: settingsState.settings.adFilterEnabled,
                  onChanged: (bool value) {
                    settingsNotifier.updateAdFilter(value);
                  },
                ),
              ],
            ),
          ),
          // 广告过滤子选项
          if (settingsState.settings.adFilterEnabled) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '通过元数据过滤广告',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Beta',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.orange.shade200
                                      : Colors.orange.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '通过码率和标签过滤广告（快速）',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '注意：Beta功能，可能导致未知问题',
                          style: TextStyle(
                            color: isDark
                                ? Colors.orange.shade200
                                : Colors.orange.shade800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    activeColor: Theme.of(context).primaryColor,
                    value: settingsState.settings.adFilterByMetadata,
                    onChanged: (bool value) {
                      settingsNotifier.updateAdFilterByMetadata(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '通过分辨率过滤广告',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Beta',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.orange.shade200
                                      : Colors.orange.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '通过分辨率区分过滤广告',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '注意：Beta功能，可能导致未知问题',
                          style: TextStyle(
                            color: isDark
                                ? Colors.orange.shade200
                                : Colors.orange.shade800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    activeColor: Theme.of(context).primaryColor,
                    value: settingsState.settings.adFilterByResolution,
                    onChanged: (bool value) {
                      settingsNotifier.updateAdFilterByResolution(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
