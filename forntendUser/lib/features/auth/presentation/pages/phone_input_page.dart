import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/language_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/app_router.dart';
import '../widgets/auth_scaffold.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  /// The action stays disabled until the number could plausibly be complete, so
  /// nobody taps it only to be told the number is too short.
  bool get _isComplete {
    var digits = _phoneController.text;
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits.length == 9;
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() => setState(() {});

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  /// Firebase reports failures by code; these are the ones a user can act on.
  String _firebaseErrorMessage(dynamic error) {
    final text = error.toString();

    if (text.contains('invalid-phone-number')) {
      return 'رقم الهاتف غير صحيح';
    }
    if (text.contains('too-many-requests')) {
      return 'محاولات كثيرة. حاول بعد قليل';
    }
    if (text.contains('quota-exceeded')) {
      return 'تعذّر إرسال الرمز حالياً. حاول لاحقاً';
    }
    if (text.contains('network')) {
      return 'تحقق من اتصالك بالإنترنت';
    }

    return 'فشل إرسال رمز التحقق. حاول مرة أخرى';
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String inputPhone = _phoneController.text.trim();
    if (inputPhone.startsWith('0')) {
      inputPhone = inputPhone.substring(1);
    }
    final phoneNumber = '+962$inputPhone';
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // 1. التحقق من وجود المستخدم
      final checkResult = await authService.checkIfUserExists(phoneNumber);
      
      if (!checkResult['success']) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(checkResult['error'] ?? 'حدث خطأ. يرجى المحاولة مرة أخرى'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      final userExists = checkResult['exists'] ?? false;

      // إرسال رمز التحقق عبر Firebase. الباك إند يولّد الرمز ويحفظه لكنه لا
      // يرسله فعلياً (لا يوجد مزوّد رسائل)، فينتظر المستخدم رسالة لا تصل.
      var navigated = false;

      await authService.sendFirebaseOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (_) {
          if (!mounted || navigated) return;
          navigated = true;
          setState(() => _isLoading = false);

          Navigator.pushNamed(
            context,
            AppRouter.otpVerification,
            arguments: {
              'phoneNumber': phoneNumber,
              'userExists': userExists,
            },
          );
        },
        onError: (error) {
          if (!mounted || navigated) return;
          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_firebaseErrorMessage(error)),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        String errorMessage = 'حدث خطأ. يرجى المحاولة مرة أخرى';
        if (e.toString().contains('TimeoutException')) {
          errorMessage = 'انتهت مهلة الاتصال. تأكد من أن Backend يعمل على http://10.0.2.2:3000';
        } else if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
          errorMessage = 'لا يمكن الاتصال بالخادم. تأكد من أن Backend يعمل';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
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

    return AuthScaffold(
      step: 1,
      title: isRTL ? 'ما رقم هاتفك؟' : 'What is your phone number?',
      subtitle: isRTL
          ? 'سنرسل لك رمز تحقق من ست خانات للتأكد من أن الرقم لك.'
          : 'We will text you a six digit code to confirm the number is yours.',
      action: AuthPrimaryButton(
        label: l10n.continueButton,
        isLoading: _isLoading,
        onPressed: _isComplete ? _handleContinue : null,
      ),
      footer: AuthFooterNote(
        text: isRTL
            ? 'لا نشارك رقمك مع أي جهة.'
            : 'We never share your number.',
      ),
      children: [
        Form(
          key: _formKey,
          child: _PhoneField(
            controller: _phoneController,
            isRTL: isRTL,
          ),
        ),
      ],
    );
  }
}

/// The number is the only thing on this screen, so it gets the full width and a
/// type size that stays readable while typing.
class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller, required this.isRTL});

  final TextEditingController controller;
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    // The prefix, the digits and the hint are one left-to-right unit. Without
    // this the prefix is pushed to the far side of the field in Arabic.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      // Phone numbers read left to right whatever the app language is.
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      autofocus: true,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: '7 9123 4567',
        hintStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: Colors.grey.shade300,
        ),
        // Reads as part of the field rather than a badge floating inside it.
        prefix: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            '+962',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        border: _border(AppColors.surface),
        enabledBorder: _border(AppColors.surface),
        focusedBorder: _border(AppColors.primary, width: 1.6),
        errorBorder: _border(Colors.red.shade300),
        focusedErrorBorder: _border(Colors.red.shade400, width: 1.6),
        errorStyle: const TextStyle(fontSize: 13, height: 1.5),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isRTL ? 'الرجاء إدخال رقم الهاتف' : 'Please enter phone number';
        }

        var normalized = value;
        if (normalized.startsWith('0')) {
          normalized = normalized.substring(1);
        }

        if (normalized.length != 9) {
          return isRTL
              ? 'الرقم يجب أن يتكوّن من 9 خانات بعد الصفر'
              : 'The number must be 9 digits';
        }

        if (!normalized.startsWith('7')) {
          return isRTL
              ? 'أرقام الهواتف الأردنية تبدأ بـ 7'
              : 'Jordanian mobile numbers start with 7';
        }

          return null;
        },
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.4}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
