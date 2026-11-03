import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/api/api_client.dart';
import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';

enum _Stage { otp, waiting, success, failed }

/// Follows one payment request from the customer's code to their approval,
/// polling every three seconds as the portal does.
class PosSessionPage extends StatefulWidget {
  const PosSessionPage({
    super.key,
    required this.sessionId,
    required this.qrUrl,
    required this.customerPhone,
    required this.total,
  });

  final String sessionId;
  final String? qrUrl;

  /// Null for a QR sale, where there is no code to enter.
  final String? customerPhone;
  final double total;

  @override
  State<PosSessionPage> createState() => _PosSessionPageState();
}

class _PosSessionPageState extends State<PosSessionPage> {
  late _Stage _stage = widget.customerPhone == null
      ? _Stage.waiting
      : _Stage.otp;
  final _otp = TextEditingController();
  bool _verifying = false;
  String? _otpError;
  bool _expired = false;
  Timer? _poll;

  bool get _isQr => widget.customerPhone == null;

  @override
  void initState() {
    super.initState();
    if (_stage == _Stage.waiting) _startPolling();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _otp.dispose();
    super.dispose();
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    try {
      final res = await context.read<SessionService>().api.getSession(
        widget.sessionId,
      );
      final status = res['status']?.toString().toUpperCase() ?? '';
      if (!mounted) return;
      if (status == 'APPROVED' || status == 'COMPLETED') {
        _poll?.cancel();
        HapticFeedback.heavyImpact();
        setState(() => _stage = _Stage.success);
      } else if (status == 'REJECTED' ||
          status == 'CANCELLED' ||
          status == 'EXPIRED') {
        _poll?.cancel();
        setState(() {
          _stage = _Stage.failed;
          _expired = status == 'EXPIRED';
        });
      }
    } on ApiException catch (e) {
      // The backend answers an expired session with a 400.
      if (e.statusCode == 400 && mounted) {
        _poll?.cancel();
        setState(() {
          _stage = _Stage.failed;
          _expired = true;
        });
      }
    } catch (_) {
      // A dropped poll is retried on the next tick.
    }
  }

  Future<void> _verify() async {
    if (_otp.text.length != 6) return;
    setState(() {
      _verifying = true;
      _otpError = null;
    });
    try {
      final message = await context.read<SessionService>().api.verifySessionOtp(
        widget.sessionId,
        _otp.text,
      );
      if (!mounted) return;
      if (message != null && message.isNotEmpty) showToast(context, message);
      setState(() => _stage = _Stage.waiting);
      _startPolling();
      _checkStatus();
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              _otpError = errorMessage(context, e, fallbackKey: 'invalidCode'),
        );
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.tr('currency');
    final done = _stage == _Stage.success;

    return PopScope(
      canPop: !done,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && done) Navigator.of(context).pop(true);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: done
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: context.tr('cancelSession'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: KeyedSubtree(
              key: ValueKey(_stage),
              child: switch (_stage) {
                _Stage.otp => _buildOtp(context),
                _Stage.waiting => _buildWaiting(context, currency),
                _Stage.success => _buildResult(
                  context,
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  title: context.tr('paymentSuccess'),
                  subtitle: context.tr('handOverItems'),
                  action: PrimaryButton(
                    label: context.tr('backToPOS'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
                _Stage.failed => _buildResult(
                  context,
                  icon: _expired
                      ? Icons.timer_off_rounded
                      : Icons.close_rounded,
                  color: AppColors.error,
                  title: _expired
                      ? context.tr('canceled')
                      : context.tr('paymentRejected'),
                  subtitle: context.tr('paymentRejectedDetail'),
                  action: PrimaryButton(
                    label: context.tr('backToPOS'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtp(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        _StageIcon(icon: Icons.sms_outlined, color: AppColors.accent),
        const SizedBox(height: 24),
        Text(
          context.tr('enterOtp'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${context.tr('otpSentTo')}\n${widget.customerPhone}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            controller: _otp,
            autofocus: true,
            maxLength: 6,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              setState(() => _otpError = null);
              if (v.length == 6) _verify();
            },
            style: const TextStyle(
              fontSize: 34,
              letterSpacing: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              hintStyle: const TextStyle(
                fontSize: 34,
                letterSpacing: 14,
                color: AppColors.border,
              ),
              errorText: _otpError,
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: context.tr('verifyCode'),
          isLoading: _verifying,
          onPressed: _otp.text.length == 6 ? _verify : null,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          child: Text(context.tr('cancel')),
        ),
      ],
    );
  }

  Widget _buildWaiting(BuildContext context, String currency) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        if (_isQr && widget.qrUrl != null) ...[
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.hairline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: QrImageView(
                data: widget.qrUrl!,
                size: 220,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primaryDark,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('showQrToCustomer'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ] else
          const _PulsingIcon(),
        const SizedBox(height: 28),
        Text(
          context.tr('sessionActive'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('waitingCustomerApproval'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                context.tr('total'),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                money(widget.total, currency, fixed: true),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.heading,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const LinearProgressIndicator(
          minHeight: 3,
          color: AppColors.primaryLight,
          backgroundColor: AppColors.hairline,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          child: Text(context.tr('cancelSession')),
        ),
      ],
    );
  }

  Widget _buildResult(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget action,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 56),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(flex: 2),
          action,
        ],
      ),
    );
  }
}

class _StageIcon extends StatelessWidget {
  const _StageIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 40),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon();

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green50,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(
                    alpha: 0.15 + 0.2 * t,
                  ),
                  blurRadius: 20 + 20 * t,
                  spreadRadius: 4 * t,
                ),
              ],
            ),
            child: child,
          );
        },
        child: const Icon(
          Icons.smartphone_rounded,
          color: AppColors.accent,
          size: 50,
        ),
      ),
    );
  }
}
