/// 应用常量
class AppConstants {
  // 应用信息
  static const String appName = 'Vision X';
  static const String appVersion = '1.0.0';
  
  // API相关
  static const String apiBaseUrl = 'https://api.example.com';
  static const int apiTimeoutSeconds = 30; // 秒
  
  // 缓存相关
  static const String cacheDir = 'cache';
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // 分页相关
  static const int defaultPageSize = 20;
  
  // 文件相关
  static const List<String> supportedVideoFormats = [
    'mp4', 'mkv', 'avi', 'mov', 'flv', 'wmv'
  ];
  
  // 其他常量
  static const int maxSearchHistory = 10;
}