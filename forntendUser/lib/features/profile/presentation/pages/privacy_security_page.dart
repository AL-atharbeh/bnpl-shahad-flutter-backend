import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../services/security_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../routing/app_router.dart';
import '../../../../config/env/env_dev.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final SecurityService _securityService = SecurityService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _isLoading = true;
  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
    _checkBiometricAvailability();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _securityService.getSecuritySettings();
      
      if (response['success']) {
        // Backend returns: {success: true, data: {pinEnabled, biometricEnabled}}
        // ApiService wraps it: {success: true, data: {success: true, data: {...}}}
        final backendData = response['data'];
        final settingsData = backendData['data'] ?? backendData; // Handle nested structure
        
        setState(() {
          _pinEnabled = settingsData['pinEnabled'] ?? false;
          _biometricEnabled = settingsData['biometricEnabled'] ?? false;
          _isLoading = false;
        });
        
        if (EnvDev.enableLogging) {
          print('🔐 Security Settings Loaded:');
          print('   PIN Enabled: $_pinEnabled');
          print('   Biometric Enabled: $_biometricEnabled');
        }
      } else {
        setState(() => _isLoading = false);
        print('❌ Failed to load security settings: ${response['error']}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Error loading security settings: $e');
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      setState(() {
        _biometricAvailable = isAvailable && isDeviceSupported;
      });
    } catch (e) {
      setState(() => _biometricAvailable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = context.watch<LanguageService>().isArabic;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.privacyAndSecurity,
          style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // ====== الأمان ======
                _SectionHeader(icon: Icons.security, title: l10n.security),
                const SizedBox(height: 12),
                _CardSection(children: [
                  // PIN Code - كلمة سر للدخول للسحاب
                  _NavTile(
                    icon: Icons.pin,
                    title: l10n.pinForAccountLogin,
                    subtitle: _pinEnabled 
                        ? l10n.enabled4Digits
                        : l10n.disabledTapToEnable,
                    onTap: _pinEnabled ? _showChangePinDialog : _showSetPinDialog,
                  ),
                  const _ItemDivider(),
                  // Biometric - بصمة الوجه
                  _SwitchTile(
                    icon: Icons.face,
                    title: l10n.faceId,
                    subtitle: _biometricEnabled 
                        ? l10n.enabledUseFaceIdToLogin
                        : l10n.disabledRequiresPinFirst,
                    value: _biometricEnabled,
                    onChanged: _biometricAvailable && _pinEnabled
                        ? (v) => v ? _enableBiometric() : _disableBiometric()
                        : null,
                    disabled: !_biometricAvailable || !_pinEnabled,
                  ),
                ]),

                const SizedBox(height: 24),

                // ====== السياسات ======
                _SectionHeader(icon: Icons.policy, title: l10n.policies),
                const SizedBox(height: 12),
                _CardSection(children: [
                  _NavTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    subtitle: l10n.privacyPolicySubtitle,
                    onTap: () => _openPolicy('privacy'),
                  ),
                  const _ItemDivider(),
                  _NavTile(
                    icon: Icons.description_outlined,
                    title: l10n.termsOfService,
                    subtitle: l10n.termsOfServiceSubtitle,
                    onTap: () => _openPolicy('terms'),
                  ),
                ]),

                const SizedBox(height: 24),

                // ====== حذف الحساب ======
                _SectionHeader(icon: Icons.warning_rounded, title: l10n.accountManagement),
                const SizedBox(height: 12),
                _CardSection(children: [
                  _NavTile(
                    icon: Icons.delete_forever_rounded,
                    title: l10n.deleteAccount,
                    subtitle: l10n.deleteAccountPermanently,
                    onTap: _showDeleteAccountDialog,
                    isDestructive: true,
                  ),
                ]),
              ],
            ),
    );
  }

  // ====== تفاعلات ======

  Future<void> _showSetPinDialog() async {
    final l10n = AppLocalizations.of(context)!;
    String? firstPin;
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    bool isConfirming = false;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isConfirming ? l10n.confirmPin : l10n.setPinForLogin,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isConfirming 
                    ? l10n.reEnterPinToConfirm
                    : l10n.enter4DigitsAsPin,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              Pinput(
                length: 4,
                controller: isConfirming ? confirmPinController : pinController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
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
                    border: Border.all(color: const Color(0xFF111827), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF111827).withOpacity(0.1),
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
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3B82F6), width: 2),
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
                onCompleted: (pin) async {
                  if (!isConfirming) {
                    // حفظ PIN الأول والانتقال للتأكيد
                    firstPin = pin;
                    setDialogState(() {
                      isConfirming = true;
                      confirmPinController.clear();
                    });
                  } else {
                    // التحقق من تطابق PIN
                    if (pin == firstPin) {
                      Navigator.pop(context);
                      await _setPin(pin);
                    } else {
                      // PIN غير متطابق
                      setDialogState(() {
                        confirmPinController.clear();
                      });
                      final dialogL10n = AppLocalizations.of(context)!;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(dialogL10n.pinsDoNotMatch),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (isConfirming) {
                  setDialogState(() {
                    isConfirming = false;
                    firstPin = null;
                    pinController.clear();
                    confirmPinController.clear();
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(isConfirming ? l10n.back : l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePinDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.changePin,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(l10n.doYouWantToChangeCurrentPin),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.change),
          ),
        ],
      ),
    );

    if (result == true) {
      // أولاً: التحقق من PIN الحالي
      final oldPinController = TextEditingController();
      final verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final dialogL10n = AppLocalizations.of(context)!;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              dialogL10n.enterCurrentPin,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Pinput(
                length: 4,
                controller: oldPinController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
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
                    border: Border.all(color: const Color(0xFF111827), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF111827).withOpacity(0.1),
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
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3B82F6), width: 2),
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
                onCompleted: (pin) async {
                  if (pin.length == 4) {
                    final response = await _securityService.verifyPin(pin);
                    final isValid = response['success'] == true && response['data']?['isValid'] == true;
                    if (!isValid && context.mounted) {
                      final verifyL10n = AppLocalizations.of(context)!;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(verifyL10n.incorrectPassword),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      oldPinController.clear();
                    } else {
                      Navigator.pop(context, isValid);
                    }
                  }
                },
              ),
            ],
          ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(dialogL10n.cancel),
              ),
            ],
          );
        },
      );

      if (verified == true) {
        // إذا تم التحقق، اطلب PIN جديد
        await _showSetPinDialog();
      } else if (verified == false) {
        final l10n = AppLocalizations.of(context)!;
        _toast(l10n.incorrectPassword, success: false);
      }
    }
  }

  Future<void> _setPin(String pin) async {
    try {
      final response = await _securityService.setPin(pin);
      
      if (response['success']) {
        // إعادة تحميل الإعدادات من الخادم للتأكد من الحالة الفعلية
        await _loadSecuritySettings();
        _toast(response['data']?['message'] ?? response['message'] ?? 'تم تفعيل كلمة السر بنجاح', success: true);
      } else {
        _toast(response['data']?['message'] ?? response['error'] ?? 'فشل تعيين كلمة السر', success: false);
      }
    } catch (e) {
      _toast('حدث خطأ: ${e.toString()}', success: false);
    }
  }

  Future<void> _enableBiometric() async {
    try {
      // التحقق من البصمة أولاً
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك لتفعيل البصمة',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final response = await _securityService.enableBiometric();
        
        if (response['success']) {
          setState(() => _biometricEnabled = true);
          _toast(response['message'] ?? 'تم تفعيل البصمة بنجاح', success: true);
        } else {
          _toast(response['error'] ?? 'فشل تفعيل البصمة', success: false);
        }
      }
    } catch (e) {
      _toast('حدث خطأ: ${e.toString()}', success: false);
    }
  }

  Future<void> _disableBiometric() async {
    try {
      final response = await _securityService.disableBiometric();
      
      if (response['success']) {
        setState(() => _biometricEnabled = false);
        _toast(response['message'] ?? 'تم تعطيل البصمة', success: true);
      } else {
        _toast(response['error'] ?? 'فشل تعطيل البصمة', success: false);
      }
    } catch (e) {
      _toast('حدث خطأ: ${e.toString()}', success: false);
    }
  }


  Future<void> _showDeleteAccountDialog() async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteAccountTitle,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.deleteAccountConfirmation,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ سيتم حذف جميع بياناتك نهائياً ولا يمكن التراجع',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // التحقق من PIN قبل الحذف
      final pinController = TextEditingController();
      final pinVerified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'تأكيد الحذف',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'أدخل كلمة السر للتحقق من هويتك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Pinput(
                length: 4,
                controller: pinController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                ),
                onCompleted: (pin) async {
                  if (pin.length == 4) {
                    final response = await _securityService.verifyPin(pin);
                    Navigator.pop(context, response['success'] == true && response['data']?['isValid'] == true);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      );

      if (pinVerified == true) {
        await _deleteAccount();
      } else if (pinVerified == false) {
        final l10n = AppLocalizations.of(context)!;
        _toast(l10n.incorrectPassword, success: false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final response = await _securityService.deleteAccount();
      
      if (response['success']) {
        // تسجيل الخروج وحذف البيانات المحلية
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.clearLoginState();
        
        if (mounted) {
          // استخراج الرسالة من response['data'] إذا كانت موجودة
          final message = response['data']?['message'] ?? 
                         response['message'] ?? 
                         'تم حذف الحساب بنجاح';
          _toast(message, success: true);
          // الانتقال لصفحة تسجيل الدخول
          AppRouter.navigateToPhoneInput(context);
        }
      } else {
        // استخراج رسالة الخطأ من response['data'] أو response['error']
        final errorMessage = response['data']?['message'] ?? 
                            response['error'] ?? 
                            'فشل حذف الحساب';
        _toast(errorMessage, success: false);
      }
    } catch (e) {
      _toast('حدث خطأ: ${e.toString()}', success: false);
    }
  }

  void _openPolicy(String which) {
    final l10n = AppLocalizations.of(context)!;
    // يمكن فتح صفحة السياسة/الشروط هنا
    _toast(which == 'privacy' ? l10n.openingPrivacyPolicy : l10n.openingTermsOfService);
  }

  void _toast(String msg, {bool? success}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          success == null ? const Color(0xFF111827) : (success ? Colors.green : Colors.red),
    ));
  }
}

// ================== Widgets مساعدة ==================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF111827)),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF111827))),
      ],
    );
  }
}

class _CardSection extends StatelessWidget {
  final List<Widget> children;
  const _CardSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6ECF3)),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(children: children),
    );
  }
}

class _ItemDivider extends StatelessWidget {
  const _ItemDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: const Color(0xFFE6ECF3));
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = disabled ? const Color(0xFF9CA3AF) : const Color(0xFF111827);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: textColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: textColor)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: disabled ? null : onChanged,
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : const Color(0xFF111827);
    final bg = isDestructive ? Colors.red[50] : const Color(0xFFF2F4F7);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      trailing: const Icon(Icons.chevron_left, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }
}
