# 项目结构更新计划

## 已完成的工作

1. 创建了新的目录结构：
   - `lib/app/` - 应用核心
   - `lib/core/` - 核心功能，包括主题

2. 将主题文件从 `lib/theme/` 移动到 `lib/core/themes/`：
   - `lib/core/themes/app_theme.dart`
   - `lib/core/themes/colors.dart`
   - `lib/core/themes/spacing.dart`
   - `lib/core/themes/theme_provider.dart`
   - `lib/core/themes/index.dart`（导出所有主题文件）

3. 更新了 `lib/app/app.dart` 中的导入路径。

4. 创建了迁移指南 `lib/core/MIGRATION_GUIDE.md`。

## 待完成的工作

### 1. 更新导入路径

以下文件需要更新导入路径：

1. lib/components/bottom_navigation_bar.dart
2. lib/pages/search/search_page.dart
3. lib/pages/search/components/source_group.dart
4. lib/components/custom_card.dart
5. lib/pages/history/widgets/history_list.dart
6. lib/pages/search/components/category_tabs.dart
7. lib/pages/settings/settings_page.dart
8. lib/pages/home/widgets/video_grid.dart
9. lib/pages/home/widgets/loading_skeleton.dart
10. lib/pages/settings/components/theme_section.dart
11. lib/pages/settings/components/data_source_section.dart
12. lib/pages/settings/components/feature_switch_section.dart
13. lib/pages/settings/components/custom_api_section.dart
14. lib/pages/settings/components/general_functions_section.dart
15. lib/pages/settings/settings_controller.dart

### 2. 修复编译错误

1. 在 `lib/core/network/network_info.dart` 中，需要添加 `connectivity_plus` 依赖。

2. 在 `lib/core/themes/theme_provider.dart` 中，修复构造函数参数重复的问题。

### 3. 创建其他核心目录

1. 创建 `lib/core/constants/` 目录，用于存放常量定义。

2. 创建 `lib/core/utilities/` 目录，用于存放工具类。

3. 创建 `lib/core/exceptions/` 目录，用于存放异常处理。

### 4. 更新 pubspec.yaml

添加 `connectivity_plus` 依赖：

```yaml
dependencies:
  connectivity_plus: ^5.0.1  # 用于网络连接检测
```

## 执行步骤

1. 首先更新 `pubspec.yaml`，添加必要的依赖。

2. 然后创建其他核心目录和文件。

3. 接着修复编译错误。

4. 最后更新所有文件的导入路径。

## 注意事项

1. 在更新导入路径时，可以使用 `lib/core/themes/index.dart` 简化导入。

2. 确保在修改文件前先备份。

3. 修改完成后，运行 `flutter pub get` 更新依赖。

4. 最后运行 `flutter run` 测试应用是否正常运行。