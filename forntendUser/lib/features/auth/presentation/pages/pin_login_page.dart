import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/security_service.dart';
import '../../../../routing/app_router.dart';
import '../../../../config/env/env_dev.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../l10n/generated/app_localizations.dart';

class PinLoginPage extends StatefulWidget {
  const PinLoginPage({super.key});

  @override
  State<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage>
    with SingleTickerProviderStateMixin {
  final SecurityService _securityService = SecurityService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String _enteredPin = '';
  static const int _pinLength = 4;

  bool _isCheckingSettings = true;
  bool _isVerifying = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _hasError = false;

  // Shake animation للخطأ
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 480),
      vsync: this,
    );
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

    _loadSecuritySettings();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // ─── تحميل الإعدادات ─────────────────────────────────────────────────────
  Future<void> _loadSecuritySettings() async {
    setState(() => _isCheckingSettings = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getSavedToken();
      if (token != null) authService.setAuthToken(token);

      final response = await _securityService.getSecuritySettings();
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final available = isDeviceSupported && canCheck
          ? await _localAuth.getAvailableBiometrics()
          : <BiometricType>[];

      if (!mounted) return;

      bool biometricEnabledInAccount = false;
      if (response['success'] == true) {
        final data = response['data'];
        final settings =
            (data is Map && data.containsKey('data')) ? data['data'] : data;
        biometricEnabledInAccount = settings?['biometricEnabled'] ?? false;
      }

      setState(() {
        _biometricEnabled = biometricEnabledInAccount;
        _biometricAvailable =
            isDeviceSupported && canCheck && available.isNotEmpty;
        _availableBiometrics = available;
        _isCheckingSettings = false;
      });

      // تشغيل البصمة تلقائياً
      if (_biometricEnabled && _biometricAvailable) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) _authenticateWithBiometric();
      }
    } catch (e) {
      if (mounted) setState(() => _isCheckingSettings = false);
      if (EnvDev.enableLogging) print('⚠️ Security settings error: $e');
    }
  }

  // ─── إدخال رقم ───────────────────────────────────────────────────────────
  void _onKeyPressed(String digit) {
    if (_isVerifying || _enteredPin.length >= _pinLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin += digit;
      _hasError = false;
    });
    if (_enteredPin.length == _pinLength) {
      _verifyPin();
    }
  }

  // ─── حذف آخر رقم ─────────────────────────────────────────────────────────
  void _onDeletePressed() {
    if (_isVerifying || _enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _hasError = false;
    });
  }

  void _navigateToHome() {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      firebaseService.updateTokenOnServer(null).catchError((e) => print('❌ Failed to update FCM token: $e'));
    } catch (e) {
      print('⚠️ Failed to initiate FCM token update: $e');
    }
    AppRouter.navigateToHome(context);
  }

  // ─── التحقق من PIN ────────────────────────────────────────────────────────
  Future<void> _verifyPin() async {
    if (_enteredPin.length != _pinLength) return;

    setState(() => _isVerifying = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getSavedToken();
      if (token == null) {
        if (mounted) AppRouter.navigateToPhoneInput(context);
        return;
      }
      authService.setAuthToken(token);

      final response = await _securityService.verifyPin(_enteredPin);

      if (response['success'] == true) {
        final backendData = response['data'];
        final isValid = backendData['data']?['isValid'] ??
            backendData['isValid'] ??
            false;

        if (isValid) {
          if (mounted) _navigateToHome();
        } else {
          _triggerError();
        }
      } else {
        _triggerError();
      }
    } catch (e) {
      if (EnvDev.enableLogging) print('❌ PIN error: $e');
      _triggerError();
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _triggerError() {
    HapticFeedback.heavyImpact();
    setState(() {
      _hasError = true;
    });
    _shakeController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _enteredPin = '';
            _hasError = false;
          });
        }
      });
    });
  }

  // ─── بصمة الوجه / الإصبع ─────────────────────────────────────────────────
  Future<void> _authenticateWithBiometric() async {
    if (!_biometricEnabled || !_biometricAvailable || _isVerifying) return;
    setState(() => _isVerifying = true);
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'ادخل إلى حسابك باستخدام $_biometricLabel',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (authenticated && mounted) _navigateToHome();
    } on PlatformException catch (e) {
      if (EnvDev.enableLogging) print('❌ Biometric error: ${e.code}');
    } catch (e) {
      if (EnvDev.enableLogging) print('❌ Biometric: $e');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  String get _biometricLabel {
    if (_availableBiometrics.contains(BiometricType.face) ||
        _availableBiometrics.contains(BiometricType.iris)) return 'بصمة الوجه';
    return 'بصمة الإصبع';
  }

  IconData get _biometricIcon {
    if (_availableBiometrics.contains(BiometricType.face) ||
        _availableBiometrics.contains(BiometricType.iris)) {
      return Icons.face_retouching_natural_rounded;
    }
    return Icons.fingerprint_rounded;
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // دائماً من اليسار لليمين لأرقام الـ PIN
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isCheckingSettings
            ? _buildLoadingState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        children: [
          // ── المساحة العلوية + العنوان + النقاط ──
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
                        'أهلًا بعودتك!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.5,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _hasError
                            ? 'كلمة السر غير صحيحة'
                            : 'أدخل رقمك السري لفتح حسابك',
                        style: TextStyle(
                          fontSize: 16,
                          color: _hasError
                              ? Colors.red.shade500
                              : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 52),

                // ── النقاط ──
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
                        curve: Curves.easeOut,
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
                                  color: const Color(0xFFD1D5DB),
                                  width: 1.5,
                                ),
                        ),
                      );
                    }),
                  ),
                ),

                // مؤشر loading أثناء التحقق
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: _isVerifying ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── لوحة الأرقام ──
          _buildKeypad(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  لوحة الأرقام - تصميم iPhone
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // صف 1: 1 2 3
          _buildKeyRow(['1', '2', '3']),
          const SizedBox(height: 12),
          // صف 2: 4 5 6
          _buildKeyRow(['4', '5', '6']),
          const SizedBox(height: 12),
          // صف 3: 7 8 9
          _buildKeyRow(['7', '8', '9']),
          const SizedBox(height: 12),
          // صف 4: [بصمة/فارغ]  0  [حذف]
          _buildBottomRow(),
          const SizedBox(height: 28),

          // ── تسجيل الدخول برقم الهاتف ──
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextButton(
              onPressed: _isVerifying
                  ? null
                  : () => AppRouter.navigateToPhoneInput(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                AppLocalizations.of(context)!.loginWithPhoneNumber,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
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

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // زر البصمة أو مساحة فارغة
        _biometricEnabled && _biometricAvailable
            ? _buildBiometricKey()
            : const SizedBox(width: 88, height: 88),

        // زر 0
        _buildDigitKey('0'),

        // زر الحذف
        _buildDeleteKey(),
      ],
    );
  }

  // ── زر رقم ────────────────────────────────────────────────────────────────
  Widget _buildDigitKey(String digit) {
    return _KeyButton(
      onTap: () => _onKeyPressed(digit),
      enabled: !_isVerifying,
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

  // ── زر الحذف ─────────────────────────────────────────────────────────────
  Widget _buildDeleteKey() {
    return _KeyButton(
      onTap: _onDeletePressed,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() => _enteredPin = '');
      },
      enabled: !_isVerifying,
      transparent: true,
      child: const Icon(
        Icons.backspace_outlined,
        size: 24,
        color: Color(0xFF374151),
      ),
    );
  }

  // ── زر البصمة ─────────────────────────────────────────────────────────────
  Widget _buildBiometricKey() {
    return _KeyButton(
      onTap: _authenticateWithBiometric,
      enabled: !_isVerifying,
      transparent: true,
      child: Icon(
        _biometricIcon,
        size: 30,
        color: const Color(0xFF374151),
      ),
    );
  }

  // حروف لوحة الأرقام (مثل iPhone)
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
      onTapDown: widget.enabled
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.enabled
          ? (_) => setState(() => _isPressed = false)
          : null,
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
