import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/ui.dart';
import 'pos_cart.dart';
import 'pos_session_page.dart';

enum PaymentMethod { phone, qr }

/// The portal's checkout sidebar as its own screen: review the cart, apply a
/// discount, find the customer and send the payment request.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.cart});

  final PosCart cart;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _phone = TextEditingController();
  late final _discount = TextEditingController(
    text: widget.cart.discount > 0 ? number(widget.cart.discount) : '',
  );
  PaymentMethod _method = PaymentMethod.phone;
  Map<String, dynamic>? _foundUser;
  bool _searching = false;
  bool _creating = false;
  Timer? _lookupDebounce;
  int _lookupId = 0;

  PosCart get cart => widget.cart;

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _phone.dispose();
    _discount.dispose();
    super.dispose();
  }

  /// Looks the number up as the merchant types, like the portal, so they know
  /// before sending whether the customer will get the request.
  void _onPhoneChanged(String value) {
    _lookupDebounce?.cancel();
    final phone = value.trim();
    if (phone.length < 7) {
      setState(() {
        _foundUser = null;
        _searching = false;
      });
      return;
    }
    final id = ++_lookupId;
    setState(() => _searching = true);
    _lookupDebounce = Timer(const Duration(milliseconds: 600), () async {
      Map<String, dynamic>? user;
      try {
        user = await context.read<SessionService>().api.findUserByPhone(
          normalizePhone(phone),
        );
      } catch (_) {
        user = null;
      }
      if (!mounted || id != _lookupId) return;
      setState(() {
        _foundUser = user;
        _searching = false;
      });
    });
  }

  void _onDiscountChanged(String value, [DiscountType? type]) {
    cart.setDiscount(
      double.tryParse(value.replaceAll(',', '.')) ?? 0,
      type ?? cart.discountType,
    );
  }

  bool get _canSubmit =>
      !_creating &&
      cart.total > 0 &&
      (_method == PaymentMethod.qr || _phone.text.trim().isNotEmpty);

  Future<void> _createSession() async {
    final session = context.read<SessionService>();
    final arabic = context.read<LanguageService>().isArabic;
    final phone = _method == PaymentMethod.phone
        ? normalizePhone(_phone.text)
        : null;

    setState(() => _creating = true);
    try {
      final created = await session.api.createSession(
        cart.toSessionPayload(
          storeId: session.storeId,
          arabic: arabic,
          customerPhone: phone,
        ),
      );
      final sessionId = created['session_id']?.toString();
      if (sessionId == null) throw StateError('missing session id');
      if (!mounted) return;

      final completed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PosSessionPage(
            sessionId: sessionId,
            qrUrl: created['web_redirect_url']?.toString(),
            customerPhone: _method == PaymentMethod.phone
                ? _phone.text.trim()
                : null,
            total: cart.total,
          ),
        ),
      );
      if (completed == true && mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          errorMessage(context, e, fallbackKey: 'sessionFailed'),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arabic = context.isArabic;
    final currency = context.tr('currency');

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        if (cart.isEmpty) {
          // Last item removed: nothing left to check out.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop(false);
            }
          });
        }

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            backgroundColor: AppColors.canvas,
            title: Text(context.tr('cartTitle')),
            actions: [
              TextButton(
                onPressed: () {
                  cart.clear();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(context.tr('clearCart')),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              SectionCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < cart.lines.length; i++) ...[
                      if (i > 0) const Divider(indent: 16, endIndent: 16),
                      _LineRow(
                        line: cart.lines[i],
                        cart: cart,
                        arabic: arabic,
                        currency: currency,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  children: [
                    InfoRow(
                      label: context.tr('subtotal'),
                      value: money(cart.subtotal, currency),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr('manualDiscount'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        _DiscountTypeToggle(
                          value: cart.discountType,
                          currency: currency,
                          onChanged: (type) =>
                              _onDiscountChanged(_discount.text, type),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 84,
                          child: TextField(
                            controller: _discount,
                            onChanged: _onDiscountChanged,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (cart.discountAmount > 0)
                      InfoRow(
                        label: '',
                        value:
                            '- ${money(cart.discountAmount, currency, fixed: true)}',
                        valueColor: AppColors.error,
                      ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                    InfoRow(
                      label: context.tr('total'),
                      value: money(cart.total, currency, fixed: true),
                      valueColor: AppColors.accent,
                      bold: true,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${context.tr('monthlyInstallment')} · ${cart.installments} ${context.tr('installments')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            money(
                              cart.installmentAmount,
                              currency,
                              fixed: true,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.heading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionTitle(context.tr('paymentMethod')),
              const SizedBox(height: 12),
              SegmentedButton<PaymentMethod>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: PaymentMethod.phone,
                    icon: const Icon(Icons.smartphone_rounded),
                    label: Text(context.tr('sendToPhone')),
                  ),
                  ButtonSegment(
                    value: PaymentMethod.qr,
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: Text(context.tr('scanQR')),
                  ),
                ],
                selected: {_method},
                onSelectionChanged: (s) => setState(() => _method = s.first),
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.white,
                  selectedBackgroundColor: AppColors.primary,
                  selectedForegroundColor: Colors.white,
                  foregroundColor: AppColors.textMuted,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (_method == PaymentMethod.phone) ...[
                const SizedBox(height: 16),
                LabeledField(
                  label: context.tr('customerPhone'),
                  controller: _phone,
                  hint: '07xxxxxxxx',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  onChanged: _onPhoneChanged,
                  suffix: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                        )
                      : null,
                ),
                if (_foundUser != null)
                  _FoundUserCard(user: _foundUser!)
                else if (_phone.text.trim().length >= 9 && !_searching)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('phoneNotRegistered'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: PrimaryButton(
              label: context.tr('createSession'),
              icon: Icons.send_rounded,
              isLoading: _creating,
              onPressed: _canSubmit ? _createSession : null,
            ),
          ),
        );
      },
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.line,
    required this.cart,
    required this.arabic,
    required this.currency,
  });

  final CartLine line;
  final PosCart cart;
  final bool arabic;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: NetImage(url: line.product.imageUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.displayName(arabic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${money(line.product.price, currency)} × ${line.quantity}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _StepButton(
                  icon: line.quantity == 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove_rounded,
                  color: line.quantity == 1
                      ? AppColors.error
                      : AppColors.heading,
                  onTap: () => cart.changeQuantity(line.product, -1),
                ),
                SizedBox(
                  width: 26,
                  child: Text(
                    '${line.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                _StepButton(
                  icon: Icons.add_rounded,
                  onTap: () => cart.changeQuantity(line.product, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.heading,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _DiscountTypeToggle extends StatelessWidget {
  const _DiscountTypeToggle({
    required this.value,
    required this.currency,
    required this.onChanged,
  });

  final DiscountType value;
  final String currency;
  final ValueChanged<DiscountType> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(DiscountType type, String label) {
      final selected = value == type;
      return GestureDetector(
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          option(DiscountType.fixed, currency),
          option(DiscountType.percent, '%'),
        ],
      ),
    );
  }
}

class _FoundUserCard extends StatelessWidget {
  const _FoundUserCard({required this.user});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    final verified = user['isVerified'] == true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green100),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']?.toString() ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
                ),
                Text(
                  context.tr(verified ? 'verifiedAccount' : 'activeAccount'),
                  style: const TextStyle(fontSize: 12, color: AppColors.accent),
                ),
              ],
            ),
          ),
          if (verified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                context.tr('ready'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
