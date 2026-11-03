import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/image_source_sheet.dart';
import '../../core/widgets/ui.dart';
import '../auth/auth_frame.dart';
import '../auth/store_setup_page.dart';

class StoreSettingsPage extends StatefulWidget {
  const StoreSettingsPage({super.key});

  @override
  State<StoreSettingsPage> createState() => _StoreSettingsPageState();
}

class _StoreSettingsPageState extends State<StoreSettingsPage> {
  final _name = TextEditingController();
  final _nameAr = TextEditingController();
  final _description = TextEditingController();
  final _descriptionAr = TextEditingController();
  final _website = TextEditingController();
  final _storeUrl = TextEditingController();
  final _minOrder = TextEditingController();
  final _maxOrder = TextEditingController();
  final _address = TextEditingController();
  String? _logoUrl;
  int? _categoryId;
  int? _genderCategoryId;
  int _productsCount = 0;
  List<Map<String, dynamic>> _categories = const [];
  bool _loading = true;
  bool _saving = false;
  bool _pickingLogo = false;
  Object? _loadError;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _nameAr,
      _description,
      _descriptionAr,
      _website,
      _storeUrl,
      _minOrder,
      _maxOrder,
      _address,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final session = context.read<SessionService>();
    setState(() {
      _loading = true;
      _loadError = null;
    });
    session.api
        .categories()
        .then((value) {
          if (mounted) setState(() => _categories = value);
        })
        .catchError((_) {});
    try {
      final s = await session.api.store(session.storeId);
      String text(dynamic v) => v == null ? '' : '$v';
      _name.text = text(s['name']);
      _nameAr.text = text(s['nameAr']);
      _description.text = text(s['description']);
      _descriptionAr.text = text(s['descriptionAr']);
      _website.text = text(s['websiteUrl']);
      _storeUrl.text = text(s['storeUrl']);
      _minOrder.text = s['minOrderAmount'] == null
          ? ''
          : number(toDouble(s['minOrderAmount'])).replaceAll(',', '');
      _maxOrder.text = s['maxOrderAmount'] == null
          ? ''
          : number(toDouble(s['maxOrderAmount'])).replaceAll(',', '');
      _address.text = text(s['address']);
      if (!mounted) return;
      setState(() {
        _logoUrl = s['logoUrl']?.toString();
        _categoryId = s['categoryId'] == null ? null : toInt(s['categoryId']);
        _genderCategoryId = s['genderCategoryId'] == null
            ? null
            : toInt(s['genderCategoryId']);
        _productsCount = toInt(s['productsCount']);
      });
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickLogo() async {
    setState(() => _pickingLogo = true);
    try {
      final file = await pickImage(context, maxSide: 400, quality: 75);
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

  Future<void> _save() async {
    final session = context.read<SessionService>();
    setState(() {
      _saving = true;
      _error = null;
    });
    double? amount(TextEditingController c) =>
        double.tryParse(c.text.trim().replaceAll(',', '.'));
    try {
      await session.api.updateStore(session.storeId, {
        'name': _name.text.trim(),
        'nameAr': _nameAr.text.trim(),
        'description': _description.text.trim(),
        'descriptionAr': _descriptionAr.text.trim(),
        'logoUrl': _logoUrl ?? '',
        'websiteUrl': _website.text.trim(),
        'storeUrl': _storeUrl.text.trim(),
        'categoryId': _categoryId,
        'genderCategoryId': _genderCategoryId,
        'minOrderAmount': ?amount(_minOrder),
        'maxOrderAmount': ?amount(_maxOrder),
        'address': _address.text.trim(),
      });
      if (mounted) showToast(context, context.trNow('setupSuccess'));
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabic = context.isArabic;
    final genders = [
      (1, context.tr('women')),
      (2, context.tr('men')),
      (3, context.tr('kids')),
      (4, context.tr('unisex')),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(context.tr('storeSettings')),
      ),
      body: _loading
          ? const LoadingState()
          : _loadError != null
          ? ErrorState(
              message: errorMessage(context, _loadError!),
              onRetry: _load,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (_error != null) FormErrorBanner(_error!),
                SectionCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: ImagePickTile(
                          imageUrl: _logoUrl,
                          busy: _pickingLogo,
                          height: 96,
                          onPick: _pickLogo,
                          onRemove: () => setState(() => _logoUrl = null),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              arabic && _nameAr.text.isNotEmpty
                                  ? _nameAr.text
                                  : _name.text,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.heading,
                              ),
                            ),
                            const SizedBox(height: 6),
                            StatusChip(
                              label: context.tr('accountActive'),
                              tone: StatusTone.success,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${context.tr('productsCount')}: $_productsCount',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitle(context.tr('basicInfo')),
                      const SizedBox(height: 16),
                      LabeledField(
                        label: context.tr('storeNameEn'),
                        controller: _name,
                        icon: Icons.storefront_outlined,
                        textDirection: TextDirection.ltr,
                        onChanged: (_) => setState(() {}),
                      ),
                      LabeledField(
                        label: context.tr('storeNameAr'),
                        controller: _nameAr,
                        icon: Icons.storefront_outlined,
                        textDirection: TextDirection.rtl,
                        onChanged: (_) => setState(() {}),
                      ),
                      LabeledField(
                        label: context.tr('descriptionEn'),
                        controller: _description,
                        maxLines: 2,
                        textDirection: TextDirection.ltr,
                      ),
                      LabeledField(
                        label: context.tr('descriptionAr'),
                        controller: _descriptionAr,
                        maxLines: 2,
                        textDirection: TextDirection.rtl,
                      ),
                      LabeledDropdown<int>(
                        label: context.tr('mainCategory'),
                        value: _categoryId,
                        hint: context.tr('selectCategory'),
                        icon: Icons.layers_outlined,
                        items: [
                          for (final c in _categories)
                            DropdownMenuItem(
                              value: toInt(c['id']),
                              child: Text(categoryName(c, arabic)),
                            ),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                      LabeledDropdown<int>(
                        label: context.tr('genderCategory'),
                        value: _genderCategoryId,
                        hint: context.tr('selectCategory'),
                        icon: Icons.people_alt_outlined,
                        items: [
                          for (final (id, name) in genders)
                            DropdownMenuItem(value: id, child: Text(name)),
                        ],
                        onChanged: (v) => setState(() => _genderCategoryId = v),
                      ),
                      LabeledField(
                        label: context.tr('websiteUrl'),
                        controller: _website,
                        hint: 'https://example.com',
                        icon: Icons.language_rounded,
                        keyboardType: TextInputType.url,
                        textDirection: TextDirection.ltr,
                      ),
                      LabeledField(
                        label: context.tr('storeUrl'),
                        controller: _storeUrl,
                        hint: 'store-slug',
                        icon: Icons.link_rounded,
                        textDirection: TextDirection.ltr,
                      ),
                      LabeledField(
                        label: context.tr('mainAddress'),
                        controller: _address,
                        icon: Icons.place_outlined,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitle(context.tr('orderLimits')),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: LabeledField(
                              label: context.tr('minOrder'),
                              controller: _minOrder,
                              hint: '50',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LabeledField(
                              label: context.tr('maxOrder'),
                              controller: _maxOrder,
                              hint: '5000',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _loading || _loadError != null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                label: context.tr('saveChanges'),
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
    );
  }
}
