import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/core/themes/theme_provider.dart';
import '../../services/api_service.dart';

class SettingsController extends ChangeNotifier {
  // 选中的播放源
  Set<String> _selectedSources = <String>{};

  // 自定义API源
  final List<Map<String, dynamic>> _customApis = [];

  // 功能开关
  bool _yellowFilterEnabled = true;
  bool _adFilterEnabled = false;

  // 广告过滤子选项
  bool _adFilterByMetadata = true;
  bool _adFilterByResolution = true;

  // 显示自定义API表单
  bool _showCustomApiForm = false;

  // 自定义API是否为隐藏资源站
  bool _isHiddenSource = false;

  // 主题选择
  int _selectedTheme = 0;

  // Getters
  Set<String> get selectedSources => _selectedSources;
  List<Map<String, dynamic>> get customApis => _customApis;
  bool get yellowFilterEnabled => _yellowFilterEnabled;
  bool get adFilterEnabled => _adFilterEnabled;
  bool get adFilterByMetadata => _adFilterByMetadata;
  bool get adFilterByResolution => _adFilterByResolution;
  bool get showCustomApiForm => _showCustomApiForm;
  bool get isHiddenSource => _isHiddenSource; // 恢复原始名称
  int get selectedTheme => _selectedTheme;

  // 加载保存的设置
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载选中的播放源
    final selectedSourcesString = prefs.getString('selected_sources') ?? '';
    if (selectedSourcesString.isNotEmpty) {
      _selectedSources = selectedSourcesString.split(',').toSet();
    } else {
      // 默认选中所有内置源
      _selectedSources = ApiService.apiSites.keys.toSet();
    }

    // 加载自定义API
    final customApisString = prefs.getString('custom_apis') ?? '';
    if (customApisString.isNotEmpty) {
      try {
        final customApis = json.decode(customApisString) as List;
        _customApis.clear();
        for (var api in customApis) {
          if (api is Map<String, dynamic>) {
            // 验证API数据的完整性
            if (_isValidApiData(api)) {
              _customApis.add(api);
            }
          }
        }
        // 如果清理了无效数据，重新保存
        if (_customApis.length != customApis.length) {
          _saveSettingsWithoutNotification();
        }
        
        // 清理无效的选中数据源
        _cleanInvalidSelectedSources();
      } catch (e) {
        // 忽略解析错误，使用空列表
        _customApis.clear();
      }
    }

    // 加载功能开关设置
    _yellowFilterEnabled = prefs.getBool('yellow_filter_enabled') ?? true;
    _adFilterEnabled = prefs.getBool('ad_filter_enabled') ?? false;

    // 加载广告过滤子选项
    _adFilterByMetadata = prefs.getBool('ad_filter_by_metadata') ?? true;
    _adFilterByResolution = prefs.getBool('ad_filter_by_resolution') ?? true;

    // 加载主题设置
    _selectedTheme = prefs.getInt('selected_theme') ?? 0;

    notifyListeners();
  }

  // 切换播放源选择
  void toggleSource(String sourceKey, BuildContext context) {
    if (_selectedSources.contains(sourceKey)) {
      // 检查是否至少保留一个源
      if (_selectedSources.length > 1) {
        _selectedSources.remove(sourceKey);
      } else {
        // 如果只剩一个源，不允许取消选择
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('至少需要选择一个数据源')),
        );
        return;
      }
    } else {
      _selectedSources.add(sourceKey);
    }

    notifyListeners();
    _saveSettingsAutomatically(context);
  }

  // 全选或全不选API
  void selectAllAPIs(bool selectAll, BuildContext context,
      [bool normalOnly = false]) {
    if (selectAll) {
      if (normalOnly) {
        // 这里应该只选择普通资源，但我们现在没有区分
        _selectedSources = ApiService.apiSites.keys.toSet();
      } else {
        // 合并内置API和自定义API的key
        _selectedSources = ApiService.apiSites.keys.toSet();
        for (var api in _customApis) {
          if (api['key'] != null) {
            _selectedSources.add(api['key']!);
          }
        }
      }
    } else {
      // 不允许全不选，至少保留一个源
      if (_selectedSources.length > 1) {
        _selectedSources.clear();
        // 默认选中第一个源
        if (ApiService.apiSites.isNotEmpty) {
          _selectedSources.add(ApiService.apiSites.keys.first);
        } else if (_customApis.isNotEmpty && _customApis.first['key'] != null) {
          _selectedSources.add(_customApis.first['key']!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('至少需要选择一个数据源')),
        );
        return;
      }
    }

    notifyListeners();
    _saveSettingsWithoutNotification();
  }

  // 更新功能开关
  void updateYellowFilter(bool value) {
    _yellowFilterEnabled = value;
    notifyListeners();
    _saveSettingsWithoutNotification();
  }

  void updateAdFilter(bool value) {
    _adFilterEnabled = value;
    notifyListeners();
    _saveSettingsWithoutNotification();
  }

  void updateAdFilterByMetadata(bool value) {
    _adFilterByMetadata = value;
    notifyListeners();
    _saveSettingsWithoutNotification();
  }

  void updateAdFilterByResolution(bool value) {
    _adFilterByResolution = value;
    notifyListeners();
    _saveSettingsWithoutNotification();
  }

  // 主题设置
  void updateTheme(int value, BuildContext context) {
    _selectedTheme = value;

    // 保存主题选择到 SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('selected_theme', value);
    });

    // 通知主应用更新主题
    final themeProvider = ThemeProvider.of(context);
    themeProvider.updateTheme(value);

    notifyListeners();
  }

  // 自定义API管理
  void showAddCustomApiForm() {
    _showCustomApiForm = true;
    _isHiddenSource = false;
    notifyListeners();
  }

  void cancelAddCustomApi() {
    _showCustomApiForm = false;
    _isHiddenSource = false;
    notifyListeners();
  }

  void updateIsHiddenSource(bool value) {
    // 恢复原始方法名
    _isHiddenSource = value;
    notifyListeners();
  }

  void addCustomApi(
      String name, String url, String detail, BuildContext context) {
    if (name.isNotEmpty && url.isNotEmpty) {
      final newApi = {
        'key': 'custom_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'api': url,
        'detail': detail,
        'adult': false, // 默认为非成人内容
        'isHidden': _isHiddenSource.toString(), // 使用原始字段名
      };

      // 检查是否重复
      if (_isDuplicateSource(newApi)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('该数据源已存在，请勿重复添加')),
        );
        return;
      }

      _customApis.add(newApi);

      // 自动选择新添加的API
      _selectedSources.add(newApi['key'] as String);

      _showCustomApiForm = false;
      _isHiddenSource = false;

      notifyListeners();
      _saveSettingsWithoutNotification();

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('自定义API添加成功')),
      );
    }
  }

  /// 解析数据源字符串，支持多种格式
  /// 支持格式：
  /// 1. 单个URL: http://caiji.dyttzyapi.com/api.php/provide/vod
  /// 2. 注释格式: // api: 'https://hsckzy.vip', name: '黄色仓库', adult: true, detail: 'https://hsckzy.vip'
  /// 3. 对象格式: wujin: { api: 'https://api.wujinapi.me/api.php/provide/vod', name: '无尽资源' }
  /// 4. 多行对象格式: 'mozhua': { 'api': '...', 'name': '...' }
  List<Map<String, dynamic>> parseDataSourceString(String input) {
    print('开始解析数据源字符串: $input');
    List<Map<String, dynamic>> results = [];
    
    // 按行分割
    List<String> lines = input.split('\n');
    print('分割后共 ${lines.length} 行');
    
    // 先处理多行对象格式
    String processedInput = _processMultilineObjects(input);
    print('处理多行对象后的内容: $processedInput');
    
    // 重新按行分割处理后的内容
    List<String> processedLines = processedInput.split('\n');
    print('处理后的行数: ${processedLines.length}');
    
    for (int i = 0; i < processedLines.length; i++) {
      String line = processedLines[i].trim();
      print('处理第 ${i + 1} 行: $line');
      
      if (line.isEmpty) {
        print('跳过空行');
        continue;
      }
      
      // 跳过纯注释行（但不跳过对象格式）
      if (line.startsWith('//') && !line.contains('api:') && !line.contains('name:')) {
        print('跳过纯注释行');
        continue;
      }
      if (line.startsWith('/*') || line.startsWith('*')) {
        print('跳过注释行');
        continue;
      }
      
      // 格式1: 单个URL
      if (line.startsWith('http://') || line.startsWith('https://')) {
        print('识别为单个URL格式');
        String name = _extractNameFromUrl(line);
        Map<String, dynamic> newSource = {
          'key': 'custom_${DateTime.now().millisecondsSinceEpoch}_${results.length}',
          'name': name,
          'api': line,
          'detail': '',
          'adult': false,
          'isHidden': 'false',
        };
        results.add(newSource);
        print('添加URL数据源: $newSource');
        continue;
      }
      
      // 格式2: 注释格式解析（包含api:和name:的行）
      if (line.contains("api:") && line.contains("name:")) {
        print('识别为注释格式');
        try {
          Map<String, dynamic> parsed = _parseCommentFormat(line);
          print('注释格式解析结果: $parsed');
          if (parsed.isNotEmpty) {
            parsed['key'] = 'custom_${DateTime.now().millisecondsSinceEpoch}_${results.length}';
            if (!parsed.containsKey('isHidden')) {
              parsed['isHidden'] = 'false';
            }
            results.add(parsed);
            print('添加注释格式数据源: $parsed');
          }
        } catch (e) {
          print('注释格式解析错误: $e');
        }
        continue;
      }
      
      // 格式3: 对象格式解析
      if (line.contains(':') && line.contains('{') && line.contains('}')) {
        print('识别为对象格式');
        try {
          Map<String, dynamic> parsed = _parseObjectFormat(line);
          print('对象格式解析结果: $parsed');
          if (parsed.isNotEmpty) {
            parsed['key'] = 'custom_${DateTime.now().millisecondsSinceEpoch}_${results.length}';
            if (!parsed.containsKey('isHidden')) {
              parsed['isHidden'] = 'false';
            }
            results.add(parsed);
            print('添加对象格式数据源: $parsed');
          }
        } catch (e) {
          print('对象格式解析错误: $e');
        }
        continue;
      }
      
      print('未识别的格式，跳过此行');
    }
    
    print('解析完成，共解析出 ${results.length} 个数据源');
    return results;
  }
  
  /// 处理多行对象格式，将其合并为单行
  String _processMultilineObjects(String input) {
    List<String> lines = input.split('\n');
    List<String> result = [];
    String currentObject = '';
    int braceCount = 0;
    bool inObject = false;
    
    for (String line in lines) {
      String trimmedLine = line.trim();
      
      // 检查是否开始一个对象
      if (trimmedLine.contains(':') && trimmedLine.contains('{')) {
        inObject = true;
        currentObject = trimmedLine;
        braceCount = _countBraces(trimmedLine);
        continue;
      }
      
      // 如果在对象内部
      if (inObject) {
        currentObject += ' ' + trimmedLine;
        braceCount += _countBraces(trimmedLine);
        
        // 如果大括号平衡，对象结束
        if (braceCount == 0) {
          result.add(currentObject);
          currentObject = '';
          inObject = false;
        }
      } else {
        // 不在对象内部，直接添加行
        result.add(trimmedLine);
      }
    }
    
    // 如果还有未完成的对象，添加它
    if (inObject && currentObject.isNotEmpty) {
      result.add(currentObject);
    }
    
    return result.join('\n');
  }
  
  /// 计算字符串中大括号的平衡情况
  int _countBraces(String line) {
    int count = 0;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == '{') {
        count++;
      } else if (line[i] == '}') {
        count--;
      }
    }
    return count;
  }
  
  /// 从URL中提取名称
  String _extractNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      String host = uri.host;
      // 移除www前缀
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }
      // 提取主域名
      List<String> parts = host.split('.');
      if (parts.length >= 2) {
        return parts[parts.length - 2];
      }
      return host;
    } catch (e) {
      return '未知源';
    }
  }
  
  /// 解析注释格式: // api: 'https://hsckzy.vip', name: '黄色仓库', adult: true, detail: 'https://hsckzy.vip'
  /// 或者: 'hwba': {'api': 'https://cjhwba.com/api.php/provide/vod', 'name': '华为吧资源'},
  Map<String, dynamic> _parseCommentFormat(String line) {
    print('解析注释格式: $line');
    Map<String, dynamic> result = {};
    
    // 移除注释符号（如果存在）
    if (line.startsWith('//')) {
      line = line.replaceFirst(RegExp(r'^\s*//\s*'), '');
      print('移除注释符号后: $line');
    }
    
    // 检查是否是对象格式（包含大括号）
    if (line.contains('{') && line.contains('}')) {
      print('检测到对象格式，使用对象解析方法');
      return _parseObjectFormat(line);
    }
    
    // 使用简单的字符串分割方法
    List<String> pairs = line.split(',');
    print('分割后的键值对: $pairs');
    
    for (int i = 0; i < pairs.length; i++) {
      String pair = pairs[i].trim();
      print('处理第 ${i + 1} 个键值对: $pair');
      
      int colonIndex = pair.indexOf(':');
      if (colonIndex > 0) {
        String key = pair.substring(0, colonIndex).trim();
        String value = pair.substring(colonIndex + 1).trim();
        print('键: $key, 值: $value');
        
        // 移除引号
        if (value.startsWith('\'') && value.endsWith('\'')) {
          value = value.substring(1, value.length - 1);
          print('移除单引号后: $value');
        } else if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
          print('移除双引号后: $value');
        }
        
        if (key == 'api') {
          result['api'] = value;
          print('设置api: $value');
        } else if (key == 'name') {
          result['name'] = value;
          print('设置name: $value');
        } else if (key == 'detail') {
          result['detail'] = value;
          print('设置detail: $value');
        } else if (key == 'adult') {
          result['adult'] = value.toLowerCase() == 'true';
          print('设置adult: ${result['adult']}');
        }
      } else {
        print('跳过无效键值对: $pair');
      }
    }
    
    print('注释格式解析结果: $result');
    return result;
  }
  
  /// 解析对象格式: wujin: { api: 'https://api.wujinapi.me/api.php/provide/vod', name: '无尽资源' }
  Map<String, dynamic> _parseObjectFormat(String line) {
    print('解析对象格式: $line');
    Map<String, dynamic> result = {};
    
    // 提取键名
    int colonIndex = line.indexOf(':');
    if (colonIndex == -1) {
      print('未找到冒号，返回空结果');
      return result;
    }
    
    String content = line.substring(colonIndex + 1).trim();
    print('提取内容部分: $content');
    
    // 移除大括号
    if (content.startsWith('{') && content.endsWith('}')) {
      content = content.substring(1, content.length - 1);
      print('移除大括号后: $content');
    }
    
    // 解析键值对 - 使用更智能的分割方法
    List<String> pairs = [];
    int braceCount = 0;
    int start = 0;
    
    for (int i = 0; i < content.length; i++) {
      if (content[i] == '{') {
        braceCount++;
      } else if (content[i] == '}') {
        braceCount--;
      } else if (content[i] == ',' && braceCount == 0) {
        pairs.add(content.substring(start, i).trim());
        start = i + 1;
      }
    }
    // 添加最后一个元素
    if (start < content.length) {
      pairs.add(content.substring(start).trim());
    }
    
    // 如果只有一个键值对且包含多个字段，尝试进一步分割
    if (pairs.length == 1 && pairs[0].contains("'api'") && pairs[0].contains("'name'")) {
      print('检测到复合键值对，尝试进一步分割');
      String complexPair = pairs[0];
      pairs.clear();
      
      // 使用正则表达式分割复合键值对
      RegExp pairRegex = RegExp(r"'(\w+)':\s*'([^']*)'");
      Iterable<RegExpMatch> matches = pairRegex.allMatches(complexPair);
      
      for (RegExpMatch match in matches) {
        String key = match.group(1) ?? '';
        String value = match.group(2) ?? '';
        pairs.add("'$key': '$value'");
        print('分割出键值对: \'$key\': \'$value\'');
      }
    }
    
    // 如果仍然只有一个键值对，尝试更宽松的分割
    if (pairs.length == 1 && pairs[0].contains("api") && pairs[0].contains("name")) {
      print('尝试更宽松的分割方法');
      String complexPair = pairs[0];
      pairs.clear();
      
      // 移除大括号
      if (complexPair.startsWith('{') && complexPair.endsWith('}')) {
        complexPair = complexPair.substring(1, complexPair.length - 1);
      }
      
      // 按逗号分割，但要注意引号内的逗号
      List<String> tempPairs = [];
      int start = 0;
      bool inQuotes = false;
      
      for (int i = 0; i < complexPair.length; i++) {
        if (complexPair[i] == '\'') {
          inQuotes = !inQuotes;
        } else if (complexPair[i] == ',' && !inQuotes) {
          tempPairs.add(complexPair.substring(start, i).trim());
          start = i + 1;
        }
      }
      if (start < complexPair.length) {
        tempPairs.add(complexPair.substring(start).trim());
      }
      
      pairs.addAll(tempPairs);
      print('宽松分割后的键值对: $pairs');
    }
    
    print('分割后的键值对: $pairs');
    
    for (int i = 0; i < pairs.length; i++) {
      String pair = pairs[i].trim();
      print('处理第 ${i + 1} 个键值对: $pair');
      
      // 找到第一个冒号的位置
      int colonIndex = -1;
      for (int j = 0; j < pair.length; j++) {
        if (pair[j] == ':') {
          colonIndex = j;
          break;
        }
      }
      
      if (colonIndex > 0) {
        String key = pair.substring(0, colonIndex).trim();
        String value = pair.substring(colonIndex + 1).trim();
        print('键: $key, 值: $value');
        
        // 移除键的引号
        if (key.startsWith('\'') && key.endsWith('\'')) {
          key = key.substring(1, key.length - 1);
          print('移除键的单引号后: $key');
        } else if (key.startsWith('"') && key.endsWith('"')) {
          key = key.substring(1, key.length - 1);
          print('移除键的双引号后: $key');
        }
        
        // 移除值的引号
        if (value.startsWith('\'') && value.endsWith('\'')) {
          value = value.substring(1, value.length - 1);
          print('移除值的单引号后: $value');
        } else if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
          print('移除值的双引号后: $value');
        }
        
        if (key == 'api') {
          result['api'] = value;
          print('设置api: $value');
        } else if (key == 'name') {
          result['name'] = value;
          print('设置name: $value');
        } else if (key == 'detail') {
          result['detail'] = value;
          print('设置detail: $value');
        } else if (key == 'adult') {
          result['adult'] = value.toLowerCase() == 'true';
          print('设置adult: ${result['adult']}');
        }
      } else {
        print('跳过无效键值对: $pair');
      }
    }
    
    print('对象格式解析结果: $result');
    return result;
  }
  
  /// 批量添加数据源
  void addMultipleDataSources(String input, BuildContext context) {
    print('开始批量添加数据源，输入内容: $input');
    
    try {
      List<Map<String, dynamic>> parsedSources = parseDataSourceString(input);
      print('解析结果: $parsedSources');
      
      if (parsedSources.isEmpty) {
        print('未找到有效的数据源格式');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未找到有效的数据源格式')),
        );
        return;
      }
      
      // 去重处理
      List<Map<String, dynamic>> uniqueSources = _removeDuplicateSources(parsedSources);
      print('去重后剩余 ${uniqueSources.length} 个数据源');
      
      int addedCount = 0;
      int duplicateCount = 0;
      
      for (Map<String, dynamic> source in uniqueSources) {
        print('处理数据源: $source');
        if (source['api'] != null && source['name'] != null) {
          if (_isDuplicateSource(source)) {
            duplicateCount++;
            print('跳过重复数据源: ${source['name']} (${source['api']})');
            continue;
          }
          
          _customApis.add(source);
          _selectedSources.add(source['key'] as String);
          addedCount++;
          print('成功添加数据源: ${source['name']}');
        } else {
          print('跳过无效数据源: $source');
        }
      }
      
      print('批量添加完成，共添加 $addedCount 个数据源，跳过 $duplicateCount 个重复数据源');
      notifyListeners();
      _saveSettingsWithoutNotification();
      
      String message = '成功添加 $addedCount 个数据源';
      if (duplicateCount > 0) {
        message += '，跳过 $duplicateCount 个重复数据源';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e, stackTrace) {
      print('批量添加数据源时发生错误: $e');
      print('错误堆栈: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加数据源时发生错误: $e')),
      );
    }
  }
  
  /// 移除重复的数据源（基于API URL）
  List<Map<String, dynamic>> _removeDuplicateSources(List<Map<String, dynamic>> sources) {
    List<Map<String, dynamic>> uniqueSources = [];
    Set<String> seenUrls = {};
    
    for (Map<String, dynamic> source in sources) {
      String apiUrl = source['api']?.toString() ?? '';
      if (apiUrl.isNotEmpty && !seenUrls.contains(apiUrl)) {
        seenUrls.add(apiUrl);
        uniqueSources.add(source);
        print('保留数据源: ${source['name']} (${apiUrl})');
      } else {
        print('移除重复数据源: ${source['name']} (${apiUrl})');
      }
    }
    
    return uniqueSources;
  }
  
  // 验证API数据的完整性
  bool _isValidApiData(Map<String, dynamic> api) {
    return api.containsKey('key') && 
           api.containsKey('name') && 
           api.containsKey('api') &&
           api['key'] != null &&
           api['name'] != null &&
           api['api'] != null &&
           api['key'].toString().isNotEmpty &&
           api['name'].toString().isNotEmpty &&
           api['api'].toString().isNotEmpty;
  }

  // 清理无效的选中数据源
  void _cleanInvalidSelectedSources() {
    Set<String> validSources = <String>{};
    
    // 检查内置API
    for (String key in ApiService.apiSites.keys) {
      if (_selectedSources.contains(key)) {
        validSources.add(key);
      }
    }
    
    // 检查自定义API
    for (var api in _customApis) {
      if (api['key'] != null && _selectedSources.contains(api['key'])) {
        validSources.add(api['key']!);
      }
    }
    
    // 如果清理后没有选中任何源，默认选中第一个可用的源
    if (validSources.isEmpty) {
      if (ApiService.apiSites.isNotEmpty) {
        validSources.add(ApiService.apiSites.keys.first);
      } else if (_customApis.isNotEmpty && _customApis.first['key'] != null) {
        validSources.add(_customApis.first['key']!);
      }
    }
    
    _selectedSources = validSources;
  }

  // 检查是否为重复数据源
  bool _isDuplicateSource(Map<String, dynamic> newSource) {
    String newApiUrl = newSource['api']?.toString() ?? '';
    if (newApiUrl.isEmpty) return false;
    
    // 检查内置API中是否有重复
    for (var entry in ApiService.apiSites.entries) {
      if (entry.value['api'] == newApiUrl) {
        print('与内置API重复: ${entry.value['name']} (${newApiUrl})');
        return true;
      }
    }
    
    // 检查自定义API中是否有重复
    for (Map<String, dynamic> existingSource in _customApis) {
      String existingApiUrl = existingSource['api']?.toString() ?? '';
      if (existingApiUrl == newApiUrl) {
        print('与自定义API重复: ${existingSource['name']} (${newApiUrl})');
        return true;
      }
    }
    
    return false;
  }

  void removeCustomApi(int index, BuildContext context) {
    final removedApi = _customApis[index];
    _customApis.removeAt(index);

    // 如果删除的API被选中，需要从选中列表中移除
    if (removedApi['key'] != null) {
      _selectedSources.remove(removedApi['key']);

      // 确保至少有一个源被选中
      if (_selectedSources.isEmpty) {
        if (ApiService.apiSites.isNotEmpty) {
          _selectedSources.add(ApiService.apiSites.keys.first);
        } else if (_customApis.isNotEmpty && _customApis.first['key'] != null) {
          _selectedSources.add(_customApis.first['key']!);
        }
      }
    }

    notifyListeners();
    _saveSettingsWithoutNotification();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('自定义API已删除')),
    );
  }

  // 保存设置
  Future<void> _saveSettingsAutomatically(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // 保存选中的播放源
    await prefs.setString('selected_sources', _selectedSources.join(','));

    // 保存自定义API
    await prefs.setString('custom_apis', json.encode(_customApis));

    // 保存功能开关设置
    await prefs.setBool('yellow_filter_enabled', _yellowFilterEnabled);
    await prefs.setBool('ad_filter_enabled', _adFilterEnabled);
    await prefs.setBool('ad_filter_by_metadata', _adFilterByMetadata);
    await prefs.setBool('ad_filter_by_resolution', _adFilterByResolution);

    // 保存主题设置
    await prefs.setInt('selected_theme', _selectedTheme);

    // 显示保存提示 - 检查context是否仍然有效
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已自动保存')),
      );
    }
  }

  // 导出数据源配置
  Map<String, dynamic> exportDataSourceConfig() {
    return {
      'selectedSources': _selectedSources.toList(),
      'customApis': _customApis,
      'exportTime': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  // 导入数据源配置
  Future<bool> importDataSourceConfig(Map<String, dynamic> config, BuildContext context) async {
    try {
      // 验证配置格式
      if (!config.containsKey('customApis') || !config.containsKey('selectedSources')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('配置文件格式无效')),
        );
        return false;
      }

      // 验证自定义API数据
      List<Map<String, dynamic>> importedApis = [];
      if (config['customApis'] is List) {
        for (var api in config['customApis']) {
          if (api is Map<String, dynamic> && _isValidApiData(api)) {
            importedApis.add(api);
          }
        }
      }

      // 验证选中的数据源
      Set<String> importedSources = <String>{};
      if (config['selectedSources'] is List) {
        for (var source in config['selectedSources']) {
          if (source is String && source.isNotEmpty) {
            importedSources.add(source);
          }
        }
      }

      // 清理无效的选中数据源
      Set<String> validSources = <String>{};
      for (String key in ApiService.apiSites.keys) {
        if (importedSources.contains(key)) {
          validSources.add(key);
        }
      }
      for (var api in importedApis) {
        if (api['key'] != null && importedSources.contains(api['key'])) {
          validSources.add(api['key']!);
        }
      }

      // 如果清理后没有选中任何源，默认选中第一个可用的源
      if (validSources.isEmpty) {
        if (ApiService.apiSites.isNotEmpty) {
          validSources.add(ApiService.apiSites.keys.first);
        } else if (importedApis.isNotEmpty && importedApis.first['key'] != null) {
          validSources.add(importedApis.first['key']!);
        }
      }

      // 应用导入的配置
      _customApis.clear();
      _customApis.addAll(importedApis);
      _selectedSources = validSources;

      notifyListeners();
      _saveSettingsWithoutNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功导入 ${importedApis.length} 个自定义数据源')),
      );

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入配置失败: $e')),
      );
      return false;
    }
  }

  // 保存设置但不显示提示
  Future<void> _saveSettingsWithoutNotification() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存选中的播放源
    await prefs.setString('selected_sources', _selectedSources.join(','));

    // 保存自定义API
    await prefs.setString('custom_apis', json.encode(_customApis));

    // 保存功能开关设置
    await prefs.setBool('yellow_filter_enabled', _yellowFilterEnabled);
    await prefs.setBool('ad_filter_enabled', _adFilterEnabled);

    // 保存广告过滤子选项
    await prefs.setBool('ad_filter_by_metadata', _adFilterByMetadata);
    await prefs.setBool('ad_filter_by_resolution', _adFilterByResolution);

    // 保存主题设置
    await prefs.setInt('selected_theme', _selectedTheme);
  }
}
