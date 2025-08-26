# 左滑返回功能说明

## 功能概述

本项目已为二级页面添加了左滑返回功能，用户可以通过从屏幕左边缘向右滑动来返回上一个页面，提供更流畅的导航体验。

## 实现组件

### 1. SwipeBackGesture
通用左滑返回手势组件，适用于普通页面。

**特性：**
- 从屏幕左边缘50像素内开始滑动
- 滑动阈值：屏幕宽度的1/3
- 支持快速滑动（速度大于500像素/秒）
- 平滑的动画效果

**使用方法：**
```dart
SwipeBackGesture(
  onBackPressed: () {
    Navigator.of(context).pop();
  },
  child: Scaffold(
    // 你的页面内容
  ),
)
```

### 2. VideoSwipeBackGesture
专门为视频播放页面优化的左滑返回手势组件。

**特性：**
- 从屏幕左边缘30像素内开始滑动
- 滑动阈值：屏幕宽度的1/4
- 只处理向右的滑动，避免与视频控制手势冲突
- 更快的动画速度（250毫秒）

**使用方法：**
```dart
VideoSwipeBackGesture(
  onBackPressed: () {
    Navigator.of(context).pop();
  },
  child: Scaffold(
    // 视频播放页面内容
  ),
)
```

## 已集成的页面

### 1. 详情页面 (DetailPage)
- 文件：`lib/pages/detail_page.dart`
- 使用：`SwipeBackGesture`
- 功能：从电影/电视剧详情页左滑返回

### 2. 视频播放页面 (VideoPlayerPage)
- 文件：`lib/pages/video_player_page.dart`
- 使用：`VideoSwipeBackGesture`
- 功能：从视频播放页左滑返回
- 支持短剧模式和传统模式

### 3. 测试页面 (TestSwipePage)
- 文件：`lib/pages/test_swipe_page.dart`
- 使用：`SwipeBackGesture`
- 功能：用于测试左滑返回功能

## 测试方法

1. 启动应用
2. 在主页右上角点击左滑图标进入测试页面
3. 在测试页面中从屏幕左边缘向右滑动
4. 或者进入任意详情页面或视频播放页面测试左滑返回

## 技术实现

### 手势检测
- 使用 `GestureDetector` 监听水平拖动手势
- 限制滑动起始位置在屏幕左边缘
- 计算滑动距离和速度来判断是否触发返回

### 动画效果
- 使用 `AnimationController` 控制滑动动画
- 页面跟随手指移动，提供实时反馈
- 根据滑动结果执行返回或回弹动画

### 冲突处理
- 视频播放页面使用专门的组件避免与视频控制手势冲突
- 设置合适的滑动阈值和速度阈值
- 使用 `HitTestBehavior.translucent` 确保手势正确传递

## 自定义配置

### SwipeBackGesture 参数
- `enableSwipeBack`: 是否启用左滑返回（默认：true）
- `swipeThreshold`: 滑动阈值比例（默认：0.33）
- `animationDuration`: 动画持续时间（默认：300毫秒）

### VideoSwipeBackGesture 参数
- `enableSwipeBack`: 是否启用左滑返回（默认：true）
- `swipeThreshold`: 滑动阈值比例（默认：0.25）
- `animationDuration`: 动画持续时间（默认：250毫秒）

## 注意事项

1. 左滑返回功能只在二级页面启用，主页面不启用
2. 视频播放页面的左滑返回经过特殊优化，避免与视频控制冲突
3. 滑动手势只在屏幕左边缘有效，避免误触
4. 支持快速滑动和慢速滑动两种触发方式
