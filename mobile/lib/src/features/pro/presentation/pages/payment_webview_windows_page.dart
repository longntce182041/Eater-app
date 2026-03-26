import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

import 'payment_webview_page.dart';

class PaymentWebViewWindowsPage extends StatefulWidget {
  final String checkoutUrl;
  final String returnUrl;
  final String cancelUrl;

  const PaymentWebViewWindowsPage({
    super.key,
    required this.checkoutUrl,
    required this.returnUrl,
    required this.cancelUrl,
  });

  @override
  State<PaymentWebViewWindowsPage> createState() =>
      _PaymentWebViewWindowsPageState();
}

class _PaymentWebViewWindowsPageState extends State<PaymentWebViewWindowsPage> {
  final WebviewController _controller = WebviewController();
  StreamSubscription<String>? _urlSub;
  bool _isReady = false;
  bool _didFinish = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      await _controller.initialize();
      await _controller.loadUrl(widget.checkoutUrl);

      _urlSub = _controller.url.listen((url) {
        final result = _handleRedirect(url);
        if (result != null) {
          _finish(result);
        }
      });

      if (!mounted) return;
      setState(() => _isReady = true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
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
    if (!mounted || _didFinish) return;
    _didFinish = true;
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _urlSub?.cancel();
    _controller.dispose();
    super.dispose();
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
      body: Builder(
        builder: (_) {
          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Khong the khoi tao WebView tren Windows.\n$_error',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!_isReady) {
            return const Center(child: CircularProgressIndicator());
          }

          return Webview(_controller);
        },
      ),
    );
  }
}
