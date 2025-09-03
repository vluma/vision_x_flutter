import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/settings_card.dart';

/// 通用功能设置区块
/// 
/// 用于设置应用的通用功能，如清除缓存、检查更新等
class GeneralFunctionsSection extends ConsumerWidget {
  /// 构造函数
  const GeneralFunctionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsCard(
      title: '通用功能',
      content: Column(
        children: [
          // 清除缓存
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            title: Text(
              '清除缓存',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            subtitle: Text(
              '清除应用缓存数据',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black54,
                fontSize: 12,
              ),
            ),
            onTap: () {
              _showClearCacheDialog(context);
            },
          ),
          // 检查更新
          ListTile(
            leading: Icon(
              Icons.update,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            title: Text(
              '检查更新',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            subtitle: Text(
              '检查应用是否有新版本',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black54,
                fontSize: 12,
              ),
            ),
            onTap: () {
              _checkForUpdates(context);
            },
          ),
          // 关于应用
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            title: Text(
              '关于应用',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            subtitle: Text(
              '查看应用版本和开发者信息',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black54,
                fontSize: 12,
              ),
            ),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// 显示清除缓存确认对话框
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 这里实现清除缓存的逻辑
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 检查应用更新
  void _checkForUpdates(BuildContext context) {
    // 这里实现检查更新的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('当前已是最新版本')),
    );
  }

  /// 显示关于应用对话框
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Vision X',
        applicationVersion: 'v1.0.0',
        applicationIcon: const FlutterLogo(size: 48),
        applicationLegalese: '© 2025 Vision X Team',
        children: [
          const SizedBox(height: 16),
          const Text('一款高效、美观的视频聚合应用'),
          const SizedBox(height: 8),
          const Text('基于Flutter开发'),
        ],
      ),
    );
  }
}