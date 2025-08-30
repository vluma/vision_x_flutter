/// 字符串工具类
class StringUtils {
  /// 截断字符串，超出部分用省略号替代
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
  
  /// 检查字符串是否为空或只包含空白字符
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }
  
  /// 将字符串首字母大写
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  /// 私有构造函数，防止实例化
  StringUtils._();
}