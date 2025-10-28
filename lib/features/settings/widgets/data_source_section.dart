import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已从剪贴板识别数据源，请确认后点击添加')),
              );
            }
            return;
          }
        }
      }
    }
    
    // 如果无法从剪贴板识别或用户手动输入，使用传统添加方式
    if (_apiNameController.text.trim().isEmpty || _apiUrlController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请填写API名称和URL')),
        );
      }
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

  /// 显示编辑API的弹窗
  Future<void> _showEditApiDialog(Map<String, dynamic> api, int index) async {
    final controller = Provider.of<SettingsController>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 创建编辑用的控制器
    final editNameController = TextEditingController(text: api['name'] ?? '');
    final editUrlController = TextEditingController(text: api['api'] ?? '');
    final editDetailController = TextEditingController(text: api['detail'] ?? '');
    bool isHidden = api['isHidden'] == 'true';
    bool isAdult = api['adult'] == true;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                '编辑数据源',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editNameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'API名称',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: editUrlController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'API地址',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: editDetailController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: '详情地址（可选）',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: isHidden,
                          onChanged: (bool? value) {
                            setState(() {
                              isHidden = value ?? false;
                            });
                          },
                        ),
                        Text(
                          '隐藏资源站',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: isAdult,
                          onChanged: (bool? value) {
                            setState(() {
                              isAdult = value ?? false;
                            });
                          },
                        ),
                        Text(
                          '成人内容',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    editNameController.dispose();
                    editUrlController.dispose();
                    editDetailController.dispose();
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
                    if (editNameController.text.trim().isNotEmpty && 
                        editUrlController.text.trim().isNotEmpty) {
                      controller.updateCustomApi(
                        index,
                        editNameController.text.trim(),
                        editUrlController.text.trim(),
                        editDetailController.text.trim(),
                        isHidden,
                        isAdult,
                        context,
                      );
                      Navigator.of(context).pop();
                      editNameController.dispose();
                      editUrlController.dispose();
                      editDetailController.dispose();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写API名称和地址')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 构建内置API项目
  Widget _buildBuiltInApiItem(MapEntry<String, Map<String, dynamic>> entry, bool isDark) {
    final controller = Provider.of<SettingsController>(context, listen: false);
    final isSelected = controller.selectedSources.contains(entry.key);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected 
            ? (isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05))
            : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected 
              ? (isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.2))
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
          width: 1,
        ),
      ),
      child: CheckboxListTile(
        activeColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Icon(
              Icons.cloud,
              size: 18,
              color: isDark ? Colors.blue[300] : Colors.blue[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.value['name']!,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.green.withOpacity(0.3) : Colors.green.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Text(
                '内置',
                style: TextStyle(
                  color: isDark ? Colors.green[300] : Colors.green[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        value: isSelected,
        onChanged: (bool? value) {
          controller.toggleSource(entry.key, context);
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// 构建自定义API项目
  Widget _buildCustomApiItem(Map<String, dynamic> api, int index, bool isDark) {
    final controller = Provider.of<SettingsController>(context, listen: false);
    final isSelected = controller.selectedSources.contains(api['key']);
    final isHidden = api['isHidden'] == 'true';
    final isAdult = api['adult'] == true;
    
    return Dismissible(
      key: Key('custom_api_${api['key']}'),
      direction: DismissDirection.horizontal,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              color: Colors.blue[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '编辑',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '删除',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.delete,
              color: Colors.red[600],
              size: 20,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 左滑编辑
          _showEditApiDialog(api, index);
          return false; // 不删除项目
        } else {
          // 右滑删除
          return await _showDeleteConfirmDialog(api, index);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // 确认删除
          controller.removeCustomApi(index, context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Colors.purple.withOpacity(0.1) : Colors.purple.withOpacity(0.05))
              : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? (isDark ? Colors.purple.withOpacity(0.3) : Colors.purple.withOpacity(0.2))
                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
            width: 1,
          ),
        ),
        child: CheckboxListTile(
          activeColor: Theme.of(context).primaryColor,
          title: Row(
            children: [
              Icon(
                Icons.settings,
                size: 18,
                color: isDark ? Colors.purple[300] : Colors.purple[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  api['name']!,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isHidden) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    '隐藏',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              if (isAdult) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    '成人',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.purple.withOpacity(0.2) : Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? Colors.purple.withOpacity(0.3) : Colors.purple.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '自定义',
                  style: TextStyle(
                    color: isDark ? Colors.purple[300] : Colors.purple[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          value: isSelected,
          onChanged: (bool? value) {
            controller.toggleSource(api['key']!, context);
          },
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  /// 显示批量删除对话框
  Future<void> _showBatchDeleteDialog() async {
    final controller = Provider.of<SettingsController>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customApis = controller.customApis;
    
    if (customApis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有自定义数据源可删除')),
      );
      return;
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                '批量删除数据源',
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
                      '选择要删除的自定义数据源：',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: customApis.length,
                        itemBuilder: (context, index) {
                          final api = customApis[index];
                          final isHidden = api['isHidden'] == 'true';
                          final isAdult = api['adult'] == true;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: CheckboxListTile(
                              activeColor: Theme.of(context).primaryColor,
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 16,
                                    color: isDark ? Colors.purple[300] : Colors.purple[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      api['name']!,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isHidden) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '隐藏',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (isAdult) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '成人',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              value: controller.batchDeleteSelected.contains(api['key']),
                              onChanged: (bool? value) {
                                controller.toggleBatchDeleteSelection(api['key']!);
                                setState(() {});
                              },
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.clearBatchDeleteSelection();
                            setState(() {});
                          },
                          child: Text(
                            '全不选',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            controller.selectAllForBatchDelete();
                            setState(() {});
                          },
                          child: Text(
                            '全选',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller.clearBatchDeleteSelection();
                  },
                  child: Text(
                    '取消',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: controller.batchDeleteSelected.isNotEmpty
                      ? () {
                          _confirmBatchDelete();
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('删除 (${controller.batchDeleteSelected.length})'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 确认批量删除
  void _confirmBatchDelete() {
    final controller = Provider.of<SettingsController>(context, listen: false);
    final selectedKeys = controller.batchDeleteSelected.toList();
    
    if (selectedKeys.isEmpty) return;
    
    // 按索引倒序删除，避免索引错乱
    final indicesToDelete = <int>[];
    for (int i = 0; i < controller.customApis.length; i++) {
      if (selectedKeys.contains(controller.customApis[i]['key'])) {
        indicesToDelete.add(i);
      }
    }
    
    // 倒序删除
    for (int i = indicesToDelete.length - 1; i >= 0; i--) {
      controller.removeCustomApi(indicesToDelete[i], context, false);
    }
    
    controller.clearBatchDeleteSelection();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已删除 ${selectedKeys.length} 个数据源')),
    );
  }

  /// 显示删除确认对话框
  Future<bool> _showDeleteConfirmDialog(Map<String, dynamic> api, int index) async {
    final controller = Provider.of<SettingsController>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '确认删除',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            '确定要删除数据源 "${api['name']}" 吗？',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
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
                controller.removeCustomApi(index, context);
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    ) ?? false;
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
        padding: const EdgeInsets.all(16),
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
                    // 从剪贴板添加数据源按钮
                    IconButton(
                      onPressed: () async {
                        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                        if (clipboardData != null && clipboardData.text != null) {
                          print('从剪贴板添加数据源: ${clipboardData.text}');
                          
                          // 尝试解析剪贴板内容
                          List<Map<String, dynamic>> parsedSources = controller.parseDataSourceString(clipboardData.text!);
                          
                          if (parsedSources.isNotEmpty) {
                            // 如果解析出数据源，使用批量添加
                            controller.addMultipleDataSources(clipboardData.text!, context);
                          } else {
                            // 尝试作为JSON配置导入
                            try {
                              final config = json.decode(clipboardData.text!);
                              await controller.importDataSourceConfig(config, context);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('剪贴板内容格式不支持，请使用标准数据源格式或配置JSON')),
                                );
                              }
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
                      tooltip: '从剪贴板添加数据源（支持多种格式）',
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('数据源配置已复制到剪贴板')),
                          );
                        }
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
                    // 批量删除按钮
                    if (controller.customApis.isNotEmpty)
                      IconButton(
                        onPressed: () => _showBatchDeleteDialog(),
                        icon: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.delete_sweep,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: '批量删除自定义数据源',
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
              // 数据源列表
              Container(
                constraints: const BoxConstraints(
                  minHeight: 200,
                  maxHeight: 400,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // 列表头部
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.api,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '数据源列表',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${controller.selectedSources.length} 已选',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 列表内容
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: ApiService.apiSites.length + controller.customApis.length,
                        itemBuilder: (context, index) {
                          // 显示内置API
                          if (index < ApiService.apiSites.length) {
                            final entry = ApiService.apiSites.entries.elementAt(index);
                            return _buildBuiltInApiItem(entry, isDark);
                          } else {
                            // 显示自定义API
                            final customIndex = index - ApiService.apiSites.length;
                            if (customIndex < controller.customApis.length) {
                              final api = controller.customApis[customIndex];
                              return _buildCustomApiItem(api, customIndex, isDark);
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        },
                      ),
                    ),
                  ],
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
