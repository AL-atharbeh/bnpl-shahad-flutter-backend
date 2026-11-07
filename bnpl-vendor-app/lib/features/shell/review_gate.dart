import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui.dart';
import '../auth/store_setup_page.dart';
import '../settings/application_page.dart';
import 'merchant_shell.dart';

enum _Review { checking, live, pending, rejected }

/// A new store waits for an admin before it can sell. Until then the merchant
/// sees where their request stands instead of the dashboard, and the screen
/// opens by itself once the store is approved.
class ReviewGate extends StatefulWidget {
  const ReviewGate({super.key});

  @override
  State<ReviewGate> createState() => _ReviewGateState();
}

class _ReviewGateState extends State<ReviewGate> {
  _Review _review = _Review.checking;
  bool _refreshing = false;
  bool _submitted = false;
  int _missing = 0;
  String? _reviewNote;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    _Review next;
    try {
      final account = await context.read<SessionService>().api.me();
      final store = account['store'] is Map
          ? account['store'] as Map
          : const {};
      final application = account['application'] is Map
          ? account['application'] as Map
          : const {};
      _submitted = application['submittedAt'] != null;
      _missing = (application['missing'] as List? ?? const []).length;
      _reviewNote = application['reviewNote']?.toString();
      if (store['status'] == 'approved' && store['isActive'] == true) {
        next = _Review.live;
      } else if (store['status'] == 'rejected') {
        next = _Review.rejected;
      } else {
        next = _Review.pending;
      }
    } on ApiException catch (e) {
      // A 401 already signs the merchant out. Otherwise the server still
      // refuses an unapproved store's sales, so a failed check should not
      // lock an approved merchant out of their dashboard.
      if (e.statusCode == 401) return;
      next = _Review.live;
    }
    if (!mounted) return;
    setState(() => _review = next);

    _poll?.cancel();
    if (next == _Review.pending) {
      _poll = Timer.periodic(const Duration(seconds: 30), (_) => _check());
    }
  }

  Future<void> _openApplication() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ApplicationPage()));
    if (mounted) _check();
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await _check();
    if (mounted) setState(() => _refreshing = false);
  }

  Future<void> _logout() async {
    final confirmed = await confirmDialog(
      context,
      message: context.trNow('logoutConfirm'),
      confirmLabel: context.trNow('logout'),
      destructive: true,
    );
    if (confirmed && mounted) await context.read<SessionService>().logout();
  }

  @override
  Widget build(BuildContext context) {
    switch (_review) {
      case _Review.checking:
        return const Scaffold(
          backgroundColor: Colors.white,
          body: LoadingState(),
        );
      case _Review.live:
        return const MerchantShell();
      case _Review.pending:
      case _Review.rejected:
        return _buildReview(context, pending: _review == _Review.pending);
    }
  }

  Widget _buildReview(BuildContext context, {required bool pending}) {
    final session = context.watch<SessionService>();
    final language = context.watch<LanguageService>();
    final color = pending ? AppColors.warning : AppColors.error;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: language.toggle,
                  icon: const Icon(Icons.translate_rounded, size: 18),
                  label: Text(language.tr('otherLanguage')),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        pending
                            ? Icons.hourglass_top_rounded
                            : Icons.block_rounded,
                        color: color,
                        size: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    context.tr(
                      !pending
                          ? 'reviewRejectedTitle'
                          : _submitted
                          ? 'reviewSubmittedTitle'
                          : 'reviewStartTitle',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr(
                      !pending
                          ? 'reviewRejectedBody'
                          : _submitted
                          ? 'reviewPendingBody'
                          : 'reviewStartBody',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (!pending && (_reviewNote ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${context.tr('rejectionReason')}: $_reviewNote',
                        style: const TextStyle(
                          color: AppColors.error,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SectionCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            session.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.heading,
                            ),
                          ),
                        ),
                        StatusChip(
                          label: context.tr(pending ? 'pending' : 'rejected'),
                          tone: pending
                              ? StatusTone.warning
                              : StatusTone.danger,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_submitted || !pending)
                    PrimaryButton(
                      label: !pending
                          ? context.tr('fixAndResubmit')
                          : _missing > 0
                          ? '${context.tr('completeApplication')} · $_missing ${context.tr('itemsLeft')}'
                          : context.tr('completeApplication'),
                      icon: Icons.assignment_outlined,
                      onPressed: _openApplication,
                    )
                  else
                    TextButton(
                      onPressed: _openApplication,
                      child: Text(context.tr('viewApplication')),
                    ),
                  if (pending)
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StoreSetupPage(),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                      ),
                      child: Text(context.tr('storeSetupTitle')),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  PrimaryButton(
                    label: context.tr('checkAgain'),
                    icon: Icons.refresh_rounded,
                    isLoading: _refreshing,
                    onPressed: _refresh,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _logout,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                    ),
                    child: Text(context.tr('logout')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
