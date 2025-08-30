import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../exceptions/api_exception.dart';

/// API客户端
class ApiClient {
  final http.Client _httpClient;
  
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  
  /// 基础URL
  final String baseUrl = AppConstants.apiBaseUrl;
  
  /// 执行GET请求
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/$endpoint'), headers: headers)
          .timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      return _processResponse(response);
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }
  
  /// 执行POST请求
  Future<Map<String, dynamic>> post(
    String endpoint, 
    {Map<String, String>? headers, dynamic body}
  ) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {...?headers, 'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      return _processResponse(response);
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }
  
  /// 处理响应
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('解析响应失败: $e');
      }
    } else {
      throw ApiException('请求失败: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
  
  /// 关闭客户端
  void dispose() {
    _httpClient.close();
  }
}