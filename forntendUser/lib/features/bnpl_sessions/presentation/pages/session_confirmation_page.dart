import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bnpl/config/env/env_dev.dart';
import 'package:bnpl/features/bnpl_sessions/data/bnpl_session_service.dart';
import 'package:bnpl/features/payments/presentation/pages/payment_webview_page.dart';
import '../../models/bnpl_session.dart';
import '../../data/bnpl_session_service.dart';
import '../widgets/pin_verification_dialog.dart';
import '../widgets/otp_verification_dialog.dart';
import '../../../payments/presentation/pages/payment_webview_page.dart';

class SessionConfirmationPage extends StatefulWidget {
  final String sessionId;

  const SessionConfirmationPage({
    Key? key,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<SessionConfirmationPage> createState() =>
      _SessionConfirmationPageState();
}

class _SessionConfirmationPageState extends State<SessionConfirmationPage> {
  final BnplSessionService _sessionService = BnplSessionService();
  BnplSession? _session;
  bool _isLoading = true;
  String? _error;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('🔍 Fetching session: ${widget.sessionId}');
      final session = await _sessionService.getSession(widget.sessionId);
      
      // DEBUG: Log session details to see items
      print('📦 Session Loaded: ${session.sessionId}');
      print('📦 Store: ${session.store.name} (Logo: ${session.store.logoUrl})');
      print('📦 Items Count: ${session.items.length}');
      for (var item in session.items) {
        print('   - Item: ${item.name}, Price: ${item.price}, Image: ${item.image}');
      }

      setState(() {
        _session = session;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading session: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _approveAndPay() async {
    if (_session == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final totalAmount = _session!.totalAmount;
      bool verified = false;

      if (totalAmount >= 300) {
        verified = await _verifyWithOTP();
      } else {
        verified = await _verifyWithPIN();
      }

      if (!verified) {
        setState(() => _isProcessing = false);
        return;
      }

      // First approve to set userId (but session stays PENDING for now)
      // This is needed so completeSession can find the userId
      await _sessionService.approveSession(widget.sessionId);
      
      // Get payment URL (Stripe Checkout Session)
      final installmentAmount = totalAmount / _session!.installmentsCount;
      final result = await _sessionService.initiateStripePayment(
        sessionId: widget.sessionId,
        amount: installmentAmount,
        currency: _session!.currency,
      );
      
      print('📦 Stripe session result: $result');

      if (mounted) {
        // Check if payment is required
        if (result['success'] == true && result['data'] != null && result['data']['url'] != null) {
          final paymentUrl = result['data']['url'];
          print('💳 Opening Stripe WebView: $paymentUrl');

          // Open payment WebView
          final paymentSuccess = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebViewPage(
                paymentUrl: paymentUrl,
                sessionId: widget.sessionId,
              ),
            ),
          );

          if (paymentSuccess == true) {
            // Payment successful - mark first installment as completed
            try {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('auth_token');
              
              if (token != null) {
                final response = await http.post(
                  Uri.parse('${EnvDev.baseUrl}/payments/complete-first-installment'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: json.encode({'sessionId': widget.sessionId}),
                );

                if (response.statusCode == 201 || response.statusCode == 200) {
                  print('✅ First installment marked as completed');
                }
              }
            } catch (e) {
              print('⚠️ Error marking first installment: $e');
            }

            // Approve session to finalize
            await _sessionService.approveSession(widget.sessionId);
            
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ تم الدفع بنجاح! تم إنشاء ${_session!.installmentsCount} أقساط'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            // Payment failed or cancelled - session stays PAYMENT_PENDING
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '❌ تم إلغاء الدفع - الطلب لم يتم الموافقة عليه',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFE53935),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 4),
              ),
            );
            
            // Stay on current page - user can try again
            print('⚠️ Payment cancelled - session remains PAYMENT_PENDING');
          }
        } else {
          // No payment required (shouldn't happen in new flow)
          await _sessionService.approveSession(widget.sessionId);
          
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم إنشاء ${_session!.installmentsCount} أقساط بنجاح'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error in _approveAndPay: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _verifyWithPIN() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinVerificationDialog(
        onVerified: () {},
        onCancel: () {},
      ),
    );
    return result ?? false;
  }

  Future<bool> _verifyWithOTP() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('user_phone') ?? '+962792380449';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationDialog(
        phoneNumber: phoneNumber,
        onVerified: () {},
        onCancel: () {},
      ),
    );
    return result ?? false;
  }

  Future<void> _reject() async {
    if (_session == null || _isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      await _sessionService.rejectSession(widget.sessionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم رفض الطلب'),
            backgroundColor: const Color(0xFFFF9800),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
            : _error != null
                ? _buildErrorState()
                : _session == null
                    ? const Center(child: Text('لا توجد بيانات'))
                    : _buildContent(),
      ),
    );
  }

  Widget _buildErrorState() {
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
              child: const Icon(Icons.error_outline, size: 48, color: Color(0xFFE53935)),
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStoreCard(),
          const SizedBox(height: 16),
          _buildItemsList(),
          const SizedBox(height: 16),
          _buildAmountCard(),
          const SizedBox(height: 16),
          _buildInstallmentCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    print('📦 Session Items count: ${_session!.items.length}');
    
    if (_session!.items.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.shopping_basket_outlined, size: 40, color: Colors.orange),
            const SizedBox(height: 12),
            Text(
              'لا توجد تفاصيل للمنتجات في هذا الطلب',
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'تفاصيل المنتجات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        ..._session!.items.map((item) => _buildItemTile(item)).toList(),
      ],
    );
  }

  Widget _buildItemTile(SessionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF5F7FA),
              image: item.image != null
                  ? DecorationImage(
                      image: NetworkImage(item.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.image == null
                ? const Icon(Icons.shopping_bag_outlined, color: Color(0xFF9E9E9E))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  'الكمية: ${item.quantity}',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.price.toStringAsFixed(2)} ${_session!.currency}',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: _session!.store.logoUrl == null
                  ? const LinearGradient(
                      colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _session!.store.logoUrl == null ? null : const Color(0xFFF5F7FA),
              image: _session!.store.logoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_session!.store.logoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _session!.store.logoUrl == null
                ? Center(
                    child: Text(
                      _session!.store.nameAr.isNotEmpty 
                        ? _session!.store.nameAr[0] 
                        : _session!.store.name.isNotEmpty 
                          ? _session!.store.name[0] 
                          : 'S',
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _session!.store.nameAr.isNotEmpty ? _session!.store.nameAr : _session!.store.name,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'طلب من ${_session!.store.name}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الطلب',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'المبلغ الإجمالي',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              Text(
                '${_session!.totalAmount.toStringAsFixed(2)} ${_session!.currency}',
                style: GoogleFonts.cairo(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عدد الأقساط',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                '${_session!.installmentsCount} أقساط',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قيمة كل قسط',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                '${_session!.installmentAmount.toStringAsFixed(2)} ${_session!.currency}',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خطة الأقساط',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.08),
                  const Color(0xFF059669).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'القسط الأول (اليوم)',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_session!.installmentAmount.toStringAsFixed(2)} ${_session!.currency}',
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Color(0xFF757575),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'الأقساط المتبقية: ${_session!.installmentsCount - 1} أقساط شهرية',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: const Color(0xFF424242),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _approveAndPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'موافقة ودفع القسط الأول',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton(
            onPressed: _isProcessing ? null : _reject,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
              side: const BorderSide(color: Color(0xFFE53935), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cancel_outlined, size: 22),
                const SizedBox(width: 12),
                Text(
                  'رفض الطلب',
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
