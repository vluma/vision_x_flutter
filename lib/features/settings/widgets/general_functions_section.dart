import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/services/update_service.dart';
import 'package:vision_x_flutter/services/install_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'package:go_router/go_router.dart'; // 添加go_router导入
import '../settings_controller.dart';

class GeneralFunctionsSection extends StatefulWidget {
  const GeneralFunctionsSection({super.key});

  @override
  State<GeneralFunctionsSection> createState() => _GeneralFunctionsSectionState();
}

class _GeneralFunctionsSectionState extends State<GeneralFunctionsSection> {
  bool _isCheckingUpdate = false;
  bool _hasNewVersion = false;
  String? _newVersion;

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
  Future<void> _checkUpdate(BuildContext context) async {
    setState(() {
      _isCheckingUpdate = true;
      _hasNewVersion = false;
      _newVersion = null;
    });

    try {
      // 初始化更新服务，使用您提供的实际密钥
      final updateService = UpdateService(
        apiKey: '65e9608ac0509189f3a36b3170ac3065', // 您提供的API Key
        appKey: '459d8d1f4abc2b79fca6d6a240bab74d', // 您提供的App Key
      );

      final updateInfo = await updateService.checkForUpdate();
      
      // 打印更新信息用于调试
      if (updateInfo != null) {
        debugPrint('=== App Update Info ===');
        debugPrint('Has new version: ${updateInfo.buildHaveNewVersion}');
        debugPrint('Current version: ${updateInfo.buildVersion}');
        debugPrint('Version number: ${updateInfo.buildVersionNo}');
        debugPrint('Build version: ${updateInfo.buildBuildVersion}');
        debugPrint('Download URL: ${updateInfo.downloadURL}');
        debugPrint('Build Key: ${updateInfo.buildKey}');
        debugPrint('Update description: ${updateInfo.buildUpdateDescription}');
        debugPrint('Need force update: ${updateInfo.needForceUpdate}');
        debugPrint('========================');
      } else {
        debugPrint('=== App Update Info ===');
        debugPrint('Failed to get update info or no update info available');
        debugPrint('========================');
      }

      if (updateInfo != null && updateInfo.buildHaveNewVersion) {
        // 有新版本
        setState(() {
          _hasNewVersion = true;
          _newVersion = updateInfo.buildVersion;
        });
        _showUpdateDialog(context, updateInfo);
      } else {
        // 没有新版本
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('当前已是最新版本')),
          );
        }
      }
    } catch (e) {
      debugPrint('=== App Update Error ===');
      debugPrint('Error checking for update: $e');
      debugPrint('========================');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('检查更新失败')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  /// 显示更新对话框
  void _showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('发现新版本 ${updateInfo.buildVersion}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (updateInfo.buildUpdateDescription.isNotEmpty)
                Text(updateInfo.buildUpdateDescription),
              const SizedBox(height: 16),
              Text('版本: ${updateInfo.buildVersion}'),
              Text('版本号: ${updateInfo.buildVersionNo}'),
              if (updateInfo.needForceUpdate)
                const Text(
                  '此更新为强制更新',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // 保存用户选择跳过该版本
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('skip_version', updateInfo.buildVersion);
              if (mounted) {
                Navigator.of(context).pop();
                setState(() {
                  _hasNewVersion = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已设置当前版本不再提示')),
                );
              }
            },
            child: const Text('当前版本不再提示'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('稍后更新'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 导航到WebView页面显示更新链接
              _showUpdateWebView(context, updateInfo);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  /// 显示更新页面WebView
  void _showUpdateWebView(BuildContext context, UpdateInfo updateInfo) {
    // 使用安装服务生成更新链接
    final installService = InstallService(
      apiKey: '65e9608ac0509189f3a36b3170ac3065',
    );
    
    String url;
    if (updateInfo.buildKey.isNotEmpty) {
      url = installService.generateInstallUrlByBuildKey(updateInfo.buildKey);
    } else {
      url = updateInfo.downloadURL;
    }
    
    // 导航到WebView页面
    context.push('/webview', extra: {'url': url, 'title': '应用更新'});
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
                
                // 重置更新状态
                setState(() {
                  _hasNewVersion = false;
                  _newVersion = null;
                });
                
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
                onPressed: _isCheckingUpdate ? null : () => _checkUpdate(context),
                icon: _isCheckingUpdate
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.system_update, size: 18),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('检查更新'),
                    if (_hasNewVersion) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.brightness_1,
                        color: Theme.of(context).colorScheme.error,
                        size: 12,
                      ),
                      if (_newVersion != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          'v$_newVersion',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ],
                ),
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