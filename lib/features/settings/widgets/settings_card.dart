import 'package:flutter/material.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';

/// 设置卡片组件
/// 
/// 提供统一的设置卡片样式，用于包装各个设置区块
class SettingsCard extends StatelessWidget {
  /// 卡片标题
  final String title;
  
  /// 卡片内容
  final Widget content;
  
  /// 标题右侧的操作按钮
  final Widget? action;
  
  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 构造函数
  const SettingsCard({
    super.key,
    required this.title,
    required this.content,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: isDark ? 1 : 2,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}