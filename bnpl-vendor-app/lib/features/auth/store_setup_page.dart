import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/image_source_sheet.dart';
import '../../core/widgets/ui.dart';
import 'auth_frame.dart';

String categoryName(Map<String, dynamic> category, bool arabic) {
  final ar = pick(category, 'nameAr', 'name_ar')?.toString();
  final en = category['name']?.toString() ?? '';
  return arabic && ar != null && ar.isNotEmpty ? ar : en;
}

/// Shown once after sign-up, as on the portal: the details customers see.
class StoreSetupPage extends StatefulWidget {
  const StoreSetupPage({super.key, this.initialName = ''});

  final String initialName;

  @override
  State<StoreSetupPage> createState() => _StoreSetupPageState();
}

class _StoreSetupPageState extends State<StoreSetupPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  final _nameAr = TextEditingController();
  final _description = TextEditingController();
  final _descriptionAr = TextEditingController();
  final _website = TextEditingController();
  final _contactPerson = TextEditingController();
  final _contactPhone = TextEditingController();
  final _address = TextEditingController();
  String? _logoUrl;
  int? _categoryId;
  List<Map<String, dynamic>> _categories = const [];
  bool _saving = false;
  bool _pickingLogo = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    context
        .read<SessionService>()
        .api
        .categories()
        .then((value) {
          if (mounted) setState(() => _categories = value);
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _nameAr,
      _description,
      _descriptionAr,
      _website,
      _contactPerson,
      _contactPhone,
      _address,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    setState(() => _pickingLogo = true);
    try {
      final file = await pickImage(context, maxSide: 200, quality: 70);
      if (file == null) return;
      if (await file.length() > kMaxImageBytes) {
        if (mounted) setState(() => _error = context.trNow('imageTooLarge'));
        return;
      }
      final url = await toDataUrl(file);
      if (mounted) setState(() => _logoUrl = url);
    } finally {
      if (mounted) setState(() => _pickingLogo = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final session = context.read<SessionService>();
    try {
      await session.api.updateStore(session.storeId, {
        'name': _name.text.trim(),
        'nameAr': _nameAr.text.trim(),
        'description': _description.text.trim(),
        'descriptionAr': _descriptionAr.text.trim(),
        'logoUrl': _logoUrl ?? '',
        'websiteUrl': _website.text.trim(),
        'contactPerson': _contactPerson.text.trim(),
        'contactPhone': _contactPhone.text.trim(),
        'address': _address.text.trim(),
        'categoryId': ?_categoryId,
      });
      if (!mounted) return;
      showToast(context, context.trNow('setupSuccess'));
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabic = context.isArabic;
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? context.trNow('requiredField') : null;

    return AuthFrame(
      title: context.tr('storeSetupTitle'),
      subtitle: context.tr('storeSetupSubtitle'),
      action: PrimaryButton(
        label: context.tr('finishSetup'),
        isLoading: _saving,
        onPressed: _submit,
      ),
      footer: TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
        child: Text(context.tr('skipForNow')),
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) FormErrorBanner(_error!),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
                child: Text(
                  context.tr('logo'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              ImagePickTile(
                imageUrl: _logoUrl,
                busy: _pickingLogo,
                onPick: _pickLogo,
                onRemove: () => setState(() => _logoUrl = null),
              ),
              const SizedBox(height: 20),
              LabeledField(
                label: context.tr('storeNameEn'),
                controller: _name,
                hint: 'Zara Official',
                icon: Icons.storefront_outlined,
                textDirection: TextDirection.ltr,
                validator: required,
              ),
              LabeledField(
                label: context.tr('storeNameAr'),
                controller: _nameAr,
                hint: 'زارا',
                icon: Icons.storefront_outlined,
                textDirection: TextDirection.rtl,
                validator: required,
              ),
              LabeledField(
                label: context.tr('descriptionEn'),
                controller: _description,
                hint: 'International fashion brand...',
                maxLines: 2,
                textDirection: TextDirection.ltr,
              ),
              LabeledField(
                label: context.tr('descriptionAr'),
                controller: _descriptionAr,
                hint: 'علامة أزياء عالمية...',
                maxLines: 2,
                textDirection: TextDirection.rtl,
              ),
              LabeledDropdown<int>(
                label: context.tr('category'),
                value: _categoryId,
                hint: context.tr('selectCategory'),
                icon: Icons.sell_outlined,
                items: [
                  for (final c in _categories)
                    DropdownMenuItem(
                      value: toInt(c['id']),
                      child: Text(categoryName(c, arabic)),
                    ),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              LabeledField(
                label: context.tr('websiteUrl'),
                controller: _website,
                hint: 'https://www.example.com',
                icon: Icons.language_rounded,
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
              ),
              LabeledField(
                label: context.tr('contactPerson'),
                controller: _contactPerson,
                hint: arabic ? 'محمد علي' : 'John Doe',
                icon: Icons.badge_outlined,
              ),
              LabeledField(
                label: context.tr('contactPhone'),
                controller: _contactPhone,
                hint: '+962 7XXXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
              ),
              LabeledField(
                label: context.tr('mainAddress'),
                controller: _address,
                hint: arabic ? 'عمان، شارع مكة...' : 'Amman, Mecca St...',
                icon: Icons.place_outlined,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
