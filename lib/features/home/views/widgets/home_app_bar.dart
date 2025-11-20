import 'package:flutter/material.dart';
import 'package:vision_x_flutter/features/home/models/filter_criteria.dart';

/// 首页自定义 AppBar 组件
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String selectedCategory;
  final String selectedSource;
  final String selectedSort;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onSortChanged;

  const HomeAppBar({
    super.key,
    required this.selectedCategory,
    required this.selectedSource,
    required this.selectedSort,
    required this.onCategoryChanged,
    required this.onSourceChanged,
    required this.onSortChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('豆瓣热门'),
      actions: _buildCategoryActions(context),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: _buildSourceTags(context),
      ),
    );
  }

  /// 构建分类导航项
  List<Widget> _buildCategoryActions(BuildContext context) {
    return [
      _buildCategoryItem(context, MovieCategory.movie.label),
      _buildCategoryItem(context, MovieCategory.tv.label),
      _buildSortButton(context),
    ];
  }

  /// 构建单个分类项
  Widget _buildCategoryItem(BuildContext context, String category) {
    final bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: () => onCategoryChanged(category),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodySmall?.color ??
                        Colors.grey,
              ),
            ),
            const SizedBox(height: 3),
            if (isSelected) _buildIndicator(context),
          ],
        ),
      ),
    );
  }

  /// 构建选中指示器
  Widget _buildIndicator(BuildContext context) {
    return Container(
      height: 3,
      width: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 构建排序按钮
  Widget _buildSortButton(BuildContext context) {
    final sortOptions = [
      {'value': 'recommend', 'label': '推荐排序'},
      {'value': 'time', 'label': '时间排序'},
      {'value': 'rank', 'label': '评分排序'},
    ];

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.sort,
        color: Theme.of(context).iconTheme.color,
      ),
      color: Theme.of(context).cardColor, // 使用主题背景色
      onSelected: onSortChanged,
      itemBuilder: (BuildContext context) {
        return sortOptions.map((option) {
          return PopupMenuItem<String>(
            value: option['value']!,
            child: Text(
              option['label']!,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          );
        }).toList();
      },
    );
  }

  /// 构建源标签列表
  Widget _buildSourceTags(BuildContext context) {
    // 使用默认标签，实际项目中应该从 ViewModel 获取动态标签
    final sources = selectedCategory == MovieCategory.movie.label
        ? FilterCriteria.movieSources
        : FilterCriteria.tvSources;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: sources.map((source) {
          final bool isSelected = selectedSource == source;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () => onSourceChanged(source),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    source,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodySmall?.color ??
                              Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (isSelected)
                    Container(
                      height: 2,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
