import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String successUrl;
  final String failureUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    this.successUrl = 'https://yourdomain.com/tap/callback', // Default callback
    this.failureUrl = 'https://yourdomain.com/tap/callback', // Usually same for Tap redirect
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
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
            debugPrint('WebResourceError: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigating to: ${request.url}');
            if (request.url.startsWith(widget.successUrl)) {
              // Extract status from URL if available, or just return success
              _handleCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _handleCallback(String url) {
    debugPrint('Payment callback detected: $url');
    final uri = Uri.parse(url);
    final tapId = uri.queryParameters['tap_id'];
    
    // Return tap_id (chargeId) to the previous screen
    Navigator.of(context).pop(tapId ?? url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.confirmYourPayment),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
