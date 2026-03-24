import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../models/in_app_notification.dart';
import '../../../../services/in_app_notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

enum NotificationType { payment, offer, security, general }

class _NotificationsPageState extends State<NotificationsPage> {
  // تفضيلات
  bool _pushNotifications = true;

  // فلتر أعلى القائمة
  String _activeFilter = 'all'; // all, unread, payment, offer, security

  // بيانات من API
  List<InAppNotification> _all = [];
  bool _isLoading = true;
  final InAppNotificationService _notificationService = InAppNotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationService.getInAppNotifications();
      setState(() {
        _all = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  List<InAppNotification> get _filtered {
    final list = List<InAppNotification>.from(_all);
    list.sort((a, b) => b.time.compareTo(a.time)); // الأحدث أولاً
    switch (_activeFilter) {
      case 'unread':
        return list.where((n) => !n.isRead).toList();
      case 'payment':
        return list.where((n) => n.type == 'payment').toList();
      case 'offer':
        return list.where((n) => n.type == 'offer').toList();
      case 'security':
        return list.where((n) => n.type == 'security').toList();
      default:
        return list;
    }
  }

  NotificationType _getNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return NotificationType.payment;
      case 'offer':
        return NotificationType.offer;
      case 'security':
        return NotificationType.security;
      default:
        return NotificationType.general;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = context.watch<LanguageService>();
    final isRTL = lang.isArabic;

    final data = _filtered;
    final grouped = _groupByDate(data, isRTL);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notifications,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.markAllAsRead,
            icon: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF111827)),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _FilterChipsBar(
            active: _activeFilter,
            onChanged: (f) => setState(() => _activeFilter = f),
          ),
          const SizedBox(height: 8),
          _SettingsSummaryCard(
            enabled: _pushNotifications,
            onToggle: (v) => setState(() => _pushNotifications = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: grouped.length,
                          itemBuilder: (_, sectionIndex) {
                            final section = grouped[sectionIndex];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionHeader(title: section.label),
                                const SizedBox(height: 8),
                                ...section.items.map(
                                  (n) => _DismissibleNotificationCard(
                                    key: ValueKey(n.id),
                                    notification: n,
                                    onReadToggle: () => _toggleRead(n),
                                    onDelete: () => _deleteNotification(n),
                                    onMuteType: () => _blockNotificationType(_getNotificationType(n.type)),
                                    onTap: () => _handleNotificationTap(n),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ======== Actions ========

  Future<void> _toggleRead(InAppNotification notification) async {
    if (!notification.isDisplayed) {
      await _notificationService.markAsDisplayed(notification.id);
    }
    // Mark as read in main notification
    // TODO: Add API call to mark main notification as read
    setState(() {
      // Update local state
    });
  }

  void _markAllAsRead() {
    // TODO: Implement mark all as read API call
    _toast(AppLocalizations.of(context)!.allNotificationsMarkedAsRead);
  }

  Future<void> _deleteNotification(InAppNotification notification) async {
    final success = await _notificationService.deleteNotification(notification.id);
    if (success) {
      setState(() {
        _all.removeWhere((e) => e.id == notification.id);
      });
      _toast(AppLocalizations.of(context)!.notificationDeleted, danger: false);
    } else {
      _toast('فشل حذف الإشعار', danger: true);
    }
  }

  void _blockNotificationType(NotificationType type) {
    // هنا تضع منطق إيقاف النوع في إعداداتك/خدمتك
    _toast(AppLocalizations.of(context)!.notificationTypeMuted, danger: false);
  }

  Future<void> _handleNotificationTap(InAppNotification notification) async {
    // Mark as displayed and clicked
    if (!notification.isDisplayed) {
      await _notificationService.markAsDisplayed(notification.id);
    }
    if (!notification.isClicked) {
      await _notificationService.markAsClicked(notification.id);
    }
    
    // Navigate to action URL if available
    if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      // TODO: Navigate to action URL
      print('Navigate to: ${notification.actionUrl}');
    }
    
    // Reload notifications to update state
    await _loadNotifications();
  }

  // ======== Helpers ========

  void _toast(String msg, {bool danger = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: danger ? Colors.red : const Color(0xFF111827),
    ));
  }


  String _sectionLabel(DateTime t, bool isRTL) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    final today = d;
    final yesterday = d.subtract(const Duration(days: 1));
    final weekStart = d.subtract(Duration(days: d.weekday % 7)); // بداية الأسبوع (الأحد)

    final dateOnly = DateTime(t.year, t.month, t.day);

    if (dateOnly == today) return l10n.today;
    if (dateOnly == yesterday) return l10n.yesterday;
    if (dateOnly.isAfter(weekStart)) return l10n.thisWeek;
    return l10n.earlier;
  }

  List<_Section> _groupByDate(List<InAppNotification> items, bool isRTL) {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, List<InAppNotification>> buckets = {};
    for (final n in items) {
      final label = _sectionLabel(n.time, isRTL);
      buckets.putIfAbsent(label, () => []).add(n);
    }
    final ordered = <_Section>[];
    // ترتيب الأقسام
    for (final label in [l10n.today, l10n.yesterday, l10n.thisWeek]) {
      if (buckets.containsKey(label)) {
        ordered.add(_Section(label: label, items: buckets[label]!));
        buckets.remove(label);
      }
    }
    // الباقي (أقدم)
    for (final e in buckets.entries) {
      ordered.add(_Section(label: e.key, items: e.value));
    }
    return ordered;
  }
}

// ======== UI Pieces ========

class _SettingsSummaryCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onToggle;
  const _SettingsSummaryCard({required this.enabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Color(0xFF1D4ED8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.notificationsEnabled,
              style: const TextStyle(color: Color(0xFF1D4ED8)),
            ),
          ),
          Switch.adaptive(value: enabled, onChanged: onToggle),
        ],
      ),
    );
  }
}

class _FilterChipsBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChanged;
  const _FilterChipsBar({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    Widget chip(String id, String label, IconData icon) {
      final isActive = active == id;
      return ChoiceChip(
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        avatar: Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFF111827)),
        label: Text(label),
        selected: isActive,
        onSelected: (_) => onChanged(id),
        selectedColor: const Color(0xFF111827),
        labelStyle: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF111827),
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE6ECF3)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('all', l10n.all, Icons.inbox_outlined),
          const SizedBox(width: 8),
          chip('unread', l10n.unread, Icons.markunread),
          const SizedBox(width: 8),
          chip('payment', l10n.payment, Icons.payments),
          const SizedBox(width: 8),
          chip('offer', l10n.offer, Icons.local_offer),
          const SizedBox(width: 8),
          chip('security', l10n.security, Icons.security),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, top: 6, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DismissibleNotificationCard extends StatelessWidget {
  final InAppNotification notification;
  final VoidCallback onReadToggle;
  final VoidCallback onDelete;
  final VoidCallback onMuteType;
  final VoidCallback onTap;

  const _DismissibleNotificationCard({
    super.key,
    required this.notification,
    required this.onReadToggle,
    required this.onDelete,
    required this.onMuteType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notificationType = _getNotificationType(notification.type);
    final meta = _typeMeta(notificationType);
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: _swipeBg(Alignment.centerLeft, Icons.delete_outline, Colors.red),
      onDismissed: (dir) {
        onDelete();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : meta.color.withOpacity(.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: notification.isRead ? const Color(0xFFE6ECF3) : meta.color.withOpacity(.35)),
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: meta.color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(meta.icon, color: meta.color),
              ),
              if (!notification.isRead)
                const Positioned(
                  top: -2,
                  right: -2,
                  child: _UnreadDot(),
                ),
            ],
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message, style: const TextStyle(color: Color(0xFF6B7280))),
              const SizedBox(height: 4),
              Text(
                _format(notification.time, Directionality.of(context) == TextDirection.rtl, l10n),
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
              if (notification.actionButtonText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      notification.actionButtonText!,
                      style: TextStyle(color: meta.color, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'toggle',
                child: Text(notification.isRead ? l10n.markAsUnread : l10n.markAsRead),
              ),
              PopupMenuItem(value: 'mute', child: Text(l10n.muteThisType)),
              PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
            ],
            onSelected: (v) {
              switch (v) {
                case 'toggle':
                  onReadToggle();
                  break;
                case 'mute':
                  onMuteType();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  NotificationType _getNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'payment':
        return NotificationType.payment;
      case 'offer':
        return NotificationType.offer;
      case 'security':
        return NotificationType.security;
      default:
        return NotificationType.general;
    }
  }

  String _format(DateTime t, bool isRTL, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${t.day}/${t.month}/${t.year}';
  }

  Widget _swipeBg(Alignment alignment, IconData icon, Color color) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNewNotifications,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.newNotificationsWillAppearHere,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Section {
  final String label;
  final List<InAppNotification> items;
  _Section({required this.label, required this.items});
}

class _TypeMeta {
  final Color color;
  final IconData icon;
  _TypeMeta({required this.color, required this.icon});
}

_TypeMeta _typeMeta(NotificationType type) {
  switch (type) {
    case NotificationType.payment:
      return _TypeMeta(color: const Color(0xFF10B981), icon: Icons.payments);
    case NotificationType.offer:
      return _TypeMeta(color: const Color(0xFFF59E0B), icon: Icons.local_offer);
    case NotificationType.security:
      return _TypeMeta(color: const Color(0xFFEF4444), icon: Icons.security);
    case NotificationType.general:
      return _TypeMeta(color: const Color(0xFF3B82F6), icon: Icons.notifications);
  }
}
