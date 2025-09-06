import 'package:flutter/foundation.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';

/// 详情页面状态枚举
enum DetailState {
  loading,    // 加载中
  success,    // 加载成功
  error,      // 加载失败
}

/// 详情页面视图模型
/// 负责处理业务逻辑和状态管理
class DetailViewModel with ChangeNotifier {
  final String? mediaId;
  final MediaDetail? initialMedia;

  MediaDetail? _media;
  DetailState _state = DetailState.loading;

  DetailViewModel({this.mediaId, this.initialMedia});

  MediaDetail? get media => _media;
  DetailState get state => _state;
  ValueNotifier<DetailState> get stateNotifier {
    return ValueNotifier(_state);
  }

  /// 初始化详情数据
  Future<void> initialize() async {
    if (initialMedia != null) {
      _media = initialMedia;
      _state = DetailState.success;
      notifyListeners();
      return;
    }

    if (mediaId == null) {
      _state = DetailState.error;
      notifyListeners();
      return;
    }

    try {
      _state = DetailState.loading;
      notifyListeners();

      // 从API获取详情数据
      final detail = await _getMediaDetail(mediaId!);
      _media = detail;
      _state = DetailState.success;
    } catch (e) {
      _state = DetailState.error;
    } finally {
      notifyListeners();
    }
  }

  /// 刷新详情数据
  Future<void> refresh() async {
    if (mediaId == null) return;
    
    try {
      _state = DetailState.loading;
      notifyListeners();

      final detail = await _getMediaDetail(mediaId!);
      _media = detail;
      _state = DetailState.success;
    } catch (e) {
      _state = DetailState.error;
    } finally {
      notifyListeners();
    }
  }

  /// 获取媒体详情信息
  Future<MediaDetail?> _getMediaDetail(String mediaId) async {
    try {
      // 这里需要根据实际的API结构来获取详情
      // 由于ApiService中没有getMediaDetail方法，我们需要模拟或使用其他方式
      // 暂时返回null，实际项目中需要实现具体的API调用
      return null;
    } catch (e) {
      return null;
    }
  }

}