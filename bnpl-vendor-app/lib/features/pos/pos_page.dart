import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/ui.dart';
import '../products/product.dart';
import '../shell/merchant_shell.dart';
import 'checkout_page.dart';
import 'pos_cart.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final _cart = PosCart();
  final _search = TextEditingController();
  List<Product> _products = const [];
  List<Map<String, dynamic>> _recent = const [];
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
      ?..addListener(_loadProducts);
  }

  @override
  void dispose() {
    _dataVersion?.removeListener(_loadProducts);
    _cart.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() => Future.wait([_loadProducts(), _loadRecent()]);

  Future<void> _loadProducts() async {
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

  Future<void> _loadRecent() async {
    final session = context.read<SessionService>();
    try {
      final list = await session.api.recentSessions(session.storeId);
      if (mounted) setState(() => _recent = list);
    } catch (_) {
      // Recent activity is a convenience; the counter still works without it.
    }
  }

  Future<void> _openCheckout() async {
    final completed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => CheckoutPage(cart: _cart)));
    if (!mounted) return;
    _loadRecent();
    if (completed == true) {
      _cart.clear();
      MerchantShell.of(context)?.notifyDataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabic = context.isArabic;
    final currency = context.tr('currency');
    final query = _search.text.trim();
    final visible = _products.where((p) => p.matches(query)).toList();
    final navClearance = GlassBottomNav.clearance(context);

    return ListenableBuilder(
      listenable: _cart,
      builder: (context, _) {
        return Stack(
          children: [
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: PageHeader(
                        title: context.tr('pos'),
                        subtitle: context.tr('posDescription'),
                        trailing: _cart.isEmpty
                            ? null
                            : IconButton(
                                onPressed: _cart.clear,
                                tooltip: context.tr('clearCart'),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.error.withValues(
                                    alpha: 0.08,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.error,
                                ),
                              ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
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
                            suffixIcon: query.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () => setState(_search.clear),
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (_loading)
                      const SliverToBoxAdapter(child: LoadingState())
                    else if (_error != null && _products.isEmpty)
                      SliverToBoxAdapter(
                        child: ErrorState(
                          message: errorMessage(context, _error!),
                          onRetry: _load,
                        ),
                      )
                    else if (_products.isEmpty)
                      SliverToBoxAdapter(
                        child: EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: context.tr('noProducts'),
                          subtitle: context.tr('addFirstProduct'),
                          action: PillButton(
                            label: context.tr('addProduct'),
                            icon: Icons.add_rounded,
                            onTap: () => MerchantShell.of(
                              context,
                            )?.goTo(MerchantShellState.products),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                          itemCount: visible.length,
                          itemBuilder: (context, i) {
                            final product = visible[i];
                            return _ProductTile(
                              product: product,
                              arabic: arabic,
                              currency: currency,
                              inCart: _cart.quantityOf(product),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _cart.add(product);
                              },
                            );
                          },
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                        child: SectionTitle(context.tr('recentActivity')),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _RecentActivity(sessions: _recent),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: navClearance + (_cart.isEmpty ? 0 : 84),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_cart.isEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: navClearance,
                child: _CartBar(
                  count: _cart.itemCount,
                  total: money(_cart.total, currency),
                  label: context.tr('checkout'),
                  onTap: _openCheckout,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.arabic,
    required this.currency,
    required this.inCart,
    required this.onTap,
  });

  final Product product;
  final bool arabic;
  final String currency;
  final int inCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: inCart > 0 ? AppColors.primaryLight : AppColors.hairline,
              width: inCart > 0 ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetImage(url: product.imageUrl),
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Container(
                          key: ValueKey(inCart),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: inCart > 0
                                ? AppColors.pillGradient
                                : null,
                            color: inCart > 0 ? null : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: inCart > 0
                              ? Text(
                                  '×$inCart',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName(arabic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      money(product.price, currency),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.count,
    required this.total,
    required this.label,
    required this.onTap,
  });

  final int count;
  final String total;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.sessions});

  final List<Map<String, dynamic>> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return SectionCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              context.tr('noRecentActivity'),
              style: const TextStyle(color: AppColors.textHint),
            ),
          ),
        ),
      );
    }

    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < sessions.length; i++) ...[
            if (i > 0) const Divider(indent: 16, endIndent: 16),
            _RecentRow(session: sessions[i]),
          ],
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.session});

  final Map<String, dynamic> session;

  @override
  Widget build(BuildContext context) {
    final user = session['user'] is Map
        ? Map<String, dynamic>.from(session['user'])
        : const <String, dynamic>{};
    final phone =
        pick(session, 'customerPhone', 'customer_phone')?.toString() ?? '';
    final name =
        user['name']?.toString() ??
        (phone.isNotEmpty ? phone : context.tr('unknownCustomer'));
    final status = describeStatus(session['status']?.toString());
    final amount = toDouble(pick(session, 'totalAmount', 'total_amount'));
    // Every store sells in dinars; show the localised symbol, not the code.
    final currency = context.tr('currency');
    final created = parseDate(pick(session, 'createdAt', 'created_at'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.green50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (phone.isNotEmpty && phone != name) phone,
                    time(created),
                  ].join(' · '),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(amount, currency),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              StatusChip(label: context.tr(status.key), tone: status.tone),
            ],
          ),
        ],
      ),
    );
  }
}
