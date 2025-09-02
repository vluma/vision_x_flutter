import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';
import 'package:vision_x_flutter/features/detail_page/detail_view_model.dart';
import 'package:vision_x_flutter/features/detail_page/widgets/detail_app_bar.dart';
import 'package:vision_x_flutter/features/detail_page/widgets/detail_header.dart';
import 'package:vision_x_flutter/features/detail_page/widgets/detail_description.dart';
import 'package:vision_x_flutter/features/detail_page/widgets/detail_cast.dart';
import 'package:vision_x_flutter/features/detail_page/widgets/detail_sources.dart';
import 'package:vision_x_flutter/features/detail_page/widgets/loading_state.dart';


/// 详情页面 - 展示媒体详细信息
/// 采用MVVM架构，状态管理由DetailViewModel处理
class DetailPage extends StatefulWidget {
  final String? id;
  final MediaDetail? media;

  const DetailPage({super.key, this.id, this.media});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final DetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DetailViewModel(
      mediaId: widget.id,
      initialMedia: widget.media,
    );
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailAppBar(
        title: _viewModel.media?.name ?? '详情页面',
        onBack: () => context.pop(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<DetailState>(
      valueListenable: _viewModel.stateNotifier,
      builder: (context, state, _) {
        return switch (state) {
          DetailState.loading => const LoadingState(),
          DetailState.error => _buildErrorState(),
          DetailState.success => _buildSuccessContent(),
        };
      },
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text('加载失败，请重试'),
    );
  }

  Widget _buildSuccessContent() {
    final media = _viewModel.media;
    if (media == null) {
      return const LoadingState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailHeader(media: media),
          DetailDescription(media: media),
          DetailCast(media: media),
          DetailSources(media: media),
        ],
      ),
    );
  }
}