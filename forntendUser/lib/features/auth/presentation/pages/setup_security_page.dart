import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../services/security_service.dart';
import '../../../../routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../config/env/env_dev.dart';

/// صفحة إعداد الأمان - تُعرض مرة واحدة بعد إنشاء الحساب
class SetupSecurityPage extends StatefulWidget {
  const SetupSecurityPage({super.key});

  @override
  State<SetupSecurityPage> createState() => _SetupSecurityPageState();
}

enum _SetupStep { welcome, setPin, confirmPin, biometric }

class _SetupSecurityPageState extends State<SetupSecurityPage>
    with TickerProviderStateMixin {
  final SecurityService _securityService = SecurityService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  _SetupStep _currentStep = _SetupStep.welcome;
  String _enteredPin = '';
  String? _firstPin;
  static const int _pinLength = 4;

  bool _biometricAvailable = false;
  bool _biometricCheckDone = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = false;
  bool _hasError = false;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _shakeController = AnimationController(
        duration: const Duration(milliseconds: 480), vsync: this);
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ─── فحص البصمة ─────────────────────────────────────────────────────────
  Future<void> _checkBiometricAvailability() async {
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final available = isDeviceSupported && canCheck
          ? await _localAuth.getAvailableBiometrics()
          : <BiometricType>[];

      if (mounted) {
        setState(() {
          _biometricAvailable =
              isDeviceSupported && canCheck && available.isNotEmpty;
          _availableBiometrics = available;
          _biometricCheckDone = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _biometricCheckDone = true);
    }
  }

  // ─── نوع البصمة ──────────────────────────────────────────────────────────
  bool get _isFaceId =>
      _availableBiometrics.contains(BiometricType.face) ||
      _availableBiometrics.contains(BiometricType.iris);

  IconData get _biometricIcon =>
      _isFaceId ? Icons.face_retouching_natural_rounded : Icons.fingerprint_rounded;

  String get _biometricLabel => _isFaceId ? 'بصمة الوجه' : 'بصمة الإصبع';

  // ─── الانتقال بين الخطوات ─────────────────────────────────────────────────
  void _animateToStep(_SetupStep step) {
    _fadeController.reset();
    setState(() {
      _currentStep = step;
      _enteredPin = '';
      _hasError = false;
    });
    _fadeController.forward();
  }

  // ─── إدخال رقم ───────────────────────────────────────────────────────────
  void _onKeyPressed(String digit) {
    if (_isLoading || _enteredPin.length >= _pinLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin += digit;
      _hasError = false;
    });
    if (_enteredPin.length == _pinLength) {
      _handlePinComplete();
    }
  }

  void _onDeletePressed() {
    if (_isLoading || _enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _hasError = false;
    });
  }

  // ─── اكتمال الـ PIN ───────────────────────────────────────────────────────
  Future<void> _handlePinComplete() async {
    if (_currentStep == _SetupStep.setPin) {
      // حفظ PIN الأول والانتقال للتأكيد
      _firstPin = _enteredPin;
      _animateToStep(_SetupStep.confirmPin);
    } else if (_currentStep == _SetupStep.confirmPin) {
      await _confirmPin();
    }
  }

  Future<void> _confirmPin() async {
    if (_enteredPin != _firstPin) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() {
            _enteredPin = '';
            _hasError = false;
          });
        });
      });
      setState(() => _hasError = true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _securityService.setPin(_enteredPin);
      if (response['success'] == true) {
        if (_biometricAvailable) {
          _animateToStep(_SetupStep.biometric);
        } else {
          _navigateToHome();
        }
      } else {
        _showError(response['error'] ?? 'فشل في حفظ كلمة السر');
        _animateToStep(_SetupStep.setPin);
      }
    } catch (e) {
      _showError('حدث خطأ: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── تفعيل البصمة ────────────────────────────────────────────────────────
  Future<void> _enableBiometric() async {
    if (!_biometricAvailable) return;
    setState(() => _isLoading = true);
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'قم بتأكيد هويتك لتفعيل $_biometricLabel',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (authenticated) {
        final response = await _securityService.enableBiometric();
        if (response['success'] == true) {
          _navigateToHome();
        } else {
          _navigateToHome();
        }
      }
    } on PlatformException catch (e) {
      if (EnvDev.enableLogging) print('❌ Biometric: ${e.code}');
      _showError('لا توجد بصمة مُسجَّلة في إعدادات الهاتف');
    } catch (e) {
      _showError('البصمة غير متاحة');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    if (mounted) AppRouter.navigateToHome(context);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textDirection: TextDirection.rtl),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case _SetupStep.welcome:
        return _buildWelcomeStep();
      case _SetupStep.setPin:
        return _buildPinStep(
          title: 'اختر كلمة السر',
          subtitle: 'أدخل 4 أرقام تتذكرها بسهولة',
        );
      case _SetupStep.confirmPin:
        return _buildPinStep(
          title: 'تأكيد كلمة السر',
          subtitle: _hasError ? 'كلمة السر غير متطابقة' : 'أعد إدخال الأرقام الأربعة',
          isConfirm: true,
        );
      case _SetupStep.biometric:
        return _buildBiometricStep();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  شاشة الترحيب
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildWelcomeStep() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // أيقونة
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: AppColors.financialGreenGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.financialGreenShadowMedium,
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.shield_rounded, size: 58, color: Colors.white),
            ),
            const SizedBox(height: 32),

            const Text(
              'أمّن حسابك',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'ستقوم الآن بإعداد كلمة سر من 4 أرقام\nتستخدمها في كل مرة تفتح التطبيق',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // مميزات
            _featureRow(Icons.lock_outline_rounded, AppColors.primary,
                'كلمة سر 4 أرقام تختارها أنت'),
            const SizedBox(height: 12),
            if (_biometricCheckDone && _biometricAvailable)
              _featureRow(_biometricIcon, const Color(0xFF6366F1),
                  '$_biometricLabel (اختياري بعد إعداد الكود)')
            else if (_biometricCheckDone && !_biometricAvailable)
              _featureRowDisabled(
                  Icons.face_outlined, 'البصمة غير متاحة على هذا الجهاز'),
            const SizedBox(height: 12),
            _featureRow(Icons.security_rounded, AppColors.primary,
                'حماية كاملة لبياناتك المالية'),

            const Spacer(flex: 3),

            // زر البدء
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _animateToStep(_SetupStep.setPin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'إعداد كلمة السر',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _navigateToHome,
              child: const Text(
                'تخطي الآن',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
        ),
      ],
    );
  }

  Widget _featureRowDisabled(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFD1D5DB), size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                  decoration: TextDecoration.lineThrough)),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  شاشة إدخال PIN (يُستخدم لإدخال وتأكيد)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPinStep({
    required String title,
    required String subtitle,
    bool isConfirm = false,
  }) {
    return Column(
      children: [
        // زر الرجوع
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Color(0xFF374151)),
              onPressed: () {
                if (isConfirm) {
                  _animateToStep(_SetupStep.setPin);
                } else {
                  _animateToStep(_SetupStep.welcome);
                }
              },
            ),
          ),
        ),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // العنوان
              Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: _hasError
                            ? Colors.red.shade500
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // النقاط
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (i) {
                    final isFilled = i < _enteredPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _hasError
                            ? Colors.red.shade400
                            : isFilled
                                ? const Color(0xFF111827)
                                : const Color(0xFFDDE1E7),
                        border: isFilled || _hasError
                            ? null
                            : Border.all(
                                color: const Color(0xFFD1D5DB), width: 1.5),
                      ),
                    );
                  }),
                ),
              ),

              // loading
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _isLoading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),

        // لوحة الأرقام
        _buildKeypad(showBiometric: false),
        const SizedBox(height: 16),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  شاشة البصمة
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBiometricStep() {
    if (!_biometricAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToHome());
      return const SizedBox.shrink();
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(_biometricIcon, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              'فعّل $_biometricLabel',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'ادخل التطبيق ${_isFaceId ? "بنظرة واحدة" : "بلمسة واحدة"} في المرات القادمة',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ملاحظة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF0284C7), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'سيتم استخدام $_biometricLabel المُسجَّلة في إعدادات هاتفك',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0369A1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 44),

            if (_isLoading)
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _enableBiometric,
                  icon: Icon(_biometricIcon, size: 22),
                  label: Text(
                    'تفعيل $_biometricLabel',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _navigateToHome,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFFE5E7EB), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  لوحة الأرقام
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildKeypad({bool showBiometric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          _buildKeyRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildKeyRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildKeyRow(['7', '8', '9']),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 88, height: 88), // فارغ
              _buildDigitKey('0'),
              _buildDeleteKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: digits.map((d) => _buildDigitKey(d)).toList(),
    );
  }

  Widget _buildDigitKey(String digit) {
    return _KeyButton(
      onTap: () => _onKeyPressed(digit),
      enabled: !_isLoading,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            digit,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: Color(0xFF111827),
              height: 1,
            ),
          ),
          if (_keypadLetters[digit] != null)
            Text(
              _keypadLetters[digit]!,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeleteKey() {
    return _KeyButton(
      onTap: _onDeletePressed,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() => _enteredPin = '');
      },
      enabled: !_isLoading,
      transparent: true,
      child: const Icon(Icons.backspace_outlined,
          size: 24, color: Color(0xFF374151)),
    );
  }

  static const Map<String, String> _keypadLetters = {
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ',
  };
}

// ══════════════════════════════════════════════════════════════════════════════
//  Widget: زر لوحة المفاتيح
// ══════════════════════════════════════════════════════════════════════════════
class _KeyButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final bool enabled;
  final bool transparent;

  const _KeyButton({
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.enabled = true,
    this.transparent = false,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp:
          widget.enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel:
          widget.enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.transparent
              ? Colors.transparent
              : _isPressed
                  ? const Color(0xFFD1D5DB)
                  : const Color(0xFFF3F4F6),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
