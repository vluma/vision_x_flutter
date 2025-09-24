import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:vision_x_flutter/features/search/state/search_controller.dart';
import 'package:vision_x_flutter/features/search/widgets/sort_popup_menu.dart';
import 'package:vision_x_flutter/features/search/widgets/category_tabs.dart';
import 'package:vision_x_flutter/features/search/widgets/source_group.dart';
import 'package:vision_x_flutter/features/search/widgets/media_grid_item.dart';
import 'package:vision_x_flutter/features/search/widgets/media_grid_item_skeleton.dart';
import 'package:vision_x_flutter/features/search/widgets/search_loading_skeleton.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'package:vision_x_flutter/shared/models/media_detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchPageController _searchController;
  bool _isGroupedView = true;

  @override
  void initState() {
    super.initState();
    _searchController = SearchPageController();
    searchDataSource.addListener(_handleSearchDataChange);

    if (searchDataSource.searchQuery.isNotEmpty &&
        !_searchController.hasSearched) {
      _searchController.performSearch(searchDataSource.searchQuery);
    }
  }

  @override
  void dispose() {
    searchDataSource.removeListener(_handleSearchDataChange);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchDataChange() {
    if (searchDataSource.searchQuery.isNotEmpty &&
        searchDataSource.searchQuery != _searchController.lastSearchQuery) {
      _searchController.performSearch(searchDataSource.searchQuery);
    }
  }

  void _toggleViewMode() {
    setState(() {
      _isGroupedView = !_isGroupedView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchPageController>.value(
      value: _searchController,
      child: _SearchPageContent(
        isGroupedView: _isGroupedView,
        onToggleViewMode: _toggleViewMode,
      ),
    );
  }
}

class _SearchPageContent extends StatelessWidget {
  final bool isGroupedView;
  final VoidCallback onToggleViewMode;

  const _SearchPageContent({
    required this.isGroupedView,
    required this.onToggleViewMode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchPageController>(
      builder: (context, searchController, child) {
        List<String> sortedCategories = ['全部'];
        Set<String> otherCategories = <String>{};

        for (var media in searchController.mediaResults) {
          if (media.type != null && media.type!.isNotEmpty) {
            otherCategories.add(media.type!);
          }
        }

        List<String> sortedOtherCategories = otherCategories.toList()..sort();
        sortedCategories.addAll(sortedOtherCategories);

        Map<String, List<MediaDetail>> groupedResults = {};
        for (var media in searchController.filteredResults) {
          final sourceName = media.sourceName;
          if (!groupedResults.containsKey(sourceName)) {
            groupedResults[sourceName] = [];
          }
          groupedResults[sourceName]!.add(media);
        }

        if (isGroupedView &&
            groupedResults.isEmpty &&
            searchController.filteredResults.isNotEmpty) {
          groupedResults['默认分组'] = searchController.filteredResults;
        }

        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            appBar: AppBar(
              title: Text('搜索结果(${searchController.filteredResults.length})'),
              actions: [
                IconButton(
                  icon:
                      Icon(isGroupedView ? Icons.view_list : Icons.view_module),
                  onPressed: onToggleViewMode,
                  tooltip: isGroupedView ? '切换到聚合视图' : '切换到分组视图',
                ),
                SortPopupMenu(onSortChanged: searchController.updateSortBy),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(searchController.isLoading ||
                        (sortedCategories.length - 1) <= 1
                    ? 0.0
                    : 40.0),
                child: CategoryTabs(
                  categories: sortedCategories,
                  selectedCategory: searchController.selectedCategory,
                  onCategorySelected: searchController.filterResults,
                  isLoading: searchController.isLoading,
                ),
              ),
            ),
            body: Column(
              children: [
                if (searchController.isLoading &&
                    searchController.filteredResults.isEmpty)
                  Expanded(
                    child: SearchLoadingSkeleton(isGroupedView: isGroupedView),
                  )
                else if (searchController.hasSearched &&
                    searchController.filteredResults.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('未找到相关结果'),
                    ),
                  )
                else if (searchController.filteredResults.isNotEmpty)
                  Expanded(
                    child: isGroupedView
                        ? _buildGroupedView(groupedResults, context)
                        : _buildListView(context),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text('请输入关键词搜索'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupedView(
      Map<String, List<MediaDetail>> groupedResults, BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.pageMargin.copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.bottomNavigationBarMargin,
      ),
      itemCount: groupedResults.keys.length,
      itemBuilder: (context, index) {
        final sourceName = groupedResults.keys.elementAt(index);
        final mediaList = groupedResults[sourceName]!;
        return SourceGroup(
          sourceName: sourceName,
          mediaList: mediaList,
          onMediaTap: (media) => _navigateToPlayer(context, media),
          onDetailTap: (media) => _showDetailPage(context, media),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return Consumer<SearchPageController>(
      builder: (context, searchController, child) {
        return ListView.builder(
          padding: AppSpacing.pageMargin.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.bottomNavigationBarMargin,
          ),
          itemCount: searchController.aggregatedResults.length,
          itemBuilder: (context, index) {
            final media = searchController.aggregatedResults[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: MediaGridItem(
                media: media,
                onTap: () => _navigateToPlayer(context, media),
                onDetailTap: () => _showDetailPage(context, media),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToPlayer(BuildContext context, MediaDetail media) {
    if (media.surces.isNotEmpty && media.surces.first.episodes.isNotEmpty) {
      final firstEpisode = media.surces.first.episodes.first;
      context.go('/search/video', extra: {
        'media': media,
        'episode': firstEpisode,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该媒体没有可播放的剧集')),
      );
    }
  }

  void _showDetailPage(BuildContext context, MediaDetail media) {
    context.push('/search/detail/${media.id}', extra: media);
  }
}
