import 'package:flutter/material.dart';

/// 排序弹出菜单组件
/// 提供多种排序选项，包括默认、评分、时间、热度等
class SortPopupMenu extends StatelessWidget {
  final Function(String) onSortChanged;
  final String currentSort;

  const SortPopupMenu({
    super.key, 
    required this.onSortChanged,
    this.currentSort = 'default',
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: '排序选项',
      onSelected: onSortChanged,
      itemBuilder: (BuildContext context) {
        return [
          _buildMenuItem('default', '默认排序', Icons.sort_by_alpha),
          _buildMenuItem('score', '评分排序', Icons.star),
          _buildMenuItem('time', '时间排序', Icons.access_time),
          _buildMenuItem('hits', '热度排序', Icons.trending_up),
        ];
      },
    );
  }

  /// 构建排序菜单项
  PopupMenuItem<String> _buildMenuItem(String value, String text, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: currentSort == value ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontWeight: currentSort == value ? FontWeight.bold : FontWeight.normal,
              color: currentSort == value ? Colors.blue : Colors.black87,
            ),
          ),
          if (currentSort == value)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.check, size: 16, color: Colors.blue),
            ),
        ],
      ),
    );
  }
}