# 历史记录模块 - Feature-First MVVM + Riverpod 架构

## 架构概述

本模块采用 **Feature-First MVVM** 架构模式，结合 **Riverpod** 状态管理库，实现了清晰的分层架构。

## 目录结构

```
lib/features/history/
├── domain/                 # 领域层 (业务逻辑)
│   ├── entities/          # 实体类
│   │   └── history_record.dart
│   └── repositories/      # 仓库接口
│       └── history_repository.dart
├── data/                  # 数据层 (数据访问)
│   ├── repositories/      # 仓库实现
│   │   └── history_repository_impl.dart
│   └── mappers/          # 数据映射器
│       └── history_mappers.dart
├── presentation/          # 表示层 (UI + 状态管理)
│   ├── providers/        # Riverpod 提供者
│   │   └── history_providers.dart
│   ├── pages/            # 页面
│   │   └── history_page.dart
│   └── widgets/          # 组件
│       ├── history_list.dart
│       ├── empty_history.dart
│       └── loading_indicator.dart
└── history_module.dart   # 模块导出文件
```

## 核心特性

### 1. 领域层 (Domain Layer)
- **实体类**: `HistoryRecordEntity` - 不可变的数据模型
- **仓库接口**: `HistoryRepository` - 定义数据访问契约

### 2. 数据层 (Data Layer)
- **仓库实现**: `HistoryRepositoryImpl` - 使用 SharedPreferences 持久化
- **数据映射器**: `HistoryMappers` - 处理数据模型转换

### 3. 表示层 (Presentation Layer)
- **状态管理**: 使用 Riverpod 的 `StateNotifierProvider`
- **响应式UI**: 自动响应状态变化
- **错误处理**: 完整的错误状态和重试机制

### 4. 状态管理
- **HistoryNotifier**: 管理历史记录状态
- **Provider**: 提供全局访问点
- **AsyncValue**: 处理加载、成功、错误状态

## 使用方法

### 1. 在页面中使用

```dart
class HistoryPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyNotifierProvider);
    
    return Scaffold(
      body: HistoryList(
        records: historyState.records,
        onRefresh: () => ref.read(historyNotifierProvider.notifier).refreshHistory(),
        onDelete: (record) => ref.read(historyNotifierProvider.notifier).removeHistory(record),
        onItemTap: (record) {
          // 处理点击事件
        },
      ),
    );
  }
}
```

### 2. 添加历史记录

```dart
ref.read(historyNotifierProvider.notifier).addHistory(
  media,
  episode,
  progress,
  duration,
);
```

### 3. 删除历史记录

```dart
ref.read(historyNotifierProvider.notifier).removeHistory(record);
```

### 4. 清空历史记录

```dart
ref.read(historyNotifierProvider.notifier).clearHistory();
```

### 5. 更新观看进度

```dart
ref.read(historyNotifierProvider.notifier).updateHistoryProgress(
  record,
  newProgress,
  newDuration,
);
```

## 优势

1. **解耦**: 各层之间通过接口交互，降低耦合度
2. **可测试**: 易于编写单元测试和集成测试
3. **可维护**: 清晰的架构便于后续维护
4. **可扩展**: 新功能添加不会影响现有代码
5. **类型安全**: 使用 Dart 的强类型系统
6. **响应式**: Riverpod 提供响应式状态管理

## 迁移指南

从旧的 Provider 架构迁移到 Riverpod：

1. 移除 `ChangeNotifierProvider`
2. 使用 `ConsumerWidget` 替代 `StatelessWidget`
3. 使用 `WidgetRef` 访问状态
4. 使用 `StateNotifierProvider` 管理状态

## 最佳实践

- 使用 `const` 构造函数优化性能
- 使用 `ValueKey` 确保列表项的唯一性
- 实现撤销删除功能
- 提供错误处理和重试机制
- 使用防抖机制避免频繁刷新