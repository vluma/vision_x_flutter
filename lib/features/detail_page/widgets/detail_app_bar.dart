import 'package:flutter/material.dart';

/// 详情页面AppBar组件
/// 提供统一的导航栏样式和返回功能
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;

  const DetailAppBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
        tooltip: '返回',
      ),
      centerTitle: true,
      elevation: 0,
    );
  }
}