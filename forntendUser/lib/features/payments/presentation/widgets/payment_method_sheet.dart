import 'package:flutter/material.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';

enum PaymentMethod { applePay, card }

class PaymentMethodSheet extends StatefulWidget {
  final String amountLabel;
  final VoidCallback onApplePay;
  final ValueChanged<AddedCard>? onCardAdded; // يُستدعى بعد حفظ بطاقة جديدة (اختياري)

  const PaymentMethodSheet({
    super.key,
    required this.amountLabel,
    required this.onApplePay,
    this.onCardAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required String amountLabel,
    required VoidCallback onApplePay,
    ValueChanged<AddedCard>? onCardAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PaymentMethodSheet(
        amountLabel: amountLabel,
        onApplePay: onApplePay,
        onCardAdded: onCardAdded,
      ),
    );
  }

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  PaymentMethod _selected = PaymentMethod.applePay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        top: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // العنوان
          const SizedBox(height: 4),
          Text(
            l10n.choosePaymentMethod,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // بطاقة الخيارات
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE6ECF3)),
            ),
            child: Column(
              children: [
                _MethodTile(
                  isSelected: _selected == PaymentMethod.applePay,
                  onTap: () => setState(() => _selected = PaymentMethod.applePay),
                  title: l10n.applePay,
                  trailing: _ApplePayBadge(),
                ),
                const Divider(height: 1, color: Color(0xFFE6ECF3)),
                _MethodTile(
                  isSelected: _selected == PaymentMethod.card,
                  onTap: () => setState(() => _selected = PaymentMethod.card),
                  title: 'Pay via MyFatoorah',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE6ECF3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.credit_card, size: 18, color: Color(0xFF111827)),
                        SizedBox(width: 4),
                        Text(
                          'Pay',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // زر الدفع
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_selected == PaymentMethod.applePay) {
                  widget.onApplePay();
                } else {
                  // Pay via MyFatoorah (card)
                  widget.onCardAdded?.call(AddedCard(
                    last4: '0000',
                    holder: 'MyFatoorah',
                    exp: '00/00',
                  ));
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              child: Text('${l10n.pay} ${widget.amountLabel}'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ======= Tiles =======

class _MethodTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  final Widget? trailing;

  const _MethodTile({
    required this.isSelected,
    required this.onTap,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            _RadioDot(selected: isSelected),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _AddNewCardTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddNewCardTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            const _RadioDot(selected: false, dimmed: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.addNewCard,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF1F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E5EC)),
              ),
              child: const Icon(Icons.add, color: Color(0xFF111827)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  final bool dimmed;
  const _RadioDot({required this.selected, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF111827)
            : (dimmed ? const Color(0xFFE7EBF2) : Colors.white),
        border: Border.all(
          color: selected ? const Color(0xFF111827) : const Color(0xFFD7DCE4),
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _ApplePayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 10, end: 12, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6ECF3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.apple, size: 18, color: Color(0xFF111827)),
          SizedBox(width: 4),
          Text(
            'Pay',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

// ======= Add Card Sheet (بسيط وجميل) =======

class AddedCard {
  final String last4;
  final String holder;
  final String exp;
  AddedCard({required this.last4, required this.holder, required this.exp});
}

class AddCardSheet extends StatefulWidget {
  const AddCardSheet({super.key});

  static Future<AddedCard?> show(BuildContext context) {
    return showModalBottomSheet<AddedCard>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddCardSheet(),
    );
  }

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _name = TextEditingController();
  final _exp = TextEditingController();
  final _cvv = TextEditingController();

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _exp.dispose();
    _cvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    InputDecoration deco(String label, {Widget? prefixIcon}) => InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon,
          filled: true,
          fillColor: const Color(0xFFF7F8FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6ECF3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6ECF3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF111827), width: 1.6),
          ),
        );

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        top: 4,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.addNewCard,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _number,
              keyboardType: TextInputType.number,
              decoration: deco(l10n.cardNumber, prefixIcon: const Icon(Icons.credit_card)),
              validator: (v) => (v == null || v.replaceAll(' ', '').length < 12)
                  ? l10n.invalidCardNumber
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: deco(l10n.cardholderName, prefixIcon: const Icon(Icons.person_outline)),
              validator: (v) => (v == null || v.trim().length < 3) ? l10n.enterName : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _exp,
                    keyboardType: TextInputType.datetime,
                    decoration: deco('MM/YY', prefixIcon: const Icon(Icons.date_range)),
                    validator: (v) => (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v))
                        ? l10n.invalidFormat
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _cvv,
                    keyboardType: TextInputType.number,
                    decoration: deco('CVV', prefixIcon: const Icon(Icons.lock_outline)),
                    validator: (v) =>
                        (v == null || v.length < 3) ? l10n.invalidCvv : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    final last4 = _number.text.replaceAll(' ', '');
                    Navigator.pop(
                      context,
                      AddedCard(
                        last4: last4.substring(last4.length - 4),
                        holder: _name.text.trim(),
                        exp: _exp.text.trim(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(l10n.saveCard),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
