/// App安装服务
class InstallService {
  static const String _baseUrl = 'https://api.pgyer.com/apiv2/app/install';
  
  /// API Key
  final String apiKey;

  InstallService({
    required this.apiKey,
  });

  /// 通过appKey安装最新版本
  String generateInstallUrlByAppKey(String appKey) {
    return '$_baseUrl?_api_key=$apiKey&appKey=$appKey';
  }

  /// 通过buildKey安装特定版本
  String generateInstallUrlByBuildKey(String buildKey, [String? password]) {
    var url = '$_baseUrl?_api_key=$apiKey&buildKey=$buildKey';
    if (password != null && password.isNotEmpty) {
      url += '&buildPassword=$password';
    }
    return url;
  }

  /// iOS应用内安装（通过plist）
  String generateIOSInstallUrlByBuildKey(String buildKey, [String? password]) {
    String url;
    if (password != null && password.isNotEmpty) {
      url = 'itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/$buildKey?password=$password';
    } else {
      url = 'itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/$buildKey';
    }
    return url;
  }
}