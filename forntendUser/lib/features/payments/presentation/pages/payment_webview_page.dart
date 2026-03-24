import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String sessionId;

  const PaymentWebViewPage({
    Key? key,
    required this.paymentUrl,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            print('🌐 Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            print('✅ Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = error.description;
            });
            print('❌ WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            print('🔗 Navigation request: $url');

            // Check for success callback
            if (url.contains('/callback/success')) {
              print('✅ Payment successful!');
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }

            // Check for error callback
            if (url.contains('/callback/error')) {
              print('❌ Payment failed!');
              _handlePaymentError();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.paymentUrl),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'BNPL-Flutter-App',
        },
      );
  }

  void _handlePaymentSuccess() {
    // Navigate back with success
    Navigator.of(context).pop(true);
  }

  void _handlePaymentError() {
    // Navigate back with failure
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'إتمام الدفع',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () {
            _showCancelDialog();
          },
        ),
      ),
      body: Stack(
        children: [
          if (_error != null)
            _buildErrorView()
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF10B981),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'جاري تحميل صفحة الدفع...',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'فشل تحميل صفحة الدفع',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'حدث خطأ غير متوقع',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _initializeWebView();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'إلغاء الدفع',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من إلغاء عملية الدفع؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'لا',
              style: GoogleFonts.cairo(color: const Color(0xFF757575)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(false); // Close WebView with failure
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'نعم، إلغاء',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
