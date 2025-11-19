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

  // 验证并修复URL格式
  String _validateUri(String url) {
    // 处理空URL的情况
    if (url.isEmpty) {
      return 'about:blank';
    }
    
    // 检查是否包含协议头
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // 如果没有协议头，添加https://
      return 'https://$url';
    }
    return url;
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
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
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
        ),
      )
      ..loadRequest(Uri.parse(validatedUrl));
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
          onPressed: () => Navigator.of(context).pop(),
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
    );
  }
}