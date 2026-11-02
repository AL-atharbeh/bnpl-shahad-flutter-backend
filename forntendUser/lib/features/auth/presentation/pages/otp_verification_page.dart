import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/language_service.dart';
import '../../../../services/auth_service.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/app_router.dart';
import '../widgets/auth_scaffold.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final bool userExists;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.userExists,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 60);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOTP() async {
    if (_resendTimer == 0) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      setState(() => _isLoading = true);
      
      try {
        var handled = false;

        await authService.sendFirebaseOTP(
          phoneNumber: widget.phoneNumber,
          onCodeSent: (_) {
            if (!mounted || handled) return;
            handled = true;
            _startTimer();
            setState(() => _isLoading = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إرسال الرمز مرة أخرى'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          onError: (error) {
            if (!mounted || handled) return;
            handled = true;
            setState(() => _isLoading = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل إرسال الرمز. حاول مرة أخرى'),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _shakeAnimation() {
    _shakeController.forward(from: 0.0);
  }

  void _handleVerify() async {
    final otp = _otpController.text;

    if (otp.length != 6) {
      _shakeAnimation();
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // يتحقق Firebase من الرمز، ثم يُرسل رمز الهوية إلى الباك إند الذي ينشئ
      // المستخدم أو يحدّثه ويُصدر JWT. شكل النتيجة هو نفسه الذي كانت تُرجعه
      // verifyOTPCode، فلا يتغيّر ما بعده.
      final verifyResult = await authService.verifyFirebaseOTP(otp);

      if (!verifyResult['success']) {
        if (mounted) {
          setState(() => _isLoading = false);
          _shakeAnimation();
          _otpController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(verifyResult['error'] ?? AppLocalizations.of(context)!.invalidVerificationCode),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      final userExists = verifyResult['userExists'] ?? false;
      final requiresProfileCompletion = verifyResult['requiresProfileCompletion'] ?? false;

      if (mounted) {
        setState(() => _isLoading = false);

        // إذا كان المستخدم موجود وله ملف كامل → تسجيل الدخول مباشرة
        if (userExists && !requiresProfileCompletion && verifyResult['token'] != null) {
          // تم حفظ Token في authService.verifyOTPCode
          print('🔐 User logged in successfully, updating FCM token...');
          try {
            final firebaseService = Provider.of<FirebaseService>(context, listen: false);
            await firebaseService.updateTokenOnServer(null);
            print('✅ FCM token update initiated');
          } catch (e) {
            print('⚠️ Failed to update FCM token: $e');
          }
          
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.home,
            (route) => false,
          );
        }
        // إذا كان المستخدم غير موجود أو يحتاج إكمال الملف → الانتقال لإنشاء الحساب
        else {
            Navigator.pushNamed(
              context,
              AppRouter.civilIdCapture,
              arguments: {
                'phoneNumber': widget.phoneNumber,
              },
            );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _shakeAnimation();
        _otpController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ. يرجى المحاولة مرة أخرى: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    final size = MediaQuery.of(context).size;

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.financialGreen50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
        ),
      ),
    );

    return AuthScaffold(
      step: 2,
      title: isRTL ? 'أدخل رمز التحقق' : 'Enter the code',
      subtitle: isRTL
          ? 'أرسلنا رمزاً إلى الرقم أدناه. أدخله لتأكيد ملكيتك له.'
          : 'We sent a code to the number below. Enter it to confirm the number is yours.',
      action: AuthPrimaryButton(
        label: l10n.verify,
        isLoading: _isLoading,
        onPressed: _otpController.text.length == 6 ? _handleVerify : null,
      ),
      children: [
        // The number is shown so a mistyped digit can be caught here instead of
        // after waiting for a code that cannot arrive.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                widget.phoneNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'تعديل' : 'Edit',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              // Three quick swings that settle back to centre.
              offset: Offset(
                math.sin(_shakeController.value * math.pi * 3) *
                    12 *
                    (1 - _shakeController.value),
                0,
              ),
              child: child,
            );
          },
          child: Directionality(
            // Codes are entered left to right in either language.
            textDirection: TextDirection.ltr,
            child: Pinput(
              controller: _otpController,
              length: 6,
              autofocus: true,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              separatorBuilder: (_) => const SizedBox(width: 8),
              onChanged: (_) => setState(() {}),
              onCompleted: (_) => _handleVerify(),
            ),
          ),
        ),

        const SizedBox(height: 28),

        Center(
          child: _resendTimer > 0
              ? Text(
                  '${l10n.resendIn} $_resendTimer ${l10n.seconds}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                )
              : TextButton(
                  onPressed: _resendOTP,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    l10n.resendCode,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
