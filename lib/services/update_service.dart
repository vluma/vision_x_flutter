import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// 应用更新服务
class UpdateService {
  static const String _baseUrl = 'https://api.pgyer.com/apiv2/app/check';
  
  /// API Key (需要在蒲公英平台获取)
  final String apiKey;
  
  /// App Key (需要在蒲公英平台获取)
  final String appKey;

  UpdateService({
    required this.apiKey,
    required this.appKey,
  });

  /// 检查是否有新版本
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      debugPrint('=== Update Service Debug Info ===');
      debugPrint('API Key: $apiKey');
      debugPrint('App Key: $appKey');
      debugPrint('Current App Version: ${packageInfo.version}');
      debugPrint('Current App Build Number: ${packageInfo.buildNumber}');
      debugPrint('========================');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          '_api_key': apiKey,
          'appKey': appKey,
          'buildVersion': packageInfo.version,
        },
      );

      debugPrint('=== HTTP Response Debug Info ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('========================');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        debugPrint('=== API Response Debug Info ===');
        debugPrint('Response Code: ${data['code']}');
        debugPrint('Response Message: ${data['message']}');
        debugPrint('========================');
        
        if (data['code'] == 0) {
          final jsonData = data['data'];
          return UpdateInfo.fromJson(jsonData);
        } else {
          debugPrint('API Error: ${data['message']}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
      }
      
      return null;
    } catch (e) {
      debugPrint('=== Update Service Exception ===');
      debugPrint('Exception: $e');
      debugPrint('========================');
      
      // 发生错误时返回null，不提示用户
      return null;
    }
  }
}

/// 更新信息数据类
class UpdateInfo {
  /// 蒲公英生成的用于区分历史版本的build号
  final int buildBuildVersion;
  
  /// 强制更新版本号
  final String forceUpdateVersion;
  
  /// 强制更新的版本编号
  final String forceUpdateVersionNo;
  
  /// 是否强制更新
  final bool needForceUpdate;
  
  /// 应用安装地址
  final String downloadURL;
  
  /// 应用安装单页地址
  final String appURL;
  
  /// 是否有新版本
  final bool buildHaveNewVersion;
  
  /// 上传包的版本编号
  final String buildVersionNo;
  
  /// 版本号
  final String buildVersion;
  
  /// 应用短链接
  final String buildShortcutUrl;
  
  /// 应用更新说明
  final String buildUpdateDescription;
  
  /// buildKey 用于安装特定版本
  final String buildKey;

  UpdateInfo({
    required this.buildBuildVersion,
    required this.forceUpdateVersion,
    required this.forceUpdateVersionNo,
    required this.needForceUpdate,
    required this.downloadURL,
    required this.appURL,
    required this.buildHaveNewVersion,
    required this.buildVersionNo,
    required this.buildVersion,
    required this.buildShortcutUrl,
    required this.buildUpdateDescription,
    required this.buildKey,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    debugPrint('=== Update Info JSON ===');
    debugPrint('Raw JSON: $json');
    debugPrint('========================');
    
    return UpdateInfo(
      buildBuildVersion: int.tryParse(json['buildBuildVersion'].toString()) ?? 0,
      forceUpdateVersion: json['forceUpdateVersion'] ?? '',
      forceUpdateVersionNo: json['forceUpdateVersionNo'] ?? '',
      needForceUpdate: json['needForceUpdate'] ?? false,
      downloadURL: json['downloadURL'] ?? '',
      appURL: json['appURL'] ?? '',
      buildHaveNewVersion: json['buildHaveNewVersion'] ?? false,
      buildVersionNo: json['buildVersionNo'] ?? '',
      buildVersion: json['buildVersion'] ?? '',
      buildShortcutUrl: json['buildShortcutUrl'] ?? '',
      buildUpdateDescription: json['buildUpdateDescription'] ?? '',
      buildKey: json['buildKey'] ?? '',
    );
  }
}