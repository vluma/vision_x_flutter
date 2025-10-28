import 'dart:convert';

/// 数据源解析器
/// 用于解析各种格式的数据源配置
class DataSourceParser {
  /// 新的数据源解析方法
  /// 1. 数据分割：处理大括号{}及其嵌套情况
  /// 2. 数据解析：检查是否包含http
  /// 3. 字段匹配：api, name, adult/isHidden, detail
  static List<Map<String, dynamic>> parseDataSourceAdvanced(String input) {
    print('开始高级解析数据源: $input');
    List<Map<String, dynamic>> results = [];
    
    // 首先尝试解析为JSON配置格式
    try {
      final jsonData = json.decode(input);
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('customApis')) {
        print('识别为JSON配置格式');
        List<dynamic> customApis = jsonData['customApis'];
        for (var api in customApis) {
          if (api is Map<String, dynamic>) {
            Map<String, dynamic> newSource = Map<String, dynamic>.from(api);
            // 确保有key字段
            if (!newSource.containsKey('key') || newSource['key'] == null) {
              newSource['key'] = 'custom_${DateTime.now().millisecondsSinceEpoch}_${results.length}';
            }
            // 确保有isHidden字段
            if (!newSource.containsKey('isHidden')) {
              newSource['isHidden'] = 'false';
            }
            results.add(newSource);
            print('添加JSON配置数据源: $newSource');
          }
        }
        print('JSON配置解析完成，共解析出 ${results.length} 个数据源');
        return results;
      }
    } catch (e) {
      print('不是JSON格式，继续尝试其他格式: $e');
    }
    
    // 步骤1: 数据分割，找到 "{ }"，如果里面嵌套"{ }" 就找到里面的，然后分割成数组
    List<String> objects = _extractObjects(input);
    print('提取的对象数组: $objects');
    
    // 如果没有找到对象，则将整个输入视为一个对象
    if (objects.isEmpty) {
      objects.add(input);
    }
    
    // 步骤2: 遍历每个对象进行解析
    for (int i = 0; i < objects.length; i++) {
      String obj = objects[i];
      print('处理第${i + 1}个对象: $obj');
      
      // 数据解析
      Map<String, dynamic> parsedData = _parseObjectFields(obj);
      
      // 判断是否包含 http 不包含跳过
      if (parsedData['api'] == null || 
          (parsedData['api'] is String && 
           !(parsedData['api'] as String).contains('http'))) {
        print('跳过不包含http的API: ${parsedData['api']}');
        continue;
      }
      
      // 确保必要字段存在
      if (parsedData['name'] == null || parsedData['name'].toString().isEmpty) {
        // 尝试从URL提取名称
        parsedData['name'] = _extractNameFromUrl(parsedData['api'].toString());
      }
      
      // 添加默认值
      parsedData['key'] = 'custom_${DateTime.now().millisecondsSinceEpoch}_$i';
      if (!parsedData.containsKey('adult')) {
        parsedData['adult'] = false;
      }
      if (!parsedData.containsKey('isHidden')) {
        parsedData['isHidden'] = 'false';
      }
      if (!parsedData.containsKey('detail')) {
        parsedData['detail'] = '';
      }
      
      results.add(parsedData);
      print('成功解析数据源: $parsedData');
    }
    
    print('高级解析完成，共解析出 ${results.length} 个数据源');
    return results;
  }
  
  /// 提取对象数组，处理嵌套大括号
  static List<String> _extractObjects(String input) {
    List<String> objects = [];
    int start = -1;
    int braceCount = 0;
    
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '{') {
        if (braceCount == 0) {
          start = i; // 记录最外层大括号的开始位置
        }
        braceCount++;
      } else if (input[i] == '}') {
        braceCount--;
        if (braceCount == 0 && start != -1) {
          // 找到一个完整的最外层对象
          objects.add(input.substring(start, i + 1));
          start = -1;
        }
      }
    }
    
    return objects;
  }
  
  /// 解析对象中的字段
  static Map<String, dynamic> _parseObjectFields(String obj) {
    Map<String, dynamic> result = {};
    
    // 匹配字段: api, name, adult/isHidden, detail
    // 匹配 api 字段
    RegExp apiRegex = RegExp(r"[']?api[']?\s*:\s*[']([^']*)[']");
    Match? apiMatch = apiRegex.firstMatch(obj);
    if (apiMatch != null && apiMatch.groupCount >= 1) {
      result['api'] = apiMatch.group(1);
      print('匹配到api字段: ${result['api']}');
    }
    
    // 匹配 name 字段
    RegExp nameRegex = RegExp(r"[']?name[']?\s*:\s*[']([^']*)[']");
    Match? nameMatch = nameRegex.firstMatch(obj);
    if (nameMatch != null && nameMatch.groupCount >= 1) {
      result['name'] = nameMatch.group(1);
      print('匹配到name字段: ${result['name']}');
    }
    
    // 匹配 adult 字段
    RegExp adultRegex = RegExp(r"[']?adult[']?\s*:\s*(true|false)");
    Match? adultMatch = adultRegex.firstMatch(obj);
    if (adultMatch != null && adultMatch.groupCount >= 1) {
      result['adult'] = adultMatch.group(1) == 'true';
      print('匹配到adult字段: ${result['adult']}');
    }
    
    // 匹配 isHidden 字段 (如果没有adult字段)
    if (!result.containsKey('adult')) {
      RegExp isHiddenRegex = RegExp(r"[']?isHidden[']?\s*:\s*(true|false)");
      Match? isHiddenMatch = isHiddenRegex.firstMatch(obj);
      if (isHiddenMatch != null && isHiddenMatch.groupCount >= 1) {
        result['isHidden'] = isHiddenMatch.group(1);
        print('匹配到isHidden字段: ${result['isHidden']}');
      }
    }
    
    // 匹配 detail 字段
    RegExp detailRegex = RegExp(r"[']?detail[']?\s*:\s*[']([^']*)[']");
    Match? detailMatch = detailRegex.firstMatch(obj);
    if (detailMatch != null && detailMatch.groupCount >= 1) {
      result['detail'] = detailMatch.group(1);
      print('匹配到detail字段: ${result['detail']}');
    }
    
    return result;
  }
  
  /// 从URL中提取名称
  static String _extractNameFromUrl(String url) {
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
}