import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/ui.dart';
import '../shell/merchant_shell.dart';
import 'product.dart';
import 'product_form_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _search = TextEditingController();
  List<Product> _products = const [];
  bool _loading = true;
  Object? _error;
  ValueNotifier<int>? _dataVersion;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataVersion ??= MerchantShell.of(context)?.dataVersion
      ?..addListener(_load);
  }

  @override
  void dispose() {
    _dataVersion?.removeListener(_load);
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final session = context.read<SessionService>();
    try {
      final list = await session.api.products(session.storeId);
      if (!mounted) return;
      setState(() {
        _products = list.map(Product.fromJson).toList();
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([Product? product]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProductFormPage(product: product)),
    );
    if (saved == true && mounted) {
      showToast(context, context.trNow('productSaved'));
      MerchantShell.of(context)?.notifyDataChanged();
    }
  }

  Future<void> _delete(Product product) async {
    final confirmed = await confirmDialog(
      context,
      message: context.trNow('deleteConfirm'),
      confirmLabel: context.trNow('delete'),
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await context.read<SessionService>().api.deleteProduct(product.id);
      if (!mounted) return;
      showToast(context, context.trNow('productDeleted'));
      MerchantShell.of(context)?.notifyDataChanged();
    } catch (e) {
      if (mounted) showToast(context, errorMessage(context, e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabic = context.isArabic;
    final query = _search.text.trim();
    final visible = _products.where((p) => p.matches(query)).toList();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.only(bottom: GlassBottomNav.clearance(context)),
          children: [
            PageHeader(
              title: context.tr('productList'),
              subtitle: '${context.tr('navProducts')} (${_products.length})',
              trailing: FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(context.tr('addProduct')),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: context.tr('searchProduct'),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            if (_loading)
              const LoadingState()
            else if (_error != null && _products.isEmpty)
              ErrorState(
                message: errorMessage(context, _error!),
                onRetry: _load,
              )
            else if (visible.isEmpty)
              EmptyState(
                icon: Icons.inventory_2_outlined,
                title: context.tr('noProducts'),
                subtitle: _products.isEmpty
                    ? context.tr('addFirstProduct')
                    : null,
              )
            else
              for (final product in visible)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _ProductCard(
                    product: product,
                    arabic: arabic,
                    onEdit: () => _openForm(product),
                    onDelete: () => _delete(product),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.arabic,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final bool arabic;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr('currency');
    final (stockKey, stockTone) = switch (product.stockLevel) {
      StockLevel.inStock => ('inStock', StatusTone.success),
      StockLevel.low => ('lowStock', StatusTone.warning),
      StockLevel.out => ('outOfStock', StatusTone.danger),
    };

    return SectionCard(
      onTap: onEdit,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: NetImage(url: product.imageUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName(arabic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    if (product.displayDescription(arabic).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.displayDescription(arabic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          money(
                            product.hasDiscount
                                ? product.discountPrice!
                                : product.price,
                            currency,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 8),
                          Text(
                            number(product.price),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textHint,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textHint,
                ),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(context.tr('editProduct')),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      title: Text(
                        context.tr('deleteProduct'),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                StatusChip(
                  label: '${context.tr(stockKey)} (${product.stockQuantity})',
                  tone: stockTone,
                ),
                const Spacer(),
                _Metric(
                  label: context.tr('salesCount'),
                  value: '${product.salesCount}',
                ),
                const SizedBox(width: 16),
                _Metric(
                  label: context.tr('earnings'),
                  value: money(product.totalRevenue, currency),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.heading,
          ),
        ),
      ],
    );
  }
}
