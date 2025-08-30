# 主题迁移指南

## 背景

为了优化项目结构，我们将主题相关文件从 `lib/theme/` 移动到 `lib/core/themes/` 目录下。这样可以更好地组织代码，使项目结构更加清晰。

## 迁移步骤

### 1. 更新导入路径

将所有导入主题相关文件的语句从旧路径更新为新路径：

```dart
// 旧的导入方式
import 'package:vision_x_flutter/theme/app_theme.dart';
import 'package:vision_x_flutter/theme/colors.dart';
import 'package:vision_x_flutter/theme/spacing.dart';
import 'package:vision_x_flutter/theme/theme_provider.dart';
```

更新为：

```dart
// 新的导入方式 - 方法1：单独导入
import 'package:vision_x_flutter/core/themes/app_theme.dart';
import 'package:vision_x_flutter/core/themes/colors.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'package:vision_x_flutter/core/themes/theme_provider.dart';

// 新的导入方式 - 方法2：使用索引文件（推荐）
import 'package:vision_x_flutter/core/themes/index.dart';
```

### 2. 需要更新的文件

根据搜索结果，以下文件需要更新导入路径：

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

### 3. 更新示例

以 `lib/components/bottom_navigation_bar.dart` 为例：

```dart
// 旧的导入
import 'package:vision_x_flutter/theme/colors.dart';

// 更新为
import 'package:vision_x_flutter/core/themes/colors.dart';
// 或者使用索引文件
import 'package:vision_x_flutter/core/themes/index.dart';
```

## 注意事项

1. 更新导入路径后，请确保运行 `flutter pub get` 更新依赖
2. 如果遇到编译错误，请检查导入路径是否正确
3. 建议使用索引文件 `import 'package:vision_x_flutter/core/themes/index.dart'` 简化导入
4. 旧的 `lib/theme/` 目录已被移除，所有文件已备份到 `lib/theme_backup/`

## 其他变更

除了主题文件的移动，我们还进行了以下结构优化：

1. 创建了 `lib/app/` 目录，包含应用入口、路由配置和依赖注入
2. 创建了 `lib/core/` 目录，包含核心功能如常量、工具类、网络处理和异常处理

这些变更旨在使项目结构更加清晰，便于团队协作和未来扩展。