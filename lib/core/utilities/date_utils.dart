import 'package:intl/intl.dart';

/// 日期工具类
class DateUtils {
  /// 格式化日期为字符串
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }
  
  /// 格式化日期时间为字符串
  static String formatDateTime(DateTime date, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(format).format(date);
  }
  
  /// 获取相对时间描述（例如：3分钟前，2小时前，昨天，等）
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      return '${difference.inDays ~/ 30}个月前';
    } else {
      return '${difference.inDays ~/ 365}年前';
    }
  }
  
  /// 判断是否是同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  /// 获取当天开始时间
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// 获取当天结束时间
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}