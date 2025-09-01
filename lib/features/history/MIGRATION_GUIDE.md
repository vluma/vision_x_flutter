# 历史模块迁移指南

## 从旧架构到新架构的迁移

### 1. 架构变化

#### 旧架构 (Provider + ChangeNotifier)
```
lib/features/history/
├── history_page.dart
├── history_view_model.dart
└── widgets/
    ├── history_list.dart
    ├── empty_history.dart
    └── loading_indicator.dart
```

#### 新架构 (Riverpod + MVVM)
```
lib/features/history/
├── domain/
│   ├── entities/
│   │   └── history_record.dart
│   └── repositories/
│       └── history_repository.dart
├── data/
│   ├── repositories/
│   │   └── history_repository_impl.dart
│   └── mappers/
│       └── history_mappers.dart
├── presentation/
│   ├── providers/
│   │   └── history_providers.dart
│   ├── pages/
│   │   └── history_page.dart
│   └── widgets/
│       ├── history_list.dart
│       ├── empty_history.dart
│       └── loading_indicator.dart
└── history_module.dart
```

### 2. 关键变化

#### 状态管理
- **从**: `ChangeNotifier` + `ChangeNotifierProvider`
- **到**: `StateNotifier` + `StateNotifierProvider` (Riverpod)

#### 数据模型
- **从**: `HistoryRecord` (可变)
- **到**: `HistoryRecordEntity` (不可变)

#### 数据访问
- **从**: `HistoryService` (单例)
- **到**: `HistoryRepository` (接口) + `HistoryRepositoryImpl` (实现)

### 3. 代码迁移示例

#### 旧代码
```dart
// 旧的状态管理
class HistoryViewModel extends ChangeNotifier {
  List<HistoryRecord> _records = [];
  
  List<HistoryRecord> get records => _records;
  
  Future<void> loadHistory() async {
    _records = await HistoryService().getHistory();
    notifyListeners();
  }
}

// 使用
ChangeNotifierProvider(
  create: (_) => HistoryViewModel(),
  child: HistoryPage(),
)
```

#### 新代码
```dart
// 新的状态管理
class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repository;
  
  HistoryNotifier(this._repository) : super(HistoryState.initial());
  
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final records = await _repository.getHistory();
    state = state.copyWith(records: records, isLoading: false);
  }
}

// 使用
final historyNotifierProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final repository = ref.watch(historyRepositoryProvider);
  return HistoryNotifier(repository);
});
```

### 4. 迁移步骤

1. **更新依赖**: 确保已添加 Riverpod 相关依赖
2. **创建实体**: 使用新的 `HistoryRecordEntity`
3. **实现仓库**: 创建 `HistoryRepository` 和 `HistoryRepositoryImpl`
4. **迁移状态管理**: 使用 `HistoryNotifier` 替代 `HistoryViewModel`
5. **更新UI**: 使用 `ConsumerWidget` 替代 `StatelessWidget`
6. **更新路由**: 修改路由导入路径
7. **测试**: 确保功能正常工作

### 5. 注意事项

- 新的 `HistoryRecordEntity` 是不可变的，使用 `copyWith` 更新字段
- 所有异步操作都有完整的错误处理
- 支持撤销删除操作
- 数据持久化使用 `SharedPreferences` 保持不变
- 保持向后兼容性，历史数据格式不变

### 6. 测试验证

迁移后请验证以下功能：
- [ ] 历史记录加载
- [ ] 添加新记录
- [ ] 删除记录（含撤销功能）
- [ ] 清空历史记录
- [ ] 更新观看进度
- [ ] 下拉刷新
- [ ] 错误处理和重试
- [ ] 空状态显示