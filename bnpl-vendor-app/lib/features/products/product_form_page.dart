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
import 'product.dart';

/// Add or edit a product, with the same fields and payload as the portal's
/// product dialog.
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final Product? p = widget.product;
  late final _name = TextEditingController(text: p?.name);
  late final _nameAr = TextEditingController(text: p?.nameAr);
  late final _description = TextEditingController(text: p?.description);
  late final _descriptionAr = TextEditingController(text: p?.descriptionAr);
  late final _price = TextEditingController(
    text: p == null ? '' : number(p!.price).replaceAll(',', ''),
  );
  late final _discount = TextEditingController(
    text: p?.discountPrice == null
        ? ''
        : number(p!.discountPrice!).replaceAll(',', ''),
  );
  late final _stock = TextEditingController(text: '${p?.stockQuantity ?? 50}');
  late int? _categoryId = p?.categoryId;
  late String? _imageUrl = p?.imageUrl;
  List<Map<String, dynamic>> _categories = const [];
  bool _uploading = false;
  bool _saving = false;
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
      _price,
      _discount,
      _stock,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await pickImage(context, maxSide: 800, quality: 80);
    if (file == null || !mounted) return;
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      final url = await context.read<SessionService>().api.uploadProductImage(
        file.path,
      );
      if (mounted) setState(() => _imageUrl = url);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = errorMessage(context, e, fallbackKey: 'uploadFailed'),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  double? _parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<SessionService>();
    setState(() {
      _saving = true;
      _error = null;
    });

    final discount = _parse(_discount.text);
    final payload = <String, dynamic>{
      'name': _name.text.trim(),
      'name_ar': _nameAr.text.trim(),
      'description': _description.text.trim(),
      'description_ar': _descriptionAr.text.trim(),
      'price': _parse(_price.text),
      'stock_quantity': int.tryParse(_stock.text.trim()) ?? 0,
      'in_stock': true,
      'store_id': session.storeId,
      'discount_price': ?discount,
      'category_id': ?_categoryId,
      if (_imageUrl != null && _imageUrl!.isNotEmpty) 'image_url': _imageUrl,
    };

    try {
      if (p == null) {
        await session.api.createProduct(payload);
      } else {
        await session.api.updateProduct(p!.id, payload);
      }
      if (mounted) Navigator.of(context).pop(true);
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
    String? requiredNumber(String? v) {
      final missing = required(v);
      if (missing != null) return missing;
      return _parse(v!) == null ? context.trNow('requiredField') : null;
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(context.tr(p == null ? 'addProduct' : 'editProduct')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (_error != null) FormErrorBanner(_error!),
            _Section(
              icon: Icons.image_outlined,
              title: context.tr('productMedia'),
              children: [
                ImagePickTile(
                  imageUrl: _imageUrl,
                  busy: _uploading,
                  height: 190,
                  fit: BoxFit.cover,
                  onPick: _pickImage,
                  onRemove: () => setState(() => _imageUrl = null),
                ),
              ],
            ),
            _Section(
              icon: Icons.text_fields_rounded,
              title: context.tr('basicInfo'),
              children: [
                LabeledField(
                  label: context.tr('productName'),
                  controller: _name,
                  hint: 'e.g. iPhone 15 Pro',
                  textDirection: TextDirection.ltr,
                  validator: required,
                ),
                LabeledField(
                  label: context.tr('productNameAr'),
                  controller: _nameAr,
                  hint: 'مثال: ايفون 15 برو',
                  textDirection: TextDirection.rtl,
                ),
                LabeledDropdown<int>(
                  label: context.tr('category'),
                  value: _categoryId,
                  hint: context.tr('selectCategory'),
                  icon: Icons.layers_outlined,
                  validator: (v) =>
                      v == null ? context.trNow('requiredField') : null,
                  items: [
                    for (final c in _categories)
                      DropdownMenuItem(
                        value: toInt(c['id']),
                        child: Text(categoryName(c, arabic)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
              ],
            ),
            _Section(
              icon: Icons.payments_outlined,
              title: context.tr('pricingInventory'),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LabeledField(
                        label: context.tr('productPrice'),
                        controller: _price,
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textDirection: TextDirection.ltr,
                        validator: requiredNumber,
                        suffix: _CurrencySuffix(context.tr('currency')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LabeledField(
                        label: context.tr('discountPrice'),
                        controller: _discount,
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textDirection: TextDirection.ltr,
                        suffix: _CurrencySuffix(context.tr('currency')),
                      ),
                    ),
                  ],
                ),
                LabeledField(
                  label: context.tr('stockQuantity'),
                  controller: _stock,
                  hint: '0',
                  icon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  validator: (v) => int.tryParse(v?.trim() ?? '') == null
                      ? context.trNow('requiredField')
                      : null,
                ),
              ],
            ),
            _Section(
              icon: Icons.notes_rounded,
              title: context.tr('descriptions'),
              children: [
                LabeledField(
                  label: context.tr('descriptionEn'),
                  controller: _description,
                  hint: 'Product details...',
                  maxLines: 3,
                  textDirection: TextDirection.ltr,
                ),
                LabeledField(
                  label: context.tr('descriptionAr'),
                  controller: _descriptionAr,
                  hint: 'تفاصيل المنتج...',
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: PrimaryButton(
          label: context.tr(p == null ? 'createProduct' : 'saveChanges'),
          isLoading: _saving,
          onPressed: _uploading ? null : _save,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _CurrencySuffix extends StatelessWidget {
  const _CurrencySuffix(this.currency);

  final String currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        widthFactor: 1,
        child: Text(
          currency,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }
}
