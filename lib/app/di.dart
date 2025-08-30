import 'package:get_it/get_it.dart';
import 'package:vision_x_flutter/core/themes/app_theme.dart';


/// 依赖注入配置
/// 使用GetIt来管理应用的依赖
class DependencyInjection {
  static final GetIt _getIt = GetIt.instance;

  static Future<void> init() async {
    // 注册主题相关服务
    _getIt.registerSingleton<AppThemes>(AppThemes());
  }
  
  // 获取注册的服务实例
  static T get<T extends Object>() {
    return _getIt<T>();
  }
  
  // 检查服务是否已注册
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
}