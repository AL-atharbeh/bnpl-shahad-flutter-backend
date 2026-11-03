import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';

/// Rates may arrive as fractions (0.03) or percents (3); both become percents,
/// exactly as the portal reads them.
double _rate(dynamic value) {
  final x = toDouble(value);
  return x > 0 && x < 1 ? x * 100 : x;
}

class _Order {
  _Order({
    required this.orderId,
    required this.productValue,
    required this.bankShare,
    required this.platformShare,
    required this.vendorNet,
    required this.paidAmount,
    required this.paidInstallments,
    required this.totalInstallments,
    required this.date,
  });

  final String orderId;
  final double productValue;
  final double bankShare;
  final double platformShare;
  final double vendorNet;
  double paidAmount;
  int paidInstallments;
  final int totalInstallments;
  final DateTime? date;
}

/// Final profits: the portal's finance page, computed the same way from the
/// store's payments and commission rates.
class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  bool _loading = true;
  Object? _error;
  List<_Order> _orders = const [];
  double _bankRate = 3;
  double _platformRate = 2;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = context.read<SessionService>();
    final api = session.api;
    try {
      final results = await Future.wait<dynamic>([
        api.commissionSettings().catchError((_) => <String, dynamic>{}),
        api.store(session.storeId).catchError((_) => <String, dynamic>{}),
        api.transactions(session.storeId, limit: 1000),
      ]);
      final settings = results[0] as Map<String, dynamic>;
      final store = results[1] as Map<String, dynamic>;
      final payments = results[2] as List<Map<String, dynamic>>;

      final globalBank = _rate(settings['bankCommission'] ?? 0.03);
      final globalPlatform = _rate(settings['platformCommission'] ?? 0.02);
      final storeBank = store['bankCommissionRate'];
      final storePlatform = store['platformCommissionRate'];

      final orders = <String, _Order>{};
      for (final p in payments) {
        final orderId = p['orderId']?.toString();
        if (orderId == null || orderId.isEmpty) continue;
        final amount = toDouble(p['amount']);
        final completed = p['status']?.toString() == 'completed';

        final existing = orders[orderId];
        if (existing != null) {
          if (completed) {
            existing.paidInstallments++;
            existing.paidAmount += amount;
          }
          continue;
        }

        final installments = toInt(p['installmentsCount']) == 0
            ? 1
            : toInt(p['installmentsCount']);
        final value = amount * installments;
        final br = storeBank != null
            ? _rate(storeBank)
            : (p['bankCommissionRate'] != null
                  ? _rate(p['bankCommissionRate'])
                  : globalBank);
        final pr = storePlatform != null
            ? _rate(storePlatform)
            : (p['platformCommissionRate'] != null
                  ? _rate(p['platformCommissionRate'])
                  : globalPlatform);

        orders[orderId] = _Order(
          orderId: orderId,
          productValue: value,
          bankShare: value * br / 100,
          platformShare: value * pr / 100,
          vendorNet: value * (1 - (br + pr) / 100),
          paidAmount: completed ? amount : 0,
          paidInstallments: completed ? 1 : 0,
          totalInstallments: installments,
          date: parseDate(p['createdAt']),
        );
      }

      final sorted = orders.values.toList()
        ..sort(
          (a, b) => (b.date?.millisecondsSinceEpoch ?? 0).compareTo(
            a.date?.millisecondsSinceEpoch ?? 0,
          ),
        );

      if (!mounted) return;
      setState(() {
        _orders = sorted;
        _bankRate = storeBank != null ? _rate(storeBank) : globalBank;
        _platformRate = storePlatform != null
            ? _rate(storePlatform)
            : globalPlatform;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.tr('currency');
    final locale = context.watch<LanguageService>().code;

    final totalSales = _orders.fold<double>(0, (s, o) => s + o.productValue);
    final totalNet = _orders.fold<double>(0, (s, o) => s + o.vendorNet);
    final totalCollected = _orders.fold<double>(0, (s, o) => s + o.paidAmount);
    final totalPending = totalSales - totalCollected;
    final totalBank = _orders.fold<double>(0, (s, o) => s + o.bankShare);
    final totalPlatform = _orders.fold<double>(
      0,
      (s, o) => s + o.platformShare,
    );
    final deduction = (_bankRate + _platformRate).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(context.tr('finance')),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            Text(
              context.tr('financeDescription'),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const LoadingState()
            else if (_error != null && _orders.isEmpty)
              ErrorState(
                message: errorMessage(context, _error!),
                onRetry: _load,
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('netRevenue'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        money(totalNet, currency, fixed: true),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(totalNet / (totalSales == 0 ? 1 : totalSales) * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Stat(
                        label: context.tr('grossSales'),
                        value: money(totalSales, currency),
                        detail:
                            '${_orders.length} ${context.tr('registeredSales')}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                        label: context.tr('collectedAmount'),
                        value: money(totalCollected, currency),
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Stat(
                label: context.tr('pendingInstallments'),
                value: money(totalPending, currency),
                color: AppColors.warning,
              ),
              const SizedBox(height: 24),
              SectionTitle(context.tr('deductionModel')),
              const SizedBox(height: 12),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InfoRow(
                      label: context.tr('bankShare'),
                      value: '${_bankRate.toStringAsFixed(1)}%',
                    ),
                    InfoRow(
                      label: context.tr('platformFee'),
                      value: '${_platformRate.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.tr('deductionNote'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.6,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('commissionSummary'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                      ),
                    ),
                    InfoRow(
                      label: context.tr('bankShare'),
                      value: money(totalBank, currency, fixed: true),
                    ),
                    InfoRow(
                      label: context.tr('platformFee'),
                      value: money(totalPlatform, currency, fixed: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionTitle(context.tr('breakdown')),
              const SizedBox(height: 12),
              if (_orders.isEmpty)
                SectionCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        context.tr('noOrders'),
                        style: const TextStyle(color: AppColors.textHint),
                      ),
                    ),
                  ),
                )
              else
                SectionCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < _orders.length; i++) ...[
                        if (i > 0) const Divider(indent: 16, endIndent: 16),
                        _OrderRow(
                          order: _orders[i],
                          locale: locale,
                          currency: currency,
                          afterLabel: '${context.tr('after')} $deduction%',
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.detail,
    this.color = AppColors.heading,
  });

  final String label;
  final String value;
  final String? detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail!,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.order,
    required this.locale,
    required this.currency,
    required this.afterLabel,
  });

  final _Order order;
  final String locale;
  final String currency;
  final String afterLabel;

  @override
  Widget build(BuildContext context) {
    final id = order.orderId.length > 8
        ? order.orderId.substring(order.orderId.length - 8)
        : order.orderId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${id.toUpperCase()}',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${shortDate(order.date, locale)} · ${order.paidInstallments}/${order.totalInstallments}',
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
                money(order.vendorNet, currency, fixed: true),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
              Text(
                '${money(order.productValue, currency)} · $afterLabel',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
