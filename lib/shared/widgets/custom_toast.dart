import 'package:flutter/material.dart';

/// 自定义Toast控件，支持多条消息同时显示
class CustomToast {
  static final List<_ToastEntry> _toastEntries = [];
  static const int _maxToasts = 3;
  static const Duration _defaultDuration = Duration(seconds: 2);

  /// 显示Toast消息
  static void show(
    BuildContext context, {
    required String message,
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.bottom,
  }) {
    // 如果超过最大数量，移除最旧的
    if (_toastEntries.length >= _maxToasts) {
      _toastEntries.last.overlayEntry.remove();
      _toastEntries.removeLast();
    }

    // 将所有现有Toast的索引+1，为新Toast让出位置0
    for (int i = 0; i < _toastEntries.length; i++) {
      _toastEntries[i] = _ToastEntry(
        overlayEntry: _toastEntries[i].overlayEntry,
        index: _toastEntries[i].index + 1,
      );
    }

    // 根据类型设置默认颜色
    final colors = _getColorsForType(type, backgroundColor, textColor);

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    // 新Toast的索引为0（最顶部）
    final newIndex = 0;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        duration: duration ?? _defaultDuration,
        backgroundColor: colors.backgroundColor,
        textColor: colors.textColor,
        icon: icon ?? colors.icon,
        onDismiss: () => _removeToast(overlayEntry),
        index: newIndex,
        position: position,
      ),
    );

    final toastEntry = _ToastEntry(
      overlayEntry: overlayEntry,
      index: newIndex,
    );
    
    // 将新Toast插入到列表开头
    _toastEntries.insert(0, toastEntry);
    overlay.insert(overlayEntry);
  }

  /// 显示成功消息
  static void success(
    BuildContext context, {
    required String message,
    Duration? duration,
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      duration: duration,
      type: ToastType.success,
      position: position,
    );
  }

  /// 显示错误消息
  static void error(
    BuildContext context, {
    required String message,
    Duration? duration,
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      duration: duration,
      type: ToastType.error,
      position: position,
    );
  }

  /// 显示警告消息
  static void warning(
    BuildContext context, {
    required String message,
    Duration? duration,
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      duration: duration,
      type: ToastType.warning,
      position: position,
    );
  }

  /// 显示信息消息
  static void info(
    BuildContext context, {
    required String message,
    Duration? duration,
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      duration: duration,
      type: ToastType.info,
      position: position,
    );
  }

  /// 移除指定的Toast
  static void _removeToast(OverlayEntry entry) {
    entry.remove();
    
    // 找到要移除的Toast的索引
    int removedIndex = -1;
    for (int i = 0; i < _toastEntries.length; i++) {
      if (_toastEntries[i].overlayEntry == entry) {
        removedIndex = i;
        break;
      }
    }
    
    if (removedIndex != -1) {
      _toastEntries.removeAt(removedIndex);
      
      // 重新调整索引：移除位置之后的Toast索引-1
      for (int i = removedIndex; i < _toastEntries.length; i++) {
        _toastEntries[i] = _ToastEntry(
          overlayEntry: _toastEntries[i].overlayEntry,
          index: _toastEntries[i].index - 1,
        );
      }
    }
  }

  /// 清除所有Toast
  static void clearAll() {
    for (final toast in _toastEntries) {
      toast.overlayEntry.remove();
    }
    _toastEntries.clear();
  }

  /// 根据类型获取颜色
  static _ToastColors _getColorsForType(
    ToastType type,
    Color? backgroundColor,
    Color? textColor,
  ) {
    switch (type) {
      case ToastType.success:
        return _ToastColors(
          backgroundColor: backgroundColor ?? Colors.green,
          textColor: textColor ?? Colors.white,
          icon: Icons.check_circle,
        );
      case ToastType.error:
        return _ToastColors(
          backgroundColor: backgroundColor ?? Colors.red,
          textColor: textColor ?? Colors.white,
          icon: Icons.error,
        );
      case ToastType.warning:
        return _ToastColors(
          backgroundColor: backgroundColor ?? Colors.orange,
          textColor: textColor ?? Colors.white,
          icon: Icons.warning,
        );
      case ToastType.info:
        return _ToastColors(
          backgroundColor: backgroundColor ?? Colors.blue,
          textColor: textColor ?? Colors.white,
          icon: Icons.info,
        );
    }
  }
}

/// Toast类型枚举
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Toast位置枚举
enum ToastPosition {
  top,
  bottom,
}

/// Toast条目
class _ToastEntry {
  final OverlayEntry overlayEntry;
  final int index;

  _ToastEntry({
    required this.overlayEntry,
    required this.index,
  });
}

/// Toast颜色配置
class _ToastColors {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  _ToastColors({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

/// Toast组件
class _ToastWidget extends StatefulWidget {
  final String message;
  final Duration duration;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback onDismiss;
  final int index;
  final ToastPosition position;

  const _ToastWidget({
    required this.message,
    required this.duration,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onDismiss,
    required this.index,
    required this.position,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.position == ToastPosition.top 
          ? const Offset(0.0, -1.0) // 从顶部滑入
          : const Offset(0.0, 1.0), // 从底部滑入
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // 开始动画
    _animationController.forward();

    // 设置自动消失
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void didUpdateWidget(_ToastWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      setState(() {
        _currentIndex = widget.index;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    
    // 计算位置 - 新Toast在顶部，旧Toast向下移动
    double topOffset;
    if (widget.position == ToastPosition.top) {
      // 新Toast（index=0）在顶部，旧Toast向下移动
      // index=0 是最新的Toast，在顶部
      // index=1 是第二新的Toast，在下方50px
      // index=2 是第三新的Toast，在下方100px
      topOffset = padding.top + 10 + (_currentIndex * 50);
    } else {
      topOffset = screenHeight - padding.bottom - 60 - (_currentIndex * 50);
    }
    
    return Positioned(
      top: topOffset,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: screenWidth - 32,
                minHeight: 40,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.backgroundColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.textColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close,
                      color: widget.textColor.withOpacity(0.6),
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
