import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';

/// Every payout the store asked for or received, and where each one stands.
class SettlementsPage extends StatefulWidget {
  const SettlementsPage({super.key});

  @override
  State<SettlementsPage> createState() => _SettlementsPageState();
}

class _SettlementsPageState extends State<SettlementsPage> {
  final List<Map<String, dynamic>> _items = [];
  int _page = 0;
  int _pages = 1;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _reload() async {
    setState(() {
      _items.clear();
      _page = 0;
      _pages = 1;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _page >= _pages) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await context.read<SessionService>().api.mySettlements(
        page: _page + 1,
      );
      final list = (data['settlements'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e));
      if (!mounted) return;
      setState(() {
        _items.addAll(list);
        _page += 1;
        _pages = toInt(data['totalPages']).clamp(1, 1 << 30);
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageService>().isArabic ? 'ar' : 'en';

    Widget body;
    if (_error != null && _items.isEmpty) {
      body = ErrorState(
        message: errorMessage(context, _error!),
        onRetry: _reload,
      );
    } else if (_items.isEmpty && _loading) {
      body = const LoadingState();
    } else if (_items.isEmpty) {
      body = EmptyState(
        icon: Icons.account_balance_outlined,
        title: context.tr('noSettlements'),
        subtitle: context.tr('noSettlementsDetail'),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _reload,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: _items.length + (_page < _pages ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            if (i == _items.length) {
              return Center(
                child: TextButton(
                  onPressed: _loading ? null : _loadMore,
                  child: Text(context.tr('loadMore')),
                ),
              );
            }
            return _SettlementCard(item: _items[i], locale: locale);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(context.tr('settlementHistory')),
      ),
      body: body,
    );
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({required this.item, required this.locale});

  final Map<String, dynamic> item;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final status = item['status']?.toString();
    final (label, tone) = switch (status) {
      'completed' => ('settlementTransferred', StatusTone.success),
      'failed' => ('settlementNotSent', StatusTone.danger),
      _ => ('settlementProcessing', StatusTone.warning),
    };
    final date = parseDate(
      status == 'completed' ? item['settlementDate'] : item['requestedAt'],
    );
    final fees = toDouble(item['bankShare']) + toDouble(item['platformShare']);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${item['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.heading,
                      ),
                    ),
                    Text(
                      shortDate(date, locale),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(label: context.tr(label), tone: tone),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(
            label: context.tr('orders'),
            value: '${toInt(item['ordersCount'])}',
          ),
          InfoRow(
            label: context.tr('collected'),
            value: money(toDouble(item['totalCollected']), 'JOD', fixed: true),
          ),
          InfoRow(
            label: context.tr('fees'),
            value: money(fees, 'JOD', fixed: true),
          ),
          InfoRow(
            label: context.tr('yourNet'),
            value: money(toDouble(item['netAmount']), 'JOD', fixed: true),
            valueColor: AppColors.primary,
            bold: true,
          ),
          if (status == 'failed' && '${item['notes'] ?? ''}'.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${item['notes']}',
              style: const TextStyle(fontSize: 12.5, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}
