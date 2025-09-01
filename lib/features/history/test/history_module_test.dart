import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/history/presentation/pages/history_page.dart';

/// 历史模块测试页面
class HistoryModuleTest extends StatelessWidget {
  const HistoryModuleTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: MaterialApp(
        home: HistoryPage(),
      ),
    );
  }
}