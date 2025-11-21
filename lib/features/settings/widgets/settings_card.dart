import 'package:flutter/material.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';

/// 设置卡片组件
/// 
/// 提供统一的设置卡片样式，用于包装各个设置区块，采用iOS风格设计
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
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (action != null) action!,
                ],
              ),
            ),
          ],
          content,
        ],
      ),
    );
  }
}