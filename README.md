# vision_x_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project Structure

```
// 项目目录结构 (仅展示关键开发相关文件和文件夹)
├── .gitignore               // Git忽略文件配置
├── .vscode\                 // VSCode编辑器配置
│   ├── launch.json          // 调试启动配置
│   └── tasks.json           // 任务配置
├── README.md                // 项目说明文档
├── analysis_options.yaml    // Dart代码分析配置
├── android\                 // Android平台相关代码
│   ├── app\                 // Android应用模块
│   │   ├── build.gradle.kts // Android模块构建配置
│   │   └── src\             // Android源代码
│   ├── build.gradle.kts     // Android项目构建配置
│   ├── gradle.properties    // Gradle属性配置
│   ├── gradlew              // Gradle构建脚本(UNIX)
│   ├── gradlew.bat          // Gradle构建脚本(Windows)
│   └── settings.gradle.kts  // Gradle设置
├── ios\                     // iOS平台相关代码
│   ├── Flutter\            // Flutter iOS集成文件
│   ├── Runner\             // iOS应用代码
│   ├── Runner.xcodeproj\   // Xcode项目文件
│   └── Runner.xcworkspace\ // Xcode工作区文件
├── lib\                     // Flutter源代码 (核心开发目录)
│   ├── app_router.dart      // 应用路由配置
│   ├── components\         // 通用组件
│   │   └── bottom_navigation_bar.dart // 底部导航栏组件
│   ├── main.dart            // 应用入口文件
│   └── pages\              // 页面组件
│       ├── history_page.dart // 历史记录页面
│       ├── home_page.dart   // 首页
│       └── settings_page.dart // 设置页面
├── linux\                   // Linux平台相关代码
├── macos\                   // macOS平台相关代码
├── pubspec.lock             // 依赖版本锁定文件
├── pubspec.yaml             // 项目依赖配置文件
├── test\                    // 测试代码
│   └── widget_test.dart     // 组件测试示例
├── web\                     // Web平台相关代码
│   ├── favicon.png          // 网站图标
│   ├── icons\              // Web应用图标
│   ├── index.html           // Web入口HTML文件
│   └── manifest.json        // Web应用清单
└── windows\                // Windows平台相关代码
```
