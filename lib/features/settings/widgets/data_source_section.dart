import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import '../../../services/api_service.dart';
import '../settings_controller.dart';

class DataSourceSection extends StatefulWidget {
  const DataSourceSection({super.key});

  @override
  State<DataSourceSection> createState() => _DataSourceSectionState();
}

class _DataSourceSectionState extends State<DataSourceSection> {
  final TextEditingController _apiNameController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _apiDetailController = TextEditingController();

  @override
  void dispose() {
    _apiNameController.dispose();
    _apiUrlController.dispose();
    _apiDetailController.dispose();
    super.dispose();
  }

  /// 从剪贴板添加数据源
  Future<void> _addFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null &&
        clipboardData.text != null &&
        clipboardData.text!.isNotEmpty) {
      final url = clipboardData.text!.trim();
      if (url.startsWith('http')) {
        // 从URL中提取域名作为名称
        String name = '未知源';
        try {
          final uri = Uri.parse(url);
          name = uri.host;
        } catch (e) {
          // 如果解析失败，使用默认名称
          name = '自定义源';
        }

        // 填充表单
        _apiNameController.text = name;
        _apiUrlController.text = url;

        // 显示表单弹窗
        _showAddApiDialog();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('剪贴板中的内容不是有效的URL')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('剪贴板为空或无有效内容')),
        );
      }
    }
  }

  /// 显示添加API的弹窗
  Future<void> _showAddApiDialog() async {
    final controller = Provider.of<SettingsController>(context, listen: false);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: Text(
            '添加数据源',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _apiNameController,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'API名称',
                      labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiUrlController,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'https://abc.com/api.php/provide/vod',
                      labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiDetailController,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'detail地址（可选）',
                      labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 从剪贴板粘贴按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final clipboardData =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        if (clipboardData != null &&
                            clipboardData.text != null &&
                            clipboardData.text!.isNotEmpty) {
                          final url = clipboardData.text!.trim();
                          if (url.startsWith('http')) {
                            // 从URL中提取域名作为名称
                            String name = '未知源';
                            try {
                              final uri = Uri.parse(url);
                              name = uri.host;
                            } catch (e) {
                              // 如果解析失败，使用默认名称
                              name = '自定义源';
                            }

                            setState(() {
                              _apiNameController.text = name;
                              _apiUrlController.text = url;
                            });
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('剪贴板中的内容不是有效的URL')),
                              );
                            }
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('剪贴板为空或无有效内容')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.paste, size: 16),
                      label: const Text('从剪贴板粘贴'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFEEEEEE),
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 隐藏资源站复选框
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: controller.isHiddenSource,
                        onChanged: (bool? value) {
                          controller.updateIsHiddenSource(value ?? false);
                          setState(() {}); // 更新弹窗内的状态
                        },
                      ),
                      Text(
                        '隐藏资源站',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _apiNameController.clear();
                _apiUrlController.clear();
                _apiDetailController.clear();
              },
              child: Text(
                '取消',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.addCustomApi(
                  _apiNameController.text,
                  _apiUrlController.text,
                  _apiDetailController.text,
                  context,
                );
                Navigator.of(context).pop();
                _apiNameController.clear();
                _apiUrlController.clear();
                _apiDetailController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SettingsController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasApis =
        ApiService.apiSites.isNotEmpty || controller.customApis.isNotEmpty;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '数据源设置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _apiNameController.clear();
                    _apiUrlController.clear();
                    _apiDetailController.clear();
                    _showAddApiDialog();
                  },
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: '添加数据源',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 如果没有数据源，显示提示信息
            if (!hasApis) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '请添加数据源',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _apiNameController.clear();
                          _apiUrlController.clear();
                          _apiDetailController.clear();
                          _showAddApiDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('添加数据源'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // API复选框列表
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFFAFAFA),
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
                  itemCount:
                      ApiService.apiSites.length + controller.customApis.length,
                  itemBuilder: (context, index) {
                    // 显示内置API
                    if (index < ApiService.apiSites.length) {
                      final entry =
                          ApiService.apiSites.entries.elementAt(index);
                      return CheckboxListTile(
                        activeColor: Theme.of(context).primaryColor,
                        title: Text(
                          entry.value['name']!,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        value: controller.selectedSources.contains(entry.key),
                        onChanged: (bool? value) {
                          controller.toggleSource(entry.key, context);
                        },
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      );
                    } else {
                      // 显示自定义API
                      final customIndex = index - ApiService.apiSites.length;
                      if (customIndex < controller.customApis.length) {
                        final api = controller.customApis[customIndex];
                        final isHidden = api['isHidden'] == 'true';
                        return CheckboxListTile(
                          activeColor: Theme.of(context).primaryColor,
                          title: Row(
                            children: [
                              Text(
                                api['name']!,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              if (isHidden) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Text(
                                    '隐藏',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          value:
                              controller.selectedSources.contains(api['key']),
                          onChanged: (bool? value) {
                            controller.toggleSource(api['key']!, context);
                          },
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              // 全选按钮和已选API数量
              Row(
                children: [
                  // 全选按钮
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            controller.selectAllAPIs(true, context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          '全选',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            controller.selectAllAPIs(false, context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF2D2D2D)
                              : const Color(0xFFEEEEEE),
                          foregroundColor:
                              isDark ? Colors.white70 : Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          '全不选',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            controller.selectAllAPIs(true, context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          '全选普通资源',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 已选API数量
                  Text(
                    '已选：${controller.selectedSources.length}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
