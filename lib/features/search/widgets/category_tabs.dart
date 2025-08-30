import 'package:flutter/material.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';

/// 分类标签组件
class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool isLoading;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // 空状态处理：没有分类或正在加载时隐藏组件
    if (isLoading || categories.isEmpty || categories.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40.0,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        // 添加key优化重渲染性能
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return _buildCategoryItem(context, category, isSelected);
        },
      ),
    );
  }

  /// 构建单个分类标签项（提取为独立方法便于维护）
  Widget _buildCategoryItem(BuildContext context, String category, bool isSelected) {
    return Padding(
      key: ValueKey(category), // 使用唯一key优化性能
      padding: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: () => onCategorySelected(category),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54),
              ),
            ),
            const SizedBox(height: 3),
            if (isSelected)
              Container(
                height: 2,
                width: 15,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}