# 核心模块

本目录包含应用程序的核心功能模块，包括：

- constants: 常量定义
- exceptions: 异常处理
- network: 网络处理
- themes: 主题定义
- utilities: 工具类

## 依赖安装

请在项目的pubspec.yaml文件中添加以下依赖：

```yaml
dependencies:
  connectivity_plus: ^5.0.1
  intl: ^0.18.1
```

添加后运行:

```bash
flutter pub get
```

来安装这些依赖。

## 目录结构说明

- constants: 存放应用程序中使用的常量，如API端点、配置值等
- exceptions: 定义应用程序中可能出现的异常类型
- network: 处理网络请求和连接状态
- themes: 定义应用程序的主题、颜色和间距
- utilities: 提供各种实用工具函数

## 使用方法

在需要使用这些模块的文件中，使用以下方式导入：

```dart
// 导入主题
import 'package:vision_x_flutter/core/themes/index.dart';

// 导入网络模块
import 'package:vision_x_flutter/core/network/network_info.dart';

// 导入常量
import 'package:vision_x_flutter/core/constants/app_constants.dart';