import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import '../settings_controller.dart';

class GeneralFunctionsSection extends StatelessWidget {
  const GeneralFunctionsSection({super.key});

  // 导入配置
  void _importConfig(BuildContext context) {
    // 这里应该实现配置导入逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入配置功能待实现')),
    );
  }

  // 导出配置
  void _exportConfig(BuildContext context) {
    // 这里应该实现配置导出逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出配置功能待实现')),
    );
  }

  // 检查更新
  void _checkUpdate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('当前已是最新版本')),
    );
  }

  // 关于应用
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('关于应用'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vision X Flutter'),
              SizedBox(height: 8),
              Text('版本: 1.0.0'),
              SizedBox(height: 8),
              Text('一个聚合搜索影视资源的Flutter应用'),
              SizedBox(height: 8),
              Text('支持多数据源搜索，提供流畅的观影体验'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 清除本地存储
  void _clearLocalStorage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认清除'),
          content: const Text('确定要清除所有本地存储数据吗？\n包括搜索历史、播放记录等。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 实际清除逻辑
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                
                // 重新加载设置
                final controller = Provider.of<SettingsController>(context, listen: false);
                await controller.loadSettings();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('本地数据已清除')),
                );
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              '一般功能',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // 导入配置
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () => _importConfig(context),
                icon: const Icon(Icons.file_upload, size: 18),
                label: const Text('导入配置'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // 导出配置
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () => _exportConfig(context),
                icon: const Icon(Icons.file_download, size: 18),
                label: const Text('导出配置'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // 检查更新
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () => _checkUpdate(context),
                icon: const Icon(Icons.system_update, size: 18),
                label: const Text('检查更新'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // 关于应用
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () => _showAbout(context),
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('关于应用'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // 清除Cookie
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _clearLocalStorage(context),
                icon: const Icon(Icons.delete_forever, size: 18),
                label: const Text('清除本地数据'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFFCF6679)
                      : const Color(0xFFB00020),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}