# Vision X Flutter

一个功能完善的视频播放应用，支持竖屏短剧和横屏传统视频播放。

## 功能特性

### 视频播放功能

#### 竖屏短剧模式
- **抖音风格播放**：全屏竖屏播放，上下滑动切换剧集
- **智能控制**：
  - 左上角返回按钮
  - 底部进度条显示
  - 可展开的导航信息栏，显示剧集信息和选集功能
  - 长按右侧2倍速快进
- **自动播放**：播放结束后自动切换下一集
- **预加载**：本集快结束时提前加载下一集缓存

#### 横屏传统模式
- **非全屏模式**：
  - 左上角返回按钮
  - 左下方播放/暂停按钮
  - 进度条和时间显示
  - 全屏切换按钮
- **全屏模式**：
  - 左上角返回按钮 + 剧集信息
  - 进度条
  - 播放/暂停、上一集/下一集按钮
  - 倍速控制、选集功能
  - 锁定屏幕功能

### 核心组件

#### CustomVideoPlayer
主要的视频播放器组件，支持：
- 自动播放和循环控制
- 进度跟踪和历史记录
- 播放完成回调
- 视频时长获取
- 起始位置设置
- 短剧模式识别

#### CustomControls
自定义视频控制组件，提供：
- 返回按钮处理
- 剧集切换控制
- 播放速度调节
- 全屏切换
- 竖屏模式导航栏
- 长按快进快退

#### VideoPlayerPage
视频播放页面，实现：
- 竖屏/横屏模式自动识别
- PageView滑动切换（短剧模式）
- 历史记录管理
- 预加载功能
- 剧集选择器

## 使用方法

### 基本使用

```dart
// 创建视频播放页面
VideoPlayerPage(
  media: mediaDetail,
  episode: episode,
  startPosition: 0, // 起始播放位置（秒）
)
```

### 自定义播放器

```dart
CustomVideoPlayer(
  media: mediaDetail,
  episode: episode,
  isShortDramaMode: true, // 是否为短剧模式
  onProgressUpdate: (progress) {
    // 进度更新回调
  },
  onPlaybackCompleted: () {
    // 播放完成回调
  },
  onBackPressed: () {
    // 返回按钮回调
  },
  onNextEpisode: () {
    // 下一集回调
  },
  onPrevEpisode: () {
    // 上一集回调
  },
  onEpisodeChanged: (index) {
    // 剧集切换回调
  },
)
```

### 自定义控制组件

```dart
CustomControls(
  isShortDramaMode: true,
  onBackPressed: () => Navigator.pop(context),
  onNextEpisode: () => playNext(),
  onPrevEpisode: () => playPrev(),
  onEpisodeChanged: (index) => changeEpisode(index),
  mediaTitle: "剧集标题",
  currentEpisodeIndex: 0,
  totalEpisodes: 10,
)
```

## 模式识别

应用会自动识别视频类型：

### 短剧模式
- 通过 `media.category` 或 `media.type` 字段判断
- 包含"短剧"关键词的视频自动启用竖屏模式
- 支持上下滑动切换剧集

### 传统模式
- 其他类型的视频使用横屏模式
- 支持全屏切换
- 提供完整的播放控制功能

## 技术特性

- **响应式设计**：适配不同屏幕尺寸
- **性能优化**：预加载机制提升播放体验
- **历史记录**：自动保存播放进度
- **手势控制**：支持长按快进快退
- **主题适配**：支持深色/浅色主题切换

## 依赖项

```yaml
dependencies:
  flutter:
    sdk: flutter
  video_player: ^2.8.1
  chewie: ^1.7.4
  cached_network_image: ^3.3.0
```

## 注意事项

1. 确保视频URL可访问且格式支持
2. 短剧模式需要正确的分类信息
3. 预加载功能需要网络连接
4. 历史记录功能需要配置存储服务

## 更新日志

### v1.0.0
- 初始版本发布
- 支持竖屏和横屏两种播放模式
- 实现自动播放和剧集切换
- 添加预加载和历史记录功能
