import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PaymentWebViewResult { success, cancel, failed, unknown }

class PaymentWebViewPage extends StatefulWidget {
  final String checkoutUrl;
  final String returnUrl;
  final String cancelUrl;

  const PaymentWebViewPage({
    super.key,
    required this.checkoutUrl,
    required this.returnUrl,
    required this.cancelUrl,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onNavigationRequest: (request) {
            final decision = _handleRedirect(request.url);
            if (decision != null) {
              _finish(decision);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  PaymentWebViewResult? _handleRedirect(String url) {
    final current = Uri.tryParse(url);
    final returnUri = Uri.tryParse(widget.returnUrl);
    final cancelUri = Uri.tryParse(widget.cancelUrl);

    if (current == null || returnUri == null || cancelUri == null) {
      return null;
    }

    if (_isSameRoute(current, cancelUri)) {
      return PaymentWebViewResult.cancel;
    }

    if (_isSameRoute(current, returnUri)) {
      return _mapResultFromReturnUrl(current);
    }

    return null;
  }

  bool _isSameRoute(Uri current, Uri target) {
    return current.scheme == target.scheme &&
        current.host == target.host &&
        current.path == target.path;
  }

  PaymentWebViewResult _mapResultFromReturnUrl(Uri uri) {
    final code = (uri.queryParameters['code'] ?? '').toUpperCase();
    final status = (uri.queryParameters['status'] ?? '').toUpperCase();
    final cancel = (uri.queryParameters['cancel'] ?? '').toLowerCase();

    if (cancel == 'true' || status.contains('CANCEL')) {
      return PaymentWebViewResult.cancel;
    }

    if (code == '00' || status.contains('PAID') || status.contains('SUCCESS')) {
      return PaymentWebViewResult.success;
    }

    if (code.isNotEmpty || status.isNotEmpty) {
      return PaymentWebViewResult.failed;
    }

    return PaymentWebViewResult.unknown;
  }

  void _finish(PaymentWebViewResult result) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayOS Payment'),
        actions: [
          IconButton(
            onPressed: () => _finish(PaymentWebViewResult.cancel),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100)
            LinearProgressIndicator(value: _progress / 100.0),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
