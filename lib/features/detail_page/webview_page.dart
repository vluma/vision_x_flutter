import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _canGoBack = false;

  // 验证并修复URL格式，将桌面版豆瓣链接转换为移动版
  String _validateUri(String url) {
    // 处理空URL的情况
    if (url.isEmpty) {
      return 'about:blank';
    }
    
    // 检查是否包含协议头
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // 如果没有协议头，添加https://
      url = 'https://$url';
    }
    
    // 将豆瓣桌面版链接转换为移动版
    if (url.contains('movie.douban.com/subject/')) {
      url = url.replaceAll('movie.douban.com/subject/', 'm.douban.com/subject/');
    }
    
    return url;
  }

  // 处理返回按钮点击事件
  Future<void> _handleBackButton() async {
    if (_canGoBack) {
      // 如果WebView可以返回，则返回上一页
      await _controller.goBack();
    } else {
      // 否则关闭当前页面
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final validatedUrl = _validateUri(widget.url);
    print('Loading URL: $validatedUrl'); // 调试信息
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            // 更新返回状态
            final canGoBack = await _controller.canGoBack();
            if (mounted) {
              setState(() {
                _canGoBack = canGoBack;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // 处理网页加载错误
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('网页加载出错: ${error.description}'),
                ),
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // 拦截外部链接，防止跳转到不需要的页面
            final url = request.url;
            // 屏蔽分析和跟踪服务
            final blockedDomains = [
              'google-analytics.com',
              'region1.google-analytics.com',
              'netease.com',
              'ydstatic.com',
              'youdao.com',
              'doubleclick.net',
              'googlesyndication.com',
              'adservice.google.com'
            ];
            
            for (var i = 0; i < blockedDomains.length; i++) {
              if (url.contains(blockedDomains[i])) {
                print('Blocked tracking request: ' + url);
                return NavigationDecision.prevent;
              }
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setUserAgent("Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1")
      ..addJavaScriptChannel(
        'SnackBar',
        onMessageReceived: (JavaScriptMessage message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          }
        },
      )
      ..loadRequest(
        Uri.parse(validatedUrl),
        headers: {
          "Referer": "https://m.douban.com/",
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
          "Accept-Language": "zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7",
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    // 检查URL是否有效
    if (widget.url.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('无效链接'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('链接地址为空，无法显示网页内容'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackButton,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      // 隐藏底部导航栏，因为这是二级页面
      bottomNavigationBar: const SizedBox.shrink(),
    );
  }
}