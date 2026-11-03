import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui.dart';
import 'auth_frame.dart';
import 'store_setup_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _storeName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _storeName, _phone, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final session = context.read<SessionService>();
    try {
      await session.register({
        'name': _name.text.trim(),
        'storeName': _storeName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'password': _password.text,
      });
      if (!mounted) return;
      // Signing in swaps the root to the shell; store setup goes on top of it
      // so finishing (or skipping) lands on the dashboard.
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => StoreSetupPage(initialName: _storeName.text.trim()),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = errorMessage(context, e, fallbackKey: 'loginError'),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? context.trNow('requiredField') : null;

    return AuthFrame(
      showBack: true,
      title: context.tr('joinAsPartner'),
      subtitle: context.tr('signupSubtitle'),
      action: PrimaryButton(
        label: context.tr('createAccountAndStart'),
        isLoading: _loading,
        onPressed: _submit,
      ),
      footer: AuthSwitchLink(
        prompt: context.tr('haveAccount'),
        link: context.tr('loginLinkText'),
        onTap: () => Navigator.of(context).pop(),
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) FormErrorBanner(_error!),
              LabeledField(
                label: context.tr('fullName'),
                controller: _name,
                hint: context.isArabic ? 'احمد علي' : 'John Doe',
                icon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: required,
              ),
              LabeledField(
                label: context.tr('storeName'),
                controller: _storeName,
                hint: context.isArabic ? 'زارا - عمان' : 'Zara - Amman',
                icon: Icons.storefront_outlined,
                textInputAction: TextInputAction.next,
                validator: required,
              ),
              LabeledField(
                label: context.tr('phoneNumber'),
                controller: _phone,
                hint: '+962 7XXXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.next,
                validator: required,
              ),
              LabeledField(
                label: context.tr('email'),
                controller: _email,
                hint: 'vendor@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final missing = required(v);
                  if (missing != null) return missing;
                  return v!.contains('@')
                      ? null
                      : context.trNow('invalidEmail');
                },
              ),
              LabeledField(
                label: context.tr('password'),
                controller: _password,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.done,
                validator: required,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 15,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.tr('secureNote'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
