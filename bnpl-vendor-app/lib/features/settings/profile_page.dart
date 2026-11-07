import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';

/// The person behind the store: their contact details and password.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileForm = GlobalKey<FormState>();
  final _passwordForm = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _savingProfile = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    final vendor = context.read<SessionService>().vendor ?? const {};
    _name = TextEditingController(text: '${vendor['name'] ?? ''}');
    _email = TextEditingController(text: '${vendor['email'] ?? ''}');
    _phone = TextEditingController(text: '${vendor['phone'] ?? ''}');
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _current, _next, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileForm.currentState!.validate()) return;
    final session = context.read<SessionService>();
    setState(() => _savingProfile = true);
    try {
      final user = await session.api.updateProfile({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': normalizePhone(_phone.text),
      });
      await session.updateVendor(user);
      if (mounted) showToast(context, context.trNow('profileSaved'));
    } catch (e) {
      if (mounted) showToast(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordForm.currentState!.validate()) return;
    setState(() => _savingPassword = true);
    try {
      await context.read<SessionService>().api.changePassword(
        _current.text,
        _next.text,
      );
      _current.clear();
      _next.clear();
      _confirm.clear();
      if (mounted) showToast(context, context.trNow('passwordChanged'));
    } catch (e) {
      if (mounted) showToast(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  String? _required(String? v) =>
      (v ?? '').trim().isEmpty ? context.trNow('requiredField') : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(context.tr('myProfile')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SectionTitle(context.tr('personalDetails')),
          const SizedBox(height: 10),
          SectionCard(
            child: Form(
              key: _profileForm,
              child: Column(
                children: [
                  LabeledField(
                    label: context.tr('fullName'),
                    controller: _name,
                    icon: Icons.person_outline_rounded,
                    validator: _required,
                  ),
                  LabeledField(
                    label: context.tr('emailLogin'),
                    controller: _email,
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    validator: (v) =>
                        RegExp(r'^\S+@\S+\.\S+$').hasMatch((v ?? '').trim())
                        ? null
                        : context.trNow('invalidEmail'),
                  ),
                  LabeledField(
                    label: context.tr('phoneNumber'),
                    controller: _phone,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    validator: _required,
                  ),
                  PrimaryButton(
                    label: context.tr('saveChanges'),
                    icon: Icons.save_outlined,
                    isLoading: _savingProfile,
                    onPressed: _saveProfile,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionTitle(
            context.tr('changePassword'),
            subtitle: context.tr('temporaryPasswordHint'),
          ),
          const SizedBox(height: 10),
          SectionCard(
            child: Form(
              key: _passwordForm,
              child: Column(
                children: [
                  LabeledField(
                    label: context.tr('currentPassword'),
                    controller: _current,
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                    validator: _required,
                  ),
                  LabeledField(
                    label: context.tr('newPassword'),
                    controller: _next,
                    icon: Icons.lock_reset_rounded,
                    obscure: true,
                    validator: (v) => (v ?? '').length < 8
                        ? context.trNow('passwordMin8')
                        : null,
                  ),
                  LabeledField(
                    label: context.tr('confirmPassword'),
                    controller: _confirm,
                    icon: Icons.lock_reset_rounded,
                    obscure: true,
                    validator: (v) => v != _next.text
                        ? context.trNow('passwordMismatch')
                        : null,
                  ),
                  PrimaryButton(
                    label: context.tr('changePassword'),
                    icon: Icons.key_rounded,
                    isLoading: _savingPassword,
                    onPressed: _changePassword,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
