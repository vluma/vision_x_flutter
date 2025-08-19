import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 选中的播放源
  Set<String> _selectedSources = <String>{};
  
  // 自定义API源
  final List<Map<String, String>> _customApis = [];
  
  // 控制自定义API表单的控制器
  final TextEditingController _apiNameController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _apiDetailController = TextEditingController();
  
  // 功能开关
  bool _yellowFilterEnabled = true;
  bool _adFilterEnabled = true;
  bool _doubanEnabled = true;
  
  // 显示自定义API表单
  bool _showCustomApiForm = false;
  
  // 主题选择
  int _selectedTheme = 0; // 0: 系统默认, 1: 浅色, 2: 深色
  
  // 加载保存的设置
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  // 释放资源
  @override
  void dispose() {
    _apiNameController.dispose();
    _apiUrlController.dispose();
    _apiDetailController.dispose();
    super.dispose();
  }
  
  // 加载保存的设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载选中的播放源
    final selectedSourcesString = prefs.getString('selected_sources') ?? '';
    if (selectedSourcesString.isNotEmpty) {
      setState(() {
        _selectedSources = selectedSourcesString.split(',').toSet();
      });
    } else {
      // 默认选中所有内置源
      setState(() {
        _selectedSources = ApiService.apiSites.keys.toSet();
      });
    }
    
    // 加载功能开关设置
    setState(() {
      _yellowFilterEnabled = prefs.getBool('yellow_filter_enabled') ?? true;
      _adFilterEnabled = prefs.getBool('ad_filter_enabled') ?? true;
      _doubanEnabled = prefs.getBool('douban_enabled') ?? true;
    });
    
    // 加载主题设置
    setState(() {
      _selectedTheme = prefs.getInt('selected_theme') ?? 0;
    });
    
    // 加载自定义API（简化处理）
    // 实际项目中应该从prefs中加载JSON格式的数据
  }
  
  // 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 保存选中的播放源
    await prefs.setString('selected_sources', _selectedSources.join(','));
    
    // 保存功能开关设置
    await prefs.setBool('yellow_filter_enabled', _yellowFilterEnabled);
    await prefs.setBool('ad_filter_enabled', _adFilterEnabled);
    await prefs.setBool('douban_enabled', _doubanEnabled);
    
    // 保存主题设置
    await prefs.setInt('selected_theme', _selectedTheme);
    
    // 保存自定义API（简化处理）
    // 实际项目中应该保存为JSON格式
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
    }
  }
  
  // 切换播放源选择
  void _toggleSource(String sourceKey) {
    setState(() {
      if (_selectedSources.contains(sourceKey)) {
        _selectedSources.remove(sourceKey);
      } else {
        _selectedSources.add(sourceKey);
      }
    });
  }
  
  // 全选或全不选API
  void _selectAllAPIs(bool selectAll, [bool normalOnly = false]) {
    setState(() {
      if (selectAll) {
        if (normalOnly) {
          // 这里应该只选择普通资源，但我们现在没有区分
          // 可以根据需要添加逻辑来区分普通资源和特殊资源
          _selectedSources = ApiService.apiSites.keys.toSet();
        } else {
          _selectedSources = ApiService.apiSites.keys.toSet();
        }
      } else {
        _selectedSources.clear();
      }
    });
  }
  
  // 添加自定义API
  void _addCustomApi() {
    if (_apiNameController.text.isNotEmpty && _apiUrlController.text.isNotEmpty) {
      final newApi = {
        'key': 'custom_${DateTime.now().millisecondsSinceEpoch}',
        'name': _apiNameController.text,
        'api': _apiUrlController.text,
        'detail': _apiDetailController.text,
      };
      
      setState(() {
        _customApis.add(newApi);
        _showCustomApiForm = false;
      });
      
      // 清空输入框
      _apiNameController.clear();
      _apiUrlController.clear();
      _apiDetailController.clear();
      
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('自定义API添加成功')),
      );
    }
  }
  
  // 删除自定义API
  void _removeCustomApi(int index) {
    setState(() {
      _customApis.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('自定义API已删除')),
    );
  }
  
  // 显示添加自定义API表单
  void _showAddCustomApiForm() {
    setState(() {
      _showCustomApiForm = true;
    });
  }
  
  // 取消添加自定义API
  void _cancelAddCustomApi() {
    setState(() {
      _showCustomApiForm = false;
      _apiNameController.clear();
      _apiUrlController.clear();
      _apiDetailController.clear();
    });
  }
  
  // 导入配置
  void _importConfig() {
    // 这里应该实现配置导入逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入配置功能待实现')),
    );
  }
  
  // 导出配置
  void _exportConfig() {
    // 这里应该实现配置导出逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出配置功能待实现')),
    );
  }
  
  // 清除本地存储
  void _clearLocalStorage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认清除'),
          content: const Text('确定要清除所有本地存储数据吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 实际清除逻辑
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).padding.bottom + 80.0, // 添加底部边距避免被导航栏遮挡
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 数据源设置部分
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '数据源设置',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 全选按钮
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _selectAllAPIs(true),
                            child: const Text(
                              '全选',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _selectAllAPIs(false),
                            child: const Text(
                              '全不选',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _selectAllAPIs(true, true),
                            child: const Text(
                              '全选普通资源',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // API复选框列表（只显示名称）
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView(
                          children: ApiService.apiSites.entries.map((entry) {
                            return CheckboxListTile(
                              activeColor: Theme.of(context).primaryColor,
                              title: Text(
                                entry.value['name']!,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: 14,
                                ),
                              ),
                              value: _selectedSources.contains(entry.key),
                              onChanged: (bool? value) {
                                _toggleSource(entry.key);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 已选API数量
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '已选API数量：${_selectedSources.length}',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            '', // 站点状态信息
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 自定义API部分
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '自定义API',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _showAddCustomApiForm,
                            icon: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 自定义API列表
                      if (_customApis.isNotEmpty)
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: _customApis.length,
                            itemBuilder: (context, index) {
                              final api = _customApis[index];
                              return ListTile(
                                title: Text(
                                  api['name']!,
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  api['api']!,
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeCustomApi(index),
                                ),
                              );
                            },
                          ),
                        ),
                      // 添加自定义API表单
                      if (_showCustomApiForm) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _apiNameController,
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                decoration: InputDecoration(
                                  labelText: 'API名称',
                                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _apiUrlController,
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                decoration: InputDecoration(
                                  labelText: 'https://abc.com',
                                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _apiDetailController,
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                decoration: InputDecoration(
                                  labelText: 'detail地址（可选）',
                                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 黄色资源站复选框
                              Row(
                                children: [
                                  Checkbox(
                                    activeColor: Theme.of(context).primaryColor,
                                    value: false, // 这里应该连接到一个状态变量
                                    onChanged: (bool? value) {
                                      // 实现黄色资源站选择逻辑
                                    },
                                  ),
                                  Text(
                                    '黄色资源站',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _addCustomApi,
                                    child: const Text(
                                      '添加',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _cancelAddCustomApi,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                    child: const Text(
                                      '取消',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 主题选择部分
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '主题设置',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('主题选择'),
                        trailing: DropdownButton<int>(
                          value: _selectedTheme,
                          items: const [
                            DropdownMenuItem(
                              value: 0,
                              child: Text('系统默认'),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text('浅色主题'),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text('深色主题'),
                            ),
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                _selectedTheme = value;
                              });
                              
                              // 保存主题选择到 SharedPreferences
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setInt('selected_theme', value);
                              });
                              
                              // 通知主应用更新主题
                              ThemeProvider.of(context).updateTheme(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 功能开关部分
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '功能开关',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 黄色内容过滤
                      Container(
                        padding: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Theme.of(context).dividerColor),
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
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '过滤"伦理片"等黄色内容',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              activeColor: Theme.of(context).primaryColor,
                              value: _yellowFilterEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _yellowFilterEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 分片广告过滤
                      Container(
                        padding: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Theme.of(context).dividerColor),
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
                                    '分片广告过滤',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '关闭可减少旧版浏览器卡顿',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              activeColor: Theme.of(context).primaryColor,
                              value: _adFilterEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _adFilterEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 豆瓣热门推荐
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '豆瓣热门推荐',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '首页显示豆瓣热门影视内容',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            activeColor: Theme.of(context).primaryColor,
                            value: _doubanEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                _doubanEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 一般功能部分
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '一般功能',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 导入配置
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ElevatedButton(
                          onPressed: _importConfig,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('导入配置'),
                        ),
                      ),
                      // 导出配置
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ElevatedButton(
                          onPressed: _exportConfig,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('导出配置'),
                        ),
                      ),
                      // 清除Cookie
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _clearLocalStorage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('清除Cookie'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 保存按钮
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('保存设置'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}