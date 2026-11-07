import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui.dart';

const _icons = <String, IconData>{
  'sale_approved': Icons.shopping_bag_rounded,
  'settlement_completed': Icons.account_balance_wallet_rounded,
  'settlement_failed': Icons.error_outline_rounded,
  'store_approved': Icons.verified_rounded,
  'store_rejected': Icons.assignment_late_outlined,
  'store_suspended': Icons.block_rounded,
  'api_keys_regenerated': Icons.key_rounded,
};

Color _toneOf(String type) => switch (type) {
  'settlement_failed' ||
  'store_rejected' ||
  'store_suspended' => AppColors.error,
  'api_keys_regenerated' => AppColors.warning,
  _ => AppColors.primary,
};

/// The merchant's notices: review decisions, new sales and payouts.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>>? _items;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<SessionService>().api;
    setState(() => _error = null);
    try {
      final data = await api.notifications();
      final items = (data['items'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (!mounted) return;
      setState(() => _items = items);
      // Opening the list is reading it.
      if (items.any((n) => n['readAt'] == null)) {
        unawaited(api.markNotificationsRead().catchError((_) {}));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabic = context.watch<LanguageService>().isArabic;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(context.tr('notifications')),
      ),
      body: _error != null
          ? ErrorState(message: errorMessage(context, _error!), onRetry: _load)
          : _items == null
          ? const LoadingState()
          : _items!.isEmpty
          ? EmptyState(
              icon: Icons.notifications_none_rounded,
              title: context.tr('noNotifications'),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: _items!.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final n = _items![i];
                  final type = n['type']?.toString() ?? '';
                  final tone = _toneOf(type);
                  final unread = n['readAt'] == null;
                  final created = DateTime.tryParse('${n['createdAt']}');
                  return SectionCard(
                    color: unread ? AppColors.green50 : Colors.white,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: tone.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _icons[type] ?? Icons.notifications_rounded,
                            color: tone,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${arabic ? n['title'] : n['titleEn']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.heading,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${arabic ? n['body'] : n['bodyEn']}',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  height: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (created != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat.yMMMd(
                                    arabic ? 'ar' : 'en',
                                  ).add_jm().format(created.toLocal()),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

/// A bell with the unread count that opens the notifications. It checks again
/// every minute and when the merchant comes back from the list.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unread = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final data = await context.read<SessionService>().api.notifications();
      final unread = (data['unread'] as num?)?.toInt() ?? 0;
      if (mounted) setState(() => _unread = unread);
    } catch (_) {
      // The next tick tries again.
    }
  }

  Future<void> _open() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotificationsPage()));
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _open,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Badge(
            isLabelVisible: _unread > 0,
            label: Text(_unread > 9 ? '9+' : '$_unread'),
            backgroundColor: AppColors.warning,
            offset: const Offset(-6, 6),
            child: const Center(
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.heading,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
