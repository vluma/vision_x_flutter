import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/models/media_detail.dart';
import 'package:vision_x_flutter/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vision_x_flutter/components/loading_animation.dart';
import 'package:provider/provider.dart';

// 搜索状态管理类
class _SearchController extends ChangeNotifier {
  List<MediaDetail> _mediaResults = [];
  List<MediaDetail> _filteredResults = [];
  List<MediaDetail> _aggregatedResults = []; // 添加聚合结果列表
  String _selectedCategory = '全部';
  String _sortBy = 'default';
  bool _isLoading = false;
  bool _hasSearched = false;
  String _lastSearchQuery = '';
  int _searchId = 0;

  List<MediaDetail> get mediaResults => _mediaResults;
  List<MediaDetail> get filteredResults => _filteredResults;
  List<MediaDetail> get aggregatedResults => _aggregatedResults; // 添加getter
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;

  // 执行聚合搜索
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      return;
    }

    final int currentSearchId = ++_searchId;
    _isLoading = true;
    _hasSearched = true;
    _selectedCategory = '全部';
    _sortBy = 'default';
    notifyListeners();

    try {
      final results = await ApiService.aggregatedSearch(query.trim());

      if (currentSearchId == _searchId) {
        _mediaResults = results;
        _filteredResults = List.from(results);
        _aggregatedResults = _aggregateMedia(results); // 聚合结果
        _isLoading = false;
        _lastSearchQuery = query.trim();
        notifyListeners();
        
        // 更新分类
        _updateCategories();
      }
    } catch (e) {
      if (currentSearchId == _searchId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // 聚合结果，将名称、年份、分类相同的媒体聚合在一起
  List<MediaDetail> _aggregateMedia(List<MediaDetail> mediaList) {
    final Map<String, MediaDetail> aggregatedMap = {};
    
    for (var media in mediaList) {
      // 创建唯一标识符，基于名称、年份和分类
      final key = '${media.name ?? ''}_${media.year ?? ''}_${media.type ?? ''}';
      
      if (aggregatedMap.containsKey(key)) {
        // 如果已存在，合并来源和剧集信息
        final existingMedia = aggregatedMap[key]!;
        existingMedia.surces.addAll(media.surces);
      } else {
        // 如果不存在，添加新条目
        aggregatedMap[key] = MediaDetail(
          id: media.id,
          name: media.name,
          subtitle: media.subtitle,
          type: media.type,
          category: media.category,
          year: media.year,
          area: media.area,
          language: media.language,
          duration: media.duration,
          state: media.state,
          remarks: media.remarks,
          version: media.version,
          actors: media.actors,
          director: media.director,
          writer: media.writer,
          description: media.description,
          content: media.content,
          poster: media.poster,
          posterThumb: media.posterThumb,
          posterSlide: media.posterSlide,
          posterScreenshot: media.posterScreenshot,
          playUrl: media.playUrl,
          playFrom: media.playFrom,
          playServer: media.playServer,
          playNote: media.playNote,
          score: media.score,
          scoreAll: media.scoreAll,
          scoreNum: media.scoreNum,
          doubanScore: media.doubanScore,
          doubanId: media.doubanId,
          hits: media.hits,
          hitsDay: media.hitsDay,
          hitsWeek: media.hitsWeek,
          hitsMonth: media.hitsMonth,
          up: media.up,
          down: media.down,
          time: media.time,
          timeAdd: media.timeAdd,
          letter: media.letter,
          color: media.color,
          tag: media.tag,
          serial: media.serial,
          tv: media.tv,
          weekday: media.weekday,
          pubdate: media.pubdate,
          total: media.total,
          isEnd: media.isEnd,
          trysee: media.trysee,
          sourceName: media.sourceName,
          sourceCode: media.sourceCode,
          apiUrl: media.apiUrl,
          hasCover: media.hasCover,
          sourceInfo: media.sourceInfo,
          surces: List.from(media.surces),
        );
      }
    }
    
    return aggregatedMap.values.toList();
  }

  void _updateCategories() {
    // 更新分类列表
    Set<String> categories = Set<String>();
    for (var media in _mediaResults) {
      if (media.type != null && media.type!.isNotEmpty) {
        categories.add(media.type!);
      }
    }
    
    // 如果当前选中的分类不在新分类列表中，则重置为"全部"
    if (_selectedCategory != '全部' && !categories.contains(_selectedCategory)) {
      _selectedCategory = '全部';
      _filteredResults = List.from(_mediaResults);
      _aggregatedResults = _aggregateMedia(_filteredResults); // 重新聚合
      notifyListeners();
    }
  }

  // 筛选结果
  void filterResults(String category) {
    _selectedCategory = category;
    if (category == '全部') {
      _filteredResults = List.from(_mediaResults);
    } else {
      _filteredResults = _mediaResults.where((media) => media.type == category).toList();
    }
    
    // 应用当前排序
    _sortResults();
    _aggregatedResults = _aggregateMedia(_filteredResults); // 重新聚合
    notifyListeners();
  }

  // 排序结果
  void _sortResults() {
    switch (_sortBy) {
      case 'score':
        _filteredResults.sort((a, b) {
          final scoreA = double.tryParse(a.score ?? '0') ?? 0;
          final scoreB = double.tryParse(b.score ?? '0') ?? 0;
          return scoreB.compareTo(scoreA);
        });
        break;
      case 'time':
        _filteredResults.sort((b, a) {
          return b.timeAdd.compareTo(a.timeAdd);
        });
        break;
      default:
        // 默认排序，保持原有顺序
        break;
    }
  }

  // 更新排序方式
  void updateSortBy(String sortBy) {
    _sortBy = sortBy;
    _sortResults();
    _aggregatedResults = _aggregateMedia(_filteredResults); // 重新聚合
    notifyListeners();
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late _SearchController _searchController;
  bool _isGroupedView = true;
  bool _isScrolledDown = false;

  @override
  void initState() {
    super.initState();
    _searchController = _SearchController();
    searchDataSource.addListener(_handleSearchDataChange);

    // 只有当页面没有搜索过且有搜索查询时才执行搜索
    if (searchDataSource.searchQuery.isNotEmpty && !_searchController.hasSearched) {
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
    // 当搜索数据源发生变化时更新搜索控制器
    // 只有当搜索查询发生变化时才执行新搜索
    if (searchDataSource.searchQuery.isNotEmpty &&
        searchDataSource.searchQuery != _searchController._lastSearchQuery) {
      _searchController.performSearch(searchDataSource.searchQuery);
    }
  }

  // 切换视图模式
  void _toggleViewMode() {
    setState(() {
      _isGroupedView = !_isGroupedView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _searchController,
      child: _SearchPageContent(
        isGroupedView: _isGroupedView,
        isScrolledDown: _isScrolledDown,
        onToggleViewMode: _toggleViewMode,
        onScrollStateChanged: (isScrolled) {
          setState(() {
            _isScrolledDown = isScrolled;
          });
        },
      ),
    );
  }
}

// 搜索页面内容组件
class _SearchPageContent extends StatelessWidget {
  final bool isGroupedView;
  final bool isScrolledDown;
  final VoidCallback onToggleViewMode;
  final Function(bool) onScrollStateChanged;

  const _SearchPageContent({
    required this.isGroupedView,
    required this.isScrolledDown,
    required this.onToggleViewMode,
    required this.onScrollStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<_SearchController>(
      builder: (context, searchController, child) {
        // 获取所有分类，确保"全部"在最前面
        List<String> sortedCategories = ['全部'];
        Set<String> otherCategories = Set<String>();
        
        for (var media in searchController.mediaResults) {
          if (media.type != null && media.type!.isNotEmpty) {
            otherCategories.add(media.type!);
          }
        }
        
        // 对其他分类进行排序并添加到列表中
        List<String> sortedOtherCategories = otherCategories.toList()..sort();
        sortedCategories.addAll(sortedOtherCategories);

        // 按来源分组结果（用于分组视图）
        Map<String, List<MediaDetail>> groupedResults = {};
        for (var media in searchController.filteredResults) {
          final sourceName = media.sourceName;
          if (!groupedResults.containsKey(sourceName)) {
            groupedResults[sourceName] = [];
          }
          groupedResults[sourceName]!.add(media);
        }

        // 如果是分组视图但没有分组数据，使用原始媒体结果创建分组
        if (isGroupedView && groupedResults.isEmpty && searchController.filteredResults.isNotEmpty) {
          final defaultGroupName = '默认分组';
          groupedResults[defaultGroupName] = searchController.filteredResults;
        }

        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: const Text('搜索结果'),
            actions: [
              // 视图切换按钮
              IconButton(
                icon: Icon(isGroupedView ? Icons.view_list : Icons.view_module),
                onPressed: onToggleViewMode,
                tooltip: isGroupedView ? '切换到聚合视图' : '切换到分组视图',
              ),
              // 排序按钮
              _SortPopupMenu(onSortChanged: searchController.updateSortBy),
            ],
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels > 0 && !isScrolledDown) {
                onScrollStateChanged(true);
                return true;
              } else if (scrollInfo.metrics.pixels <= 0 && isScrolledDown) {
                onScrollStateChanged(false);
                return true;
              }
              return false;
            },
            child: Column(
              children: [
                // 分类筛选标签（使用主页样式并添加背景，搜索过程中隐藏）
                if (sortedCategories.length > 1 && !searchController.isLoading)
                  _CategoryFilter(
                    categories: sortedCategories,
                    selectedCategory: searchController.selectedCategory,
                    onCategorySelected: searchController.filterResults,
                    isScrolledDown: isScrolledDown,
                  ),

                // 搜索结果
                if (searchController.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (searchController.hasSearched && searchController.filteredResults.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('未找到相关结果'),
                    ),
                  )
                else if (searchController.filteredResults.isNotEmpty)
                  Expanded(
                    child: isGroupedView 
                      ? _buildGroupedView(groupedResults, context) // 分组视图
                      : _buildListView(context), // 列表视图
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text('请输入关键词搜索'),
                    ),
                  ),
                  
                // 当显示分组视图时添加分组说明
                if (isGroupedView && searchController.filteredResults.isNotEmpty && !searchController.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      '按资源分组显示',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color ??
                            (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 在搜索时隐藏底部导航栏
          bottomNavigationBar: searchDataSource.isSearchExpanded ? null : null,
        );
      }
    );
  }

  // 构建分组视图
  Widget _buildGroupedView(Map<String, List<MediaDetail>> groupedResults, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: groupedResults.keys.length,
      itemBuilder: (BuildContext context, int index) {
        final sourceName = groupedResults.keys.elementAt(index);
        final mediaList = groupedResults[sourceName]!;
        
        return _SourceGroup(
          sourceName: sourceName,
          mediaList: mediaList,
          onMediaTap: (media) {
            _navigateToPlayer(context, media);
          },
          onDetailTap: (media) {
            _showDetailPage(context, media);
          },
        );
      },
    );
  }

  // 构建列表视图（聚合视图）
  Widget _buildListView(BuildContext context) {
    return Consumer<_SearchController>(
      builder: (context, searchController, child) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // 将padding移到ListView上
          itemCount: searchController.aggregatedResults.length,
          itemBuilder: (BuildContext context, int index) {
            final media = searchController.aggregatedResults[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _MediaGridItem(
                media: media,
                onTap: () {
                  _navigateToPlayer(context, media);
                },
                onDetailTap: () {
                  _showDetailPage(context, media);
                },
              ),
            );
          },
        );
      }
    );
  }

  // 导航到播放器页面
  void _navigateToPlayer(BuildContext context, MediaDetail media) {
    // 检查是否有可用的剧集
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

  // 显示详情页面（模态方式）
  void _showDetailPage(BuildContext context, MediaDetail media) {
    context.push(
      '/search/detail/${media.id}',
      extra: media,
    );
  }
}

// 排序弹出菜单
class _SortPopupMenu extends StatelessWidget {
  final Function(String) onSortChanged;

  const _SortPopupMenu({required this.onSortChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      onSelected: onSortChanged,
      itemBuilder: (BuildContext context) {
        return const [
          PopupMenuItem(
            value: 'default',
            child: Text('默认排序'),
          ),
          PopupMenuItem(
            value: 'score',
            child: Text('评分排序'),
          ),
          PopupMenuItem(
            value: 'time',
            child: Text('时间排序'),
          ),
        ];
      },
    );
  }
}

// 分类筛选器
class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool isScrolledDown;

  const _CategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isScrolledDown,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40),
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isScrolledDown 
            ? (Theme.of(context).appBarTheme.backgroundColor ?? 
               (Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF121212) 
                : const Color(0xFFEEEEEE)))
            : (Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF121212) 
                : const Color(0xFFEEEEEE)),
          boxShadow: isScrolledDown ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ] : [],
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () {
                  if (!isSelected) {
                    onCategorySelected(category);
                  }
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
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
                        height: 3,
                        width: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 来源分组组件
class _SourceGroup extends StatelessWidget {
  final String sourceName;
  final List<MediaDetail> mediaList;
  final Function(MediaDetail) onMediaTap;
  final Function(MediaDetail) onDetailTap;

  const _SourceGroup({
    required this.sourceName,
    required this.mediaList,
    required this.onMediaTap,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 来源标题
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            sourceName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 根据媒体数量采用不同的布局
        _buildMediaLayout(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMediaLayout() {
    if (mediaList.length == 1) {
      // 只有一个媒体项，使用图片在左侧的布局
      return Container(
        height: 140,
        child: _MediaResultItem(
          media: mediaList[0],
          onTap: () => onMediaTap(mediaList[0]),
          onDetailTap: () => onDetailTap(mediaList[0]),
        ),
      );
    } else if (mediaList.length == 2) {
      // 两个媒体项，使用Row布局，不可滑动
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 180,
              margin: const EdgeInsets.only(right: 4),
              child: _VerticalMediaItem(
                media: mediaList[0],
                onTap: () => onMediaTap(mediaList[0]),
                onDetailTap: () => onDetailTap(mediaList[0]),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 180,
              margin: const EdgeInsets.only(left: 4),
              child: _VerticalMediaItem(
                media: mediaList[1],
                onTap: () => onMediaTap(mediaList[1]),
                onDetailTap: () => onDetailTap(mediaList[1]),
              ),
            ),
          ),
        ],
      );
    } else {
      // 三个或以上媒体项，使用图片在上方的布局，固定宽度，可滑动
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            final media = mediaList[index];
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 8),
              child: _VerticalMediaItem(
                media: media,
                onTap: () => onMediaTap(media),
                onDetailTap: () => onDetailTap(media),
              ),
            );
          },
        ),
      );
    }
  }
}

// 媒体结果项组件（图片在左侧的布局）
class _MediaResultItem extends StatelessWidget {
  final MediaDetail media;
  final VoidCallback onTap;
  final VoidCallback onDetailTap;

  const _MediaResultItem({
    required this.media,
    required this.onTap,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String? imageUrl = media.poster;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 海报图片
            _buildImageContainer(imageUrl, isDarkMode),

            // 内容信息
            _buildContent(context, theme, isDarkMode),
          ],
        ),
      ),
    );
  }

  // 构建图片容器
  Widget _buildImageContainer(String? imageUrl, bool isDarkMode) {
    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingAnimation(),
                errorWidget: (context, url, error) => Container(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.movie,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : Container(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );
  }

  // 构建内容区域
  Widget _buildContent(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题和基本信息
            _buildTitleAndInfo(theme, isDarkMode),

            // 简介
            _buildDescription(context, isDarkMode),

            const SizedBox(height: 4),

            // 底部信息
            Flexible(
              child: _buildBottomInfo(theme, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  // 构建标题和基本信息
  Widget _buildTitleAndInfo(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          media.name ?? '未知片名',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // 年份、区域和类型信息
        _buildYearAreaType(theme, isDarkMode),

        const SizedBox(height: 4),

        // 评分和来源
        _buildRatingAndSource(theme, isDarkMode),
      ],
    );
  }

  // 构建年份、区域和类型信息
  Widget _buildYearAreaType(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        if (media.year != null && media.year!.isNotEmpty)
          Text(
            media.year!,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        if (media.year != null &&
            media.year!.isNotEmpty &&
            media.area != null &&
            media.area!.isNotEmpty)
          Text(
            ' · ',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        if (media.area != null && media.area!.isNotEmpty)
          Text(
            media.area!,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        if (media.type != null && media.type!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              media.type!,
              style: TextStyle(
                fontSize: 9,
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // 构建评分和来源信息
  Widget _buildRatingAndSource(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        // 评分
        if (media.score != null && media.score!.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 3),
              Text(
                media.score!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        // 来源信息
        if (media.sourceName.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              media.sourceName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
      ],
    );
  }

  // 构建简介
  Widget _buildDescription(BuildContext context, bool isDarkMode) {
    if (media.description == null) {
      return const SizedBox.shrink();
    }

    return Text(
      media.description!,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).textTheme.bodySmall?.color ??
            (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // 构建底部信息
  Widget _buildBottomInfo(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 演员信息
        if (media.actors != null && media.actors!.isNotEmpty)
          Expanded(
            child: Text(
              media.actors!,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // 详情按钮
        TextButton(
          onPressed: onDetailTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '详情',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// 媒体结果项组件（图片在上方的布局）
class _VerticalMediaItem extends StatelessWidget {
  final MediaDetail media;
  final VoidCallback onTap;
  final VoidCallback onDetailTap;

  const _VerticalMediaItem({
    required this.media,
    required this.onTap,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String? imageUrl = media.poster;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 海报图片
            _buildImageContainer(context, imageUrl, isDarkMode),
            
            // 标题
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                media.name ?? '未知片名',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // 年份、地区、分类信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: _buildYearAreaType(theme, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  // 构建图片容器（带评分和详情按钮）
  Widget _buildImageContainer(BuildContext context, String? imageUrl, bool isDarkMode) {
    final theme = Theme.of(context);
    
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 图片
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const LoadingAnimation(),
                    errorWidget: (context, url, error) => Container(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.movie,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.movie,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
          
          // 黑色半透明渐变蒙版
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),
          
          // 评分（左下角）
          if (media.score != null && media.score!.isNotEmpty)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      media.score!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 详情按钮（右下角）
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDetailTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '详情',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建年份、区域和类型信息
  Widget _buildYearAreaType(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 年份和区域
        Expanded(
          child: Text(
            [
              if (media.year != null && media.year!.isNotEmpty) media.year,
              if (media.area != null && media.area!.isNotEmpty) media.area,
            ].join(' · '),
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // 类型标签
        if (media.type != null && media.type!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              media.type!,
              style: TextStyle(
                fontSize: 9,
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// 媒体网格项组件（用于列表视图）
class _MediaGridItem extends StatelessWidget {
  final MediaDetail media;
  final VoidCallback onTap;
  final VoidCallback onDetailTap;

  const _MediaGridItem({
    required this.media,
    required this.onTap,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String? imageUrl = media.poster;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 海报图片
            _buildImageContainer(imageUrl, isDarkMode),

            // 内容信息
            _buildContent(context, theme, isDarkMode),
          ],
        ),
      ),
    );
  }

  // 构建图片容器
  Widget _buildImageContainer(String? imageUrl, bool isDarkMode) {
    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingAnimation(),
                errorWidget: (context, url, error) => Container(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.movie,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : Container(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );
  }

  // 构建内容区域
  Widget _buildContent(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题和基本信息
            _buildTitleAndInfo(theme, isDarkMode),

            // 简介
            _buildDescription(context, isDarkMode),

            const SizedBox(height: 4),

            // 底部信息
            Flexible(
              child: _buildBottomInfo(theme, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  // 构建标题和基本信息
  Widget _buildTitleAndInfo(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          media.name ?? '未知片名',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // 年份、区域和类型信息
        _buildYearAreaType(theme, isDarkMode),

        const SizedBox(height: 4),

        // 评分和来源
        _buildRatingAndSource(theme, isDarkMode),
      ],
    );
  }

  // 构建年份、区域和类型信息
  Widget _buildYearAreaType(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        if (media.year != null && media.year!.isNotEmpty)
          Text(
            media.year!,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        if (media.year != null &&
            media.year!.isNotEmpty &&
            media.area != null &&
            media.area!.isNotEmpty)
          Text(
            ' · ',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        if (media.area != null && media.area!.isNotEmpty)
          Text(
            media.area!,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        if (media.type != null && media.type!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              media.type!,
              style: TextStyle(
                fontSize: 9,
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // 构建评分和来源信息
  Widget _buildRatingAndSource(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        // 评分
        if (media.score != null && media.score!.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 3),
              Text(
                media.score!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        // 来源信息
        if (media.sourceName.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              media.sourceName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
      ],
    );
  }

  // 构建简介
  Widget _buildDescription(BuildContext context, bool isDarkMode) {
    if (media.description == null) {
      return const SizedBox.shrink();
    }

    return Text(
      media.description!,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).textTheme.bodySmall?.color ??
            (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // 构建底部信息
  Widget _buildBottomInfo(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 演员信息
        if (media.actors != null && media.actors!.isNotEmpty)
          Expanded(
            child: Text(
              media.actors!,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // 详情按钮
        TextButton(
          onPressed: onDetailTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '详情',
            style: TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}