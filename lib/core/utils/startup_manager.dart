import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/services/update_service.dart';
import 'package:vision_x_flutter/services/install_service.dart';

/// 应用启动管理器
class StartupManager {
  /// 检查应用更新
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      debugPrint('=== Startup Update Check ===');
      
      // 初始化更新服务，使用您提供的实际密钥
      final updateService = UpdateService(
        apiKey: '65e9608ac0509189f3a36b3170ac3065', // 您提供的API Key
        appKey: '459d8d1f4abc2b79fca6d6a240bab74d', // 您提供的App Key
      );

      final updateInfo = await updateService.checkForUpdate();

      if (updateInfo != null && updateInfo.buildHaveNewVersion) {
        debugPrint('New version found, showing update dialog');
        // 检查用户是否选择了"当前版本不再提示"
        final prefs = await SharedPreferences.getInstance();
        final skipVersion = prefs.getString('skip_version');
        if (skipVersion != updateInfo.buildVersion) {
          // 有新版本且用户未选择跳过该版本，显示更新提示
          _showUpdateDialog(context, updateInfo);
        } else {
          debugPrint('User chose to skip this version: ${updateInfo.buildVersion}');
        }
      } else {
        debugPrint('No new version found or update info is null');
      }
    } catch (e) {
      debugPrint('Startup Update Check Error: $e');
      // 静默处理错误，不在启动时打扰用户
    }
  }

  /// 显示更新对话框
  static void _showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    // 检查组件是否还挂载
    if (!context.mounted) return;

    // 使用带Localizations的上下文显示对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('发现新版本 ${updateInfo.buildVersion}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('发现新版本，建议立即更新以获得更好的体验。'),
                const SizedBox(height: 16),
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
            if (!updateInfo.needForceUpdate)
              TextButton(
                onPressed: () async {
                  // 保存用户选择跳过该版本
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('skip_version', updateInfo.buildVersion);
                  Navigator.of(context).pop();
                },
                child: const Text('当前版本不再提示'),
              ),
            if (!updateInfo.needForceUpdate)
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
        );
      },
    );
  }

  /// 显示更新页面WebView
  static void _showUpdateWebView(BuildContext context, UpdateInfo updateInfo) {
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
}