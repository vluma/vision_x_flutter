import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/services/update_service.dart';
import 'package:vision_x_flutter/services/install_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/settings_card.dart';
import '../../providers/settings_provider.dart';

/// 通用功能设置区块
/// 
/// 用于设置应用的通用功能，如清除缓存、检查更新等
class GeneralFunctionsSection extends ConsumerStatefulWidget {
  /// 构造函数
  const GeneralFunctionsSection({super.key});

  @override
  ConsumerState<GeneralFunctionsSection> createState() =>
      _GeneralFunctionsSectionState();
}

class _GeneralFunctionsSectionState extends ConsumerState<GeneralFunctionsSection> {
  bool _isCheckingUpdate = false;
  bool _hasNewVersion = false;
  String? _newVersion;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsCard(
      title: '通用功能',
      content: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 检查更新
            ListTile(
              leading: Icon(
                Icons.system_update,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              title: const Text('检查更新'),
              subtitle: _hasNewVersion
                  ? Text('发现新版本: $_newVersion')
                  : const Text('点击检查应用更新'),
              trailing: _isCheckingUpdate
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _hasNewVersion ? Icons.brightness_1 : Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
              onTap: _isCheckingUpdate ? null : () => _checkUpdate(context),
            ),
            const Divider(height: 1),
            // 关于应用
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              title: const Text('关于应用'),
              subtitle: const Text('查看应用信息和版本'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white54 : Colors.black38,
              ),
              onTap: () => _showAbout(context),
            ),
            const Divider(height: 1),
            // 清除本地数据
            ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: isDark ? Colors.redAccent : Colors.red,
              ),
              title: const Text('清除本地数据'),
              subtitle: const Text('清除搜索历史、播放记录等本地数据'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white54 : Colors.black38,
              ),
              onTap: () => _clearLocalStorage(context),
            ),
          ],
        ),
      ),
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

      if (updateInfo != null && updateInfo.buildHaveNewVersion) {
        // 有新版本
        setState(() {
          _hasNewVersion = true;
          _newVersion = updateInfo.buildVersion;
        });
        _showUpdateDialog(context, updateInfo);
      } else {
        // 没有新版本
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('当前已是最新版本')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
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
              if (context.mounted) {
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
                final settingsNotifier = ref.read(settingsProvider.notifier);
                await settingsNotifier.loadSettings();

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
}