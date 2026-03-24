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
        final result = await authService.sendOTPToPhone(widget.phoneNumber);
        
        if (result['success']) {
      _startTimer();
          if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال الرمز مرة أخرى'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['error'] ?? 'فشل إرسال الرمز'),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
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
      // التحقق من OTP
      final verifyResult = await authService.verifyOTPCode(widget.phoneNumber, otp);

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
          // إرسال FCM token إلى الـ backend
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sms_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  l10n.verificationCode,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Column(
                  children: [
                    Text(
                      l10n.enterCodeSentTo,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        widget.phoneNumber,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // OTP Input
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final offset = _shakeController.value;
                    final shakeValue = (offset * 10 * (1 - offset)).toDouble();
                    return Transform.translate(
                      offset: Offset(isRTL ? -shakeValue : shakeValue, 0),
                      child: child,
                    );
                  },
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      controller: _otpController,
                      focusNode: _focusNode,
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      errorPinTheme: defaultPinTheme.copyWith(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade400,
                          ),
                        ),
                      ),
                      pinAnimationType: PinAnimationType.fade,
                      onCompleted: (_) => _handleVerify(),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Resend
                if (_resendTimer > 0)
                  Text(
                    '${l10n.resendIn} $_resendTimer ${l10n.seconds}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  TextButton(
                    onPressed: _resendOTP,
                    child: Text(
                      l10n.resendCode,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 40),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l10n.verify,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
