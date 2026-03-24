import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../../services/auth_service.dart';

/// Dialog for OTP verification
/// Used for BNPL session approval when amount >= 300 JOD
class OtpVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerified;
  final VoidCallback onCancel;

  const OtpVerificationDialog({
    Key? key,
    required this.phoneNumber,
    required this.onVerified,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final _otpController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _isSendingOtp = false;
  String? _errorMessage;
  bool _otpSent = false;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.sendOTPToPhone(widget.phoneNumber);

      if (response['success']) {
        setState(() {
          _otpSent = true;
          _isSendingOtp = false;
        });
        _startResendCountdown();
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'فشل إرسال رمز التحقق';
          _isSendingOtp = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: ${e.toString()}';
        _isSendingOtp = false;
      });
    }
  }

  void _startResendCountdown() {
    _resendCountdown = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendCountdown > 0) {
        setState(() => _resendCountdown--);
        return true;
      }
      return false;
    });
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.verifyOTPCode(widget.phoneNumber, otp);

      if (response['success']) {
        // OTP correct
        widget.onVerified();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // OTP incorrect
        setState(() {
          _errorMessage = response['error'] ?? 'رمز التحقق غير صحيح';
          _isLoading = false;
        });
        _otpController.clear();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: ${e.toString()}';
        _isLoading = false;
      });
      _otpController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF667eea), width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red, width: 2),
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android,
                size: 32,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'تحقق من رقم الهاتف',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Phone Number
            Text(
              'تم إرسال رمز التحقق إلى\n${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Loading while sending OTP
            if (_isSendingOtp) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('جاري إرسال رمز التحقق...'),
            ] else if (_otpSent) ...[
              // OTP Input
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: _errorMessage != null ? errorPinTheme : null,
                  enabled: !_isLoading,
                  onCompleted: _verifyOtp,
                  autofocus: true,
                ),
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Loading Indicator
              if (_isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],

              const SizedBox(height: 16),

              // Resend Button
              TextButton(
                onPressed: _resendCountdown == 0 && !_isLoading
                    ? _sendOtp
                    : null,
                child: Text(
                  _resendCountdown > 0
                      ? 'إعادة الإرسال بعد $_resendCountdown ثانية'
                      : 'إعادة إرسال الرمز',
                  style: TextStyle(
                    fontSize: 14,
                    color: _resendCountdown == 0
                        ? const Color(0xFF667eea)
                        : Colors.grey,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: _isLoading || _isSendingOtp
                  ? null
                  : () {
                      widget.onCancel();
                      Navigator.of(context).pop(false);
                    },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
