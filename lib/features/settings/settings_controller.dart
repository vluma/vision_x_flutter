import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_x_flutter/core/themes/theme_provider.dart';
import '../../services/api_service.dart';

class SettingsController extends ChangeNotifier {
  // 选中的播放源
  Set<String> _selectedSources = <String>{};

  // 自定义API源
  final List<Map<String, String>> _customApis = [];

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
  List<Map<String, String>> get customApis => _customApis;
  bool get yellowFilterEnabled => _yellowFilterEnabled;
  bool get adFilterEnabled => _adFilterEnabled;
  bool get adFilterByMetadata => _adFilterByMetadata;
  bool get adFilterByResolution => _adFilterByResolution;
  bool get showCustomApiForm => _showCustomApiForm;
  bool get isHiddenSource => _isHiddenSource;
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
  void selectAllAPIs(bool selectAll, BuildContext context, [bool normalOnly = false]) {
    if (selectAll) {
      if (normalOnly) {
        // 这里应该只选择普通资源，但我们现在没有区分
        _selectedSources = ApiService.apiSites.keys.toSet();
      } else {
        _selectedSources = ApiService.apiSites.keys.toSet();
      }
    } else {
      // 不允许全不选，至少保留一个源
      if (_selectedSources.length > 1) {
        _selectedSources.clear();
        // 默认选中第一个源
        _selectedSources.add(ApiService.apiSites.keys.first);
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
    _isHiddenSource = value;
    notifyListeners();
  }

  void addCustomApi(String name, String url, String detail, BuildContext context) {
    if (name.isNotEmpty && url.isNotEmpty) {
      final newApi = {
        'key': 'custom_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'api': url,
        'detail': detail,
        'isHidden': _isHiddenSource.toString(),
      };

      _customApis.add(newApi);
      _showCustomApiForm = false;
      _isHiddenSource = false;

      notifyListeners();

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('自定义API添加成功')),
      );
    }
  }

  void removeCustomApi(int index, BuildContext context) {
    _customApis.removeAt(index);
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('自定义API已删除')),
    );
  }

  // 保存设置
  Future<void> _saveSettingsAutomatically(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // 保存选中的播放源
    await prefs.setString('selected_sources', _selectedSources.join(','));

    // 保存功能开关设置
    await prefs.setBool('yellow_filter_enabled', _yellowFilterEnabled);
    await prefs.setBool('ad_filter_enabled', _adFilterEnabled);
    await prefs.setBool('ad_filter_by_metadata', _adFilterByMetadata);
    await prefs.setBool('ad_filter_by_resolution', _adFilterByResolution);

    // 保存主题设置
    await prefs.setInt('selected_theme', _selectedTheme);

    // 显示保存提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置已自动保存')),
    );
  }

  // 保存设置但不显示提示
  Future<void> _saveSettingsWithoutNotification() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存选中的播放源
    await prefs.setString('selected_sources', _selectedSources.join(','));

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