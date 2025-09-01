import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/features/history/data/repositories/history_repository_impl.dart';
import 'package:vision_x_flutter/features/history/domain/entities/history_record.dart';
import 'package:vision_x_flutter/features/history/domain/repositories/history_repository.dart';
import 'package:vision_x_flutter/data/models/media_detail.dart';

// 仓库提供者
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl();
});

// 历史记录状态类
class HistoryState {
  final List<HistoryRecordEntity> records;
  final bool isLoading;
  final String? error;

  const HistoryState({
    this.records = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<HistoryRecordEntity>? records,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 历史记录状态通知器
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._repository) : super(const HistoryState());

  final HistoryRepository _repository;

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final records = await _repository.getHistory();
      state = state.copyWith(
        records: records,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshHistory() async {
    await loadHistory();
  }

  Future<void> addHistory(
    MediaDetail media,
    Episode episode,
    int progress, [
    int? duration,
  ]) async {
    try {
      await _repository.addHistory(media, episode, progress, duration);
      await loadHistory(); // 重新加载以更新UI
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeHistory(HistoryRecordEntity record) async {
    try {
      await _repository.removeHistory(record);
      state = state.copyWith(
        records: state.records.where((r) => r != record).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearHistory() async {
    try {
      await _repository.clearHistory();
      state = state.copyWith(records: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateHistoryProgress(
    MediaDetail media,
    Episode episode,
    int progress, [
    int? duration,
  ]) async {
    try {
      await _repository.updateHistoryProgress(media, episode, progress, duration);
      await loadHistory(); // 重新加载以更新UI
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// 历史记录状态提供者
final historyNotifierProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryNotifier(repository);
});

// 空历史记录状态提供者
final isHistoryEmptyProvider = Provider<bool>((ref) {
  final state = ref.watch(historyNotifierProvider);
  return state.records.isEmpty && !state.isLoading;
});

// 历史记录数量提供者
final historyCountProvider = Provider<int>((ref) {
  final state = ref.watch(historyNotifierProvider);
  return state.records.length;
});