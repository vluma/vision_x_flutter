import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_card.dart';
import '../../../../services/api_service.dart';

/// 数据源设置区块
/// 
/// 用于选择和管理视频数据源
class DataSourceSection extends ConsumerWidget {
  /// 构造函数
  const DataSourceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final settingsState = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsCard(
      title: '数据源设置',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 全选按钮
          Row(
            children: [
              ElevatedButton(
                onPressed: () => settingsNotifier.selectAllAPIs(true, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  '全选',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => settingsNotifier.selectAllAPIs(false, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFEEEEEE),
                  foregroundColor: isDark ? Colors.white70 : Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  '全不选',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => settingsNotifier.selectAllAPIs(true, context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  '全选普通资源',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // API复选框列表
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 4,
              ),
              itemCount: ApiService.apiSites.length,
              itemBuilder: (context, index) {
                final entry = ApiService.apiSites.entries.elementAt(index);
                return CheckboxListTile(
                  activeColor: Theme.of(context).primaryColor,
                  title: Text(
                    entry.value['name']!,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  value: settingsState.settings.selectedSources.contains(entry.key),
                  onChanged: (bool? value) {
                    settingsNotifier.toggleSource(entry.key, context);
                  },
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // 已选API数量
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已选API数量：${settingsState.settings.selectedSources.length}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              Text(
                '至少需要选择1个数据源',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}