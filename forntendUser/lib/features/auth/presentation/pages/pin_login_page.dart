import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/security_service.dart';
import '../../../../routing/app_router.dart';
import '../../../../config/env/env_dev.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

class PinLoginPage extends StatefulWidget {
  const PinLoginPage({super.key});

  @override
  State<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final SecurityService _securityService = SecurityService();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPinAndLogin(String pin) async {
    if (pin.length != 4) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // الحصول على JWT token المحفوظ
      final token = await authService.getSavedToken();
      if (token == null) {
        // لا يوجد token، اذهب إلى phone input
        if (mounted) {
          AppRouter.navigateToPhoneInput(context);
        }
        return;
      }

      // تعيين token في API service للتحقق من PIN
      authService.setAuthToken(token);

      // Trim PIN قبل الإرسال
      final trimmedPin = pin.trim();
      
      if (EnvDev.enableLogging) {
        print('🔐 Verifying PIN: "$pin" (length: ${pin.length})');
        print('🔐 Trimmed PIN: "$trimmedPin" (length: ${trimmedPin.length})');
      }

      // التحقق من PIN
      final response = await _securityService.verifyPin(trimmedPin);

      if (response['success']) {
        // Backend returns: {success: true, data: {isValid: true}}
        // ApiService wraps it: {success: true, data: {success: true, data: {isValid: true}}}
        final backendData = response['data'];
        final isValid = backendData['data']?['isValid'] ?? backendData['isValid'] ?? false;
        
        if (EnvDev.enableLogging) {
          print('🔐 PIN Verification Result:');
          print('   Response: $response');
          print('   Backend Data: $backendData');
          print('   Is Valid: $isValid');
        }
        
        if (isValid) {
          // PIN صحيح - الدخول مباشرة
          if (mounted) {
            AppRouter.navigateToHome(context);
          }
        } else {
          // PIN خاطئ
          final l10n = AppLocalizations.of(context)!;
          setState(() {
            _errorMessage = l10n.incorrectPassword;
            _isLoading = false;
            _pinController.clear();
          });
          
          // هز الصفحة
          _shakeAnimation();
        }
      } else {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = response['error'] ?? l10n.errorVerifyingPassword;
          _isLoading = false;
          _pinController.clear();
        });
      }
    } catch (e) {
      if (EnvDev.enableLogging) {
        print('❌ Error verifying PIN: $e');
      }
      
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = '${l10n.errorVerifyingPassword}: ${e.toString()}';
        _isLoading = false;
        _pinController.clear();
      });
    }
  }

  void _shakeAnimation() {
    // يمكن إضافة animation هنا إذا أردت
  }

  void _goToPhoneLogin() {
    AppRouter.navigateToPhoneInput(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon with Financial Green gradient background
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.financialGreenGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.financialGreenShadowMedium,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                l10n.enterPassword,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                l10n.enter4DigitsToLogin,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 56),

              // PIN Input
              Pinput(
                length: 4,
                controller: _pinController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                enabled: !_isLoading,
                defaultPinTheme: PinTheme(
                  width: 64,
                  height: 64,
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 64,
                  height: 64,
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.financialGreenShadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                submittedPinTheme: PinTheme(
                  width: 64,
                  height: 64,
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.financialGreen50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
                errorPinTheme: PinTheme(
                  width: 64,
                  height: 64,
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                ),
                onCompleted: _verifyPinAndLogin,
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage != null) const SizedBox(height: 24),

              // Loading Indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              else
                const SizedBox(height: 40),

              const Spacer(),

              // Alternative Login Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _goToPhoneLogin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.loginWithPhoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

