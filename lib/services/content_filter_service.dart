import 'package:shared_preferences/shared_preferences.dart';

class ContentFilterService {
  // 黄色内容关键词列表
  static const List<String> _yellowContentKeywords = [
    '伦理',
    '伦理片',
    '伦理电影',
    '伦理剧',
    '伦理电视剧',
    '伦理视频',
    '伦理内容',
    '黄色',
    '黄色内容',
    '黄色视频',
    '黄色电影',
    '黄色剧',
    '色情',
    '色情内容',
    '色情视频',
    '色情电影',
    '色情剧',
    '成人',
    '成人内容',
    '成人视频',
    '成人电影',
    '成人剧',
    '限制级',
    '限制级内容',
    '限制级视频',
    '限制级电影',
    '限制级剧',
    'R级',
    'R级内容',
    'R级视频',
    'R级电影',
    'R级剧',
    '18+',
    '18+内容',
    '18+视频',
    '18+电影',
    '18+剧',
    'AV',
    'AV电影',
    'AV视频',
    'AV内容',
    '三级',
    '三级片',
    '三级电影',
    '三级视频',
    '三级内容',
    '情色',
    '情色内容',
    '情色视频',
    '情色电影',
    '情色剧',
    '性',
    '性内容',
    '性视频',
    '性电影',
    '性剧',
    '性爱',
    '性爱内容',
    '性爱视频',
    '性爱电影',
    '性爱剧',
    '性交',
    '性交内容',
    '性交视频',
    '性交电影',
    '性交剧',
    '做爱',
    '做爱内容',
    '做爱视频',
    '做爱电影',
    '做爱剧',
    '性行为',
    '性行为内容',
    '性行为视频',
    '性行为电影',
    '性行为剧',
    '性关系',
    '性关系内容',
    '性关系视频',
    '性关系电影',
    '性关系剧',
    '性接触',
    '性接触内容',
    '性接触视频',
    '性接触电影',
    '性接触剧',
    '性服务',
    '性服务内容',
    '性服务视频',
    '性服务电影',
    '性服务剧',
    '性交易',
    '性交易内容',
    '性交易视频',
    '性交易电影',
    '性交易剧',
    '性买卖',
    '性买卖内容',
    '性买卖视频',
    '性买卖电影',
    '性买卖剧',
    '性工作',
    '性工作内容',
    '性工作视频',
    '性工作电影',
    '性工作剧',
    '性工作者',
    '性工作者内容',
    '性工作者视频',
    '性工作者电影',
    '性工作者剧',
    '性产业',
    '性产业内容',
    '性产业视频',
    '性产业电影',
    '性产业剧',
    '性商业',
    '性商业内容',
    '性商业视频',
    '性商业电影',
    '性商业剧',
    '性市场',
    '性市场内容',
    '性市场视频',
    '性市场电影',
    '性市场剧',
    '性场所',
    '性场所内容',
    '性场所视频',
    '性场所电影',
    '性场所剧',
    '性俱乐部',
    '性俱乐部内容',
    '性俱乐部视频',
    '性俱乐部电影',
    '性俱乐部剧',
    '性酒吧',
    '性酒吧内容',
    '性酒吧视频',
    '性酒吧电影',
    '性酒吧剧',
    '性按摩',
    '性按摩内容',
    '性按摩视频',
    '性按摩电影',
    '性按摩剧',
    '性按摩店',
    '性按摩店内容',
    '性按摩店视频',
    '性按摩店电影',
    '性按摩店剧',
    '性按摩院',
    '性按摩院内容',
    '性按摩院视频',
    '性按摩院电影',
    '性按摩院剧',
    '性按摩中心',
    '性按摩中心内容',
    '性按摩中心视频',
    '性按摩中心电影',
    '性按摩中心剧',
    '性按摩会所',
    '性按摩会所内容',
    '性按摩会所视频',
    '性按摩会所电影',
    '性按摩会所剧',
    '性按摩服务',
    '性按摩服务内容',
    '性按摩服务视频',
    '性按摩服务电影',
    '性按摩服务剧',
    '性按摩技师',
    '性按摩技师内容',
    '性按摩技师视频',
    '性按摩技师电影',
    '性按摩技师剧',
    '性按摩师',
    '性按摩师内容',
    '性按摩师视频',
    '性按摩师电影',
    '性按摩师剧',
    '性按摩小姐',
    '性按摩小姐内容',
    '性按摩小姐视频',
    '性按摩小姐电影',
    '性按摩小姐剧',
    '性按摩女',
    '性按摩女内容',
    '性按摩女视频',
    '性按摩女电影',
    '性按摩女剧',
    '性按摩男',
    '性按摩男内容',
    '性按摩男视频',
    '性按摩男电影',
    '性按摩男剧',
    '性按摩人员',
    '性按摩人员内容',
    '性按摩人员视频',
    '性按摩人员电影',
    '性按摩人员剧',
    '性按摩员工',
    '性按摩员工内容',
    '性按摩员工视频',
    '性按摩员工电影',
    '性按摩员工剧',
    '性按摩工作者',
    '性按摩工作者内容',
    '性按摩工作者视频',
    '性按摩工作者电影',
    '性按摩工作者剧',
    '性按摩从业者',
    '性按摩从业者内容',
    '性按摩从业者视频',
    '性按摩从业者电影',
    '性按摩从业者剧',
    '性按摩从业员',
    '性按摩从业员内容',
    '性按摩从业员视频',
    '性按摩从业员电影',
    '性按摩从业员剧',
    '性按摩从业者',
    '性按摩从业者内容',
    '性按摩从业者视频',
    '性按摩从业者电影',
    '性按摩从业者剧',
    '性按摩从业员',
    '性按摩从业员内容',
    '性按摩从业员视频',
    '性按摩从业员电影',
    '性按摩从业员剧',
  ];

  // 检查是否启用黄色内容过滤
  static Future<bool> isYellowFilterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('yellow_filter_enabled') ?? true;
  }

  // 过滤黄色内容
  static Future<List<T>> filterYellowContent<T>(List<T> items, String Function(T) getText) async {
    final isEnabled = await isYellowFilterEnabled();
    if (!isEnabled) {
      return items;
    }

    return items.where((item) {
      final text = getText(item).toLowerCase();
      return !_yellowContentKeywords.any((keyword) => 
        text.contains(keyword.toLowerCase())
      );
    }).toList();
  }

  // 检查单个文本是否包含黄色内容
  static bool containsYellowContent(String text) {
    final lowerText = text.toLowerCase();
    return _yellowContentKeywords.any((keyword) => 
      lowerText.contains(keyword.toLowerCase())
    );
  }

  // 获取过滤后的关键词列表（用于调试）
  static List<String> getFilteredKeywords() {
    return List.from(_yellowContentKeywords);
  }

  // 添加自定义过滤关键词
  static Future<void> addCustomKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final customKeywords = prefs.getStringList('custom_yellow_keywords') ?? [];
    if (!customKeywords.contains(keyword)) {
      customKeywords.add(keyword);
      await prefs.setStringList('custom_yellow_keywords', customKeywords);
    }
  }

  // 移除自定义过滤关键词
  static Future<void> removeCustomKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final customKeywords = prefs.getStringList('custom_yellow_keywords') ?? [];
    customKeywords.remove(keyword);
    await prefs.setStringList('custom_yellow_keywords', customKeywords);
  }

  // 获取所有过滤关键词（包括自定义的）
  static Future<List<String>> getAllKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    final customKeywords = prefs.getStringList('custom_yellow_keywords') ?? [];
    return [..._yellowContentKeywords, ...customKeywords];
  }
}
