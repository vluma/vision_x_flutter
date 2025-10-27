import 'dart:convert';
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
  final TextEditingController _batchInputController = TextEditingController();

  @override
  void dispose() {
    _apiNameController.dispose();
    _apiUrlController.dispose();
    _apiDetailController.dispose();
    _batchInputController.dispose();
    super.dispose();
  }


  /// 显示批量添加数据源的弹窗
  Future<void> _showBatchAddDialog() async {
    final controller = Provider.of<SettingsController>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '批量添加数据源',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '支持以下格式：',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. 单个URL：\nhttp://caiji.dyttzyapi.com/api.php/provide/vod',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2. 注释格式：\n// api: \'https://hsckzy.vip\', name: \'黄色仓库\', adult: true, detail: \'https://hsckzy.vip\'',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3. 对象格式：\nwujin: { api: \'https://api.wujinapi.me/api.php/provide/vod\', name: \'无尽资源\' }',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    controller: _batchInputController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                    decoration: InputDecoration(
                      hintText: '请粘贴数据源配置...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 使用Wrap避免按钮溢出
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                        if (clipboardData != null && clipboardData.text != null) {
                          print('剪贴板内容: ${clipboardData.text}');
                          _batchInputController.text = clipboardData.text!;
                        } else {
                          print('剪贴板为空或无法访问');
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
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _batchInputController.clear();
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
                        if (_batchInputController.text.trim().isNotEmpty) {
                          controller.addMultipleDataSources(
                            _batchInputController.text,
                            context,
                          );
                          Navigator.of(context).pop();
                          _batchInputController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('添加'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 智能添加数据源处理
  Future<void> _handleSmartAdd(BuildContext context) async {
    final controller = Provider.of<SettingsController>(context, listen: false);
    
    // 如果URL字段为空，尝试从剪贴板识别
    if (_apiUrlController.text.trim().isEmpty) {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null && clipboardData.text!.isNotEmpty) {
        print('从剪贴板智能识别数据源: ${clipboardData.text}');
        
        // 尝试解析剪贴板内容
        List<Map<String, dynamic>> parsedSources = controller.parseDataSourceString(clipboardData.text!);
        
        if (parsedSources.isNotEmpty) {
          // 如果解析出多个数据源，使用批量添加
          if (parsedSources.length > 1) {
            Navigator.of(context).pop();
            controller.addMultipleDataSources(clipboardData.text!, context);
            _apiNameController.clear();
            _apiUrlController.clear();
            _apiDetailController.clear();
            return;
          } else if (parsedSources.length == 1) {
            // 如果解析出单个数据源，填充表单
            Map<String, dynamic> source = parsedSources.first;
            _apiNameController.text = source['name']?.toString() ?? '';
            _apiUrlController.text = source['api']?.toString() ?? '';
            _apiDetailController.text = source['detail']?.toString() ?? '';
            
            // 显示填充后的表单，让用户确认
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已从剪贴板识别数据源，请确认后点击添加')),
            );
            return;
          }
        }
      }
    }
    
    // 如果无法从剪贴板识别或用户手动输入，使用传统添加方式
    if (_apiNameController.text.trim().isEmpty || _apiUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写API名称和URL')),
      );
      return;
    }
    
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
              width: MediaQuery.of(context).size.width * 0.9,
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
                  // 智能添加提示
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: isDark ? Colors.blue[300] : Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '智能添加：如果URL为空，将自动从剪贴板识别数据源格式',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.blue[300] : Colors.blue[600],
                            ),
                          ),
                        ),
                      ],
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
                // 检查是否可以从剪贴板智能识别数据源
                _handleSmartAdd(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('智能添加'),
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
            // 标题和按钮布局 - 适配手机端
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '数据源设置',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // 使用Wrap避免按钮溢出
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // 从剪贴板直接添加按钮
                    IconButton(
                      onPressed: () async {
                        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                        if (clipboardData != null && clipboardData.text != null) {
                          print('从剪贴板直接添加数据源: ${clipboardData.text}');
                          controller.addMultipleDataSources(
                            clipboardData.text!,
                            context,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('剪贴板为空或无有效内容')),
                          );
                        }
                      },
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.content_paste,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: '从剪贴板直接添加数据源',
                    ),
                    // 批量添加按钮
                    IconButton(
                      onPressed: () {
                        _batchInputController.clear();
                        _showBatchAddDialog();
                      },
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_box,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: '批量添加数据源',
                    ),
                    // 单个添加按钮
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
                      tooltip: '添加单个数据源',
                    ),
                    // 导出配置按钮
                    IconButton(
                      onPressed: () async {
                        final config = controller.exportDataSourceConfig();
                        final configJson = json.encode(config);
                        await Clipboard.setData(ClipboardData(text: configJson));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('数据源配置已复制到剪贴板')),
                        );
                      },
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: '导出数据源配置',
                    ),
                    // 导入配置按钮
                    IconButton(
                      onPressed: () async {
                        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                        if (clipboardData != null && clipboardData.text != null) {
                          try {
                            final config = json.decode(clipboardData.text!);
                            await controller.importDataSourceConfig(config, context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('导入失败: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('剪贴板为空或无有效内容')),
                          );
                        }
                      },
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.upload,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: '导入数据源配置',
                    ),
                  ],
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
                        final isAdult = api['adult'] == true;
                        return CheckboxListTile(
                          activeColor: Theme.of(context).primaryColor,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  api['name']!,
                                  style: TextStyle(
                                    color:
                                        isDark ? Colors.white70 : Colors.black87,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                              if (isAdult) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Text(
                                    '成人',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 按钮组 - 使用Wrap避免溢出
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                              horizontal: 12, vertical: 6),
                        ),
                        child: const Text(
                          '全选',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
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
                              horizontal: 12, vertical: 6),
                        ),
                        child: const Text(
                          '全不选',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
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
                              horizontal: 12, vertical: 6),
                        ),
                        child: const Text(
                          '全选普通',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
