import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../../services/security_service.dart';

/// Dialog for PIN verification
/// Used for BNPL session approval when amount < 300 JOD
class PinVerificationDialog extends StatefulWidget {
  final VoidCallback onVerified;
  final VoidCallback onCancel;

  const PinVerificationDialog({
    Key? key,
    required this.onVerified,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PinVerificationDialog> createState() => _PinVerificationDialogState();
}

class _PinVerificationDialogState extends State<PinVerificationDialog> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin(String pin) async {
    if (pin.length != 4) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Import SecurityService
      final securityService = SecurityService();
      final response = await securityService.verifyPin(pin);

      if (response['success']) {
        // PIN correct
        widget.onVerified();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // PIN incorrect
        setState(() {
          _errorMessage = response['error'] ?? 'الرقم السري غير صحيح';
          _isLoading = false;
        });
        _pinController.clear();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: ${e.toString()}';
        _isLoading = false;
      });
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
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
                Icons.lock_outline,
                size: 32,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'أدخل الرقم السري',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'للتحقق من هويتك وإتمام عملية الدفع',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // PIN Input
            Directionality(
              textDirection: TextDirection.ltr,
              child: Pinput(
                controller: _pinController,
                length: 4,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: _errorMessage != null ? errorPinTheme : null,
                obscureText: true,
                obscuringCharacter: '●',
                enabled: !_isLoading,
                onCompleted: _verifyPin,
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

            const SizedBox(height: 24),

            // Cancel Button
            TextButton(
              onPressed: _isLoading
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
