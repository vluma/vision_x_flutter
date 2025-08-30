/// 应用异常基类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// 网络异常
class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// API异常
class ApiException extends AppException {
  ApiException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// 认证异常
class AuthException extends AppException {
  AuthException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// 缓存异常
class CacheException extends AppException {
  CacheException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// 数据解析异常
class ParseException extends AppException {
  ParseException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// 权限异常
class PermissionException extends AppException {
  PermissionException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// 未找到资源异常
class NotFoundException extends AppException {
  NotFoundException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}