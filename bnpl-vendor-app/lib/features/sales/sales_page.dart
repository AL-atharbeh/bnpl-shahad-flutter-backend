import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/ui.dart';
import '../shell/merchant_shell.dart';

enum _View { sales, transactions }

/// The portal's sales operations and transactions pages, side by side under
/// one tab.
class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  _View _view = _View.sales;
  final _search = TextEditingController();

  Map<String, dynamic>? _sales;
  List<Map<String, dynamic>> _transactions = const [];
  bool _loading = true;
  Object? _error;
  final Set<int> _expanded = {};
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
      final results = await Future.wait([
        session.api.salesDetailed(session.storeId),
        session.api.transactions(session.storeId),
      ]);
      if (!mounted) return;
      setState(() {
        _sales = results[0] as Map<String, dynamic>;
        _transactions = results[1] as List<Map<String, dynamic>>;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _saleList {
    final raw = _sales?['sales'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  bool _matches(String? name, Object? orderId) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return (name ?? '').toLowerCase().contains(q) ||
        '${orderId ?? ''}'.toLowerCase().contains(q);
  }

  void _shareReceipt(Map<String, dynamic> sale) {
    final lang = context.read<LanguageService>();
    final currency = lang.tr('currency');
    final items = (sale['items'] as List? ?? const []).whereType<Map>();
    final lines = [
      '${lang.tr('appName')} — ${lang.tr('receipt')}',
      '',
      '${lang.tr('orderId')}: #${sale['orderId']}',
      '${lang.tr('customer')}: ${sale['customerName']} (${sale['customerPhone']})',
      '${lang.tr('date')}: ${dateTime(parseDate(sale['createdAt']), lang.code)}',
      '',
      '${lang.tr('items')}:',
      for (final item in items)
        '• ${item['name']}  ×${item['quantity']}  ${money(toDouble(item['price']), currency)}',
      '',
      '${lang.tr('totalAmount')}: ${money(toDouble(sale['totalAmount']), currency, fixed: true)}',
    ];
    SharePlus.instance.share(
      ShareParams(text: lines.join('\n'), subject: lang.tr('receipt')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSales = _view == _View.sales;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.only(bottom: GlassBottomNav.clearance(context)),
          children: [
            PageHeader(
              title: context.tr(isSales ? 'salesOps' : 'transactions'),
              subtitle: context.tr(
                isSales ? 'salesOpsDescription' : 'transactionsDescription',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: SegmentedButton<_View>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: _View.sales,
                    label: Text(context.tr('salesOps')),
                  ),
                  ButtonSegment(
                    value: _View.transactions,
                    label: Text(context.tr('transactions')),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (s) => setState(() => _view = s.first),
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.white,
                  selectedBackgroundColor: AppColors.primary,
                  selectedForegroundColor: Colors.white,
                  foregroundColor: AppColors.textMuted,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(46),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (_loading)
              const LoadingState()
            else if (_error != null && _sales == null)
              ErrorState(
                message: errorMessage(context, _error!),
                onRetry: _load,
              )
            else ...[
              if (isSales) _buildMetrics(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: context.tr('searchPlaceholder'),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              ...(isSales ? _buildSales(context) : _buildTransactions(context)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetrics(BuildContext context) {
    final m = _sales?['metrics'] is Map
        ? Map<String, dynamic>.from(_sales!['metrics'])
        : <String, dynamic>{};
    final currency = context.tr('currency');
    final tiles = [
      (
        Icons.inventory_2_rounded,
        context.tr('piecesSold'),
        number(toInt(m['totalPiecesSold'])),
        AppColors.success,
      ),
      (
        Icons.people_alt_rounded,
        context.tr('activeCustomers'),
        number(toInt(m['totalCustomers'])),
        AppColors.info,
      ),
      (
        Icons.trending_up_rounded,
        context.tr('totalVolume'),
        money(toDouble(m['totalVolume']), currency),
        AppColors.success,
      ),
      (
        Icons.payments_rounded,
        context.tr('totalCollections'),
        money(toDouble(m['totalCollected']), currency),
        AppColors.info,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.7,
        children: [
          for (final (icon, label, value, color) in tiles)
            SectionCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSales(BuildContext context) {
    final sales = _saleList
        .where((s) => _matches(s['customerName']?.toString(), s['orderId']))
        .toList();
    if (sales.isEmpty) {
      return [
        EmptyState(
          icon: Icons.receipt_long_outlined,
          title: context.tr('noTransactions'),
        ),
      ];
    }
    return [
      for (final sale in sales)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: _SaleCard(
            sale: sale,
            expanded: _expanded.contains(toInt(sale['id'])),
            onToggle: () => setState(() {
              final id = toInt(sale['id']);
              _expanded.contains(id) ? _expanded.remove(id) : _expanded.add(id);
            }),
            onShare: () => _shareReceipt(sale),
          ),
        ),
    ];
  }

  List<Widget> _buildTransactions(BuildContext context) {
    final list = _transactions.where((t) {
      final user = t['user'] is Map ? t['user'] as Map : const {};
      return _matches(user['name']?.toString(), t['orderId'] ?? t['id']);
    }).toList();
    if (list.isEmpty) {
      return [
        EmptyState(
          icon: Icons.receipt_long_outlined,
          title: context.tr('noTransactions'),
        ),
      ];
    }
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < list.length; i++) ...[
                if (i > 0) const Divider(indent: 16, endIndent: 16),
                _TransactionRow(payment: list[i]),
              ],
            ],
          ),
        ),
      ),
    ];
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    required this.expanded,
    required this.onToggle,
    required this.onShare,
  });

  final Map<String, dynamic> sale;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr('currency');
    final locale = context.watch<LanguageService>().code;
    final total = toDouble(sale['totalAmount']);
    final collected = toDouble(sale['collectedAmount']);
    final progress = total > 0 ? (collected / total).clamp(0.0, 1.0) : 0.0;
    final status = describeStatus(sale['status']?.toString());
    final items = (sale['items'] as List? ?? const [])
        .whereType<Map>()
        .toList();

    return SectionCard(
      onTap: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${sale['orderId']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sale['customerName']?.toString() ??
                          context.tr('unknownCustomer'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    Text(
                      sale['customerPhone']?.toString() ?? '',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 12.5,
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
                    money(total, currency),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(label: context.tr(status.key), tone: status.tone),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                context.tr('paymentProgress'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}% · ${money(collected, currency)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.hairline,
              color: AppColors.primaryLight,
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textHint.withValues(alpha: 0.8),
              ),
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(),
                ),
                Text(
                  context.tr('items'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 6),
                for (final item in items)
                  InfoRow(
                    label: '${item['name']}  ×${item['quantity']}',
                    value: money(
                      toDouble(item['price']) * toInt(item['quantity']),
                      currency,
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  context.tr('sessionDetails'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 6),
                InfoRow(
                  label: context.tr('orderDate'),
                  value: dateTime(parseDate(sale['createdAt']), locale),
                ),
                InfoRow(
                  label: context.tr('grossAmount'),
                  value: money(total, currency, fixed: true),
                ),
                InfoRow(
                  label: context.tr('deductedCommission'),
                  value:
                      '-${money(toDouble(sale['totalCommission']), currency, fixed: true)}',
                  valueColor: AppColors.error,
                ),
                InfoRow(
                  label: context.tr('finalNet'),
                  value: money(
                    toDouble(sale['netAmount']),
                    currency,
                    fixed: true,
                  ),
                  valueColor: AppColors.accent,
                  bold: true,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: Text(context.tr('shareReceipt')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.green100),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.payment});

  final Map<String, dynamic> payment;

  @override
  Widget build(BuildContext context) {
    final user = payment['user'] is Map
        ? Map<String, dynamic>.from(payment['user'])
        : const <String, dynamic>{};
    final installments = toInt(payment['installmentsCount']) == 0
        ? 1
        : toInt(payment['installmentsCount']);
    // As on the portal: the order's value is one installment times their count.
    final value = toDouble(payment['amount']) * installments;
    final completed = payment['status']?.toString() == 'completed';
    final locale = context.watch<LanguageService>().code;
    final orderId = '${payment['orderId'] ?? payment['id']}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (completed ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check_rounded : Icons.schedule_rounded,
              size: 20,
              color: completed ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']?.toString() ?? context.tr('unknownCustomer'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '#${orderId.length > 12 ? orderId.substring(orderId.length - 12) : orderId} · ${shortDate(parseDate(payment['createdAt']), locale)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(value, context.tr('currency')),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 4),
              StatusChip(
                label: context.tr(completed ? 'paid' : 'processing'),
                tone: completed ? StatusTone.success : StatusTone.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
