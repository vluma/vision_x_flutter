import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import '../settings_controller.dart';

class FeatureSwitchSection extends StatelessWidget {
  const FeatureSwitchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SettingsController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: isDark ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '功能开关',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // 黄色内容过滤
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
                    thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context).primaryColor;
                      }
                      return Colors.grey; // 默认颜色
                    }),
                    value: controller.yellowFilterEnabled,
                    onChanged: (bool value) {
                      controller.updateYellowFilter(value);
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
                    thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context).primaryColor;
                      }
                      return Colors.grey; // 默认颜色
                    }),
                    value: controller.adFilterEnabled,
                    onChanged: (bool value) {
                      controller.updateAdFilter(value);
                    },
                  ),
                ],
              ),
            ),
            // 广告过滤子选项
            if (controller.adFilterEnabled) ...[
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
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
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
                      thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(context).primaryColor;
                        }
                        return Colors.grey; // 默认颜色
                      }),
                      value: controller.adFilterByMetadata,
                      onChanged: (bool value) {
                        controller.updateAdFilterByMetadata(value);
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
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
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
                      thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(context).primaryColor;
                        }
                        return Colors.grey; // 默认颜色
                      }),
                      value: controller.adFilterByResolution,
                      onChanged: (bool value) {
                        controller.updateAdFilterByResolution(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
