import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/pages/home/home_view_model.dart';
import 'package:vision_x_flutter/pages/home/widgets/home_app_bar.dart';
import 'package:vision_x_flutter/pages/home/widgets/video_grid.dart';
import 'package:vision_x_flutter/pages/home/widgets/loading_skeleton.dart';
import 'package:vision_x_flutter/services/api_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: HomeAppBar(
        selectedCategory: viewModel.selectedCategory,
        selectedSource: viewModel.selectedSource,
        selectedSort: viewModel.selectedSort,
        onCategoryChanged: viewModel.switchCategory,
        onSourceChanged: viewModel.switchSource,
        onSortChanged: viewModel.switchSort,
      ),
      body: _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isLoading && viewModel.movies.isEmpty) {
      return const LoadingSkeleton();
    }

    if (viewModel.movies.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return VideoGrid(
      movies: viewModel.movies,
      hasMoreData: viewModel.hasMoreData,
      isLoading: viewModel.isLoading,
      onRefresh: viewModel.refresh,
      onLoadMore: viewModel.loadMoreMovies,
      onItemTap: (movie) {
        // 点击电影项时跳转到搜索页面
        // 搜索功能将在后续版本实现
        searchDataSource.setSearchQuery(movie.title);
        searchDataSource.setSearchExpanded(true);
        context.push('/search', extra: {'query': movie.title});
      },
    );
  }
}
