import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/widgets/ui.dart';
import 'auth_frame.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<SessionService>().login(_email.text, _password.text);
      // The root swaps to the shell once the session is signed in.
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
      title: context.tr('loginTitle'),
      subtitle: context.tr('loginWelcome'),
      action: PrimaryButton(
        label: context.tr('loginButton'),
        isLoading: _loading,
        onPressed: _submit,
      ),
      footer: AuthSwitchLink(
        prompt: context.tr('noAccount'),
        link: context.tr('signupLinkText'),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SignupPage())),
      ),
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                if (_error != null) FormErrorBanner(_error!),
                LabeledField(
                  label: context.tr('email'),
                  controller: _email,
                  hint: 'example@store.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.next,
                  validator: required,
                ),
                LabeledField(
                  label: context.tr('password'),
                  controller: _password,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.done,
                  validator: required,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
