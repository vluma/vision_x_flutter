import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/spacing.dart';
import '../settings_controller.dart';

/// 自定义API设置区块（已整合到数据源设置中）
/// 
/// 此组件已弃用，保留文件以确保向后兼容性
class CustomApiSection extends StatelessWidget {
  /// 构造函数
  const CustomApiSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 这个组件已弃用，不显示任何内容
    return const SizedBox.shrink();
  }
}
