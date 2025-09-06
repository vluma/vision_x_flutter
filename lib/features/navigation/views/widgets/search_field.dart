/// 搜索输入框组件
/// 搜索功能的文本输入UI组件
library;

import 'package:flutter/material.dart';
import 'package:vision_x_flutter/services/api_service.dart';

/// 搜索输入框组件
class SearchField extends StatelessWidget {
  final TextEditingController controller;

  const SearchField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        isDense: true,
      ),
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          searchDataSource.setSearchQuery(value);
        }
      },
    );
  }
}