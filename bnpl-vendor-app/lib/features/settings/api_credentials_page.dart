import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui.dart';

/// The store's integration keys, as shown on the portal's settings page.
class ApiCredentialsPage extends StatefulWidget {
  const ApiCredentialsPage({super.key});

  @override
  State<ApiCredentialsPage> createState() => _ApiCredentialsPageState();
}

class _ApiCredentialsPageState extends State<ApiCredentialsPage> {
  Map<String, dynamic>? _store;
  Object? _error;
  bool _showSecret = false;
  bool _regenerating = false;

  /// For a leaked secret: the old keys stop working at once.
  Future<void> _regenerate() async {
    final confirmed = await confirmDialog(
      context,
      message: context.trNow('regenerateKeysConfirm'),
      confirmLabel: context.trNow('regenerateKeys'),
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final session = context.read<SessionService>();
    setState(() => _regenerating = true);
    try {
      final keys = await session.api.regenerateApiKeys(session.storeId);
      if (!mounted) return;
      setState(() {
        _store = {...?_store, ...keys};
        _showSecret = true;
      });
      showToast(context, context.trNow('keysRegenerated'));
    } catch (e) {
      if (mounted) showToast(context, errorMessage(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _regenerating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = context.read<SessionService>();
    setState(() => _error = null);
    try {
      final store = await session.api.store(session.storeId);
      if (mounted) setState(() => _store = store);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    showToast(context, context.trNow('copied'));
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = _store?['apiKey']?.toString();
    final secret = _store?['apiSecret']?.toString();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: Text(context.tr('apiCredentials')),
      ),
      body: _error != null
          ? ErrorState(message: errorMessage(context, _error!), onRetry: _load)
          : _store == null
          ? const LoadingState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _KeyCard(
                  label: context.tr('storeId'),
                  value: '${_store?['id'] ?? ''}',
                  onCopy: _copy,
                ),
                const SizedBox(height: 12),
                _KeyCard(
                  label: context.tr('apiKeyLabel'),
                  value: apiKey,
                  placeholder: context.tr('pendingApproval'),
                  onCopy: _copy,
                ),
                const SizedBox(height: 12),
                _KeyCard(
                  label: context.tr('apiSecretLabel'),
                  value: secret,
                  display: secret == null
                      ? null
                      : (_showSecret ? secret : '•' * 28),
                  placeholder: context.tr('pendingApproval'),
                  onCopy: _copy,
                  extra: secret == null
                      ? null
                      : IconButton(
                          onPressed: () =>
                              setState(() => _showSecret = !_showSecret),
                          icon: Icon(
                            _showSecret
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.tr('neverShareSecret'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                if (secret != null && _store?['status'] == 'approved') ...[
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _regenerating ? null : _regenerate,
                    icon: _regenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.autorenew_rounded),
                    label: Text(context.tr('regenerateKeys')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _KeyCard extends StatelessWidget {
  const _KeyCard({
    required this.label,
    required this.value,
    required this.onCopy,
    this.display,
    this.placeholder,
    this.extra,
  });

  final String label;
  final String? value;
  final String? display;
  final String? placeholder;
  final ValueChanged<String> onCopy;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? (display ?? value!) : (placeholder ?? ''),
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: hasValue ? AppColors.heading : AppColors.textHint,
                  ),
                ),
              ),
              ?extra,
              if (hasValue)
                IconButton(
                  onPressed: () => onCopy(value!),
                  tooltip: context.tr('copy'),
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
