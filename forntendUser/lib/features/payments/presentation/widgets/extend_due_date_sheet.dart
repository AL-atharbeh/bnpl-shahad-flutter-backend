import 'package:flutter/material.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import 'payment_method_sheet.dart';

class ExtendOption {
  final int? id;               // معرف الخيار من السيرفر
  final int days;
  final double? fee;           // المبلغ كرقم
  final String feeLabel;         // مثال: "JOD 1.950"
  final String targetDateLabel;  // مثال: "مُمدّد إلى سبتمبر 2025"
  final bool popular;            // تمييز الخيار
  const ExtendOption({
    this.id,
    required this.days,
    this.fee,
    required this.feeLabel,
    required this.targetDateLabel,
    this.popular = false,
  });
}

class ExtendDueDateSheet extends StatefulWidget {
  final String merchantName;
  final String originalAmountLabel; // المبلغ الأصلي المعروض تحت الاسم
  final String originalDueLabel;    // مثلاً "أغسطس 2025"
  final List<ExtendOption> options;
  final ValueChanged<ExtendOption> onConfirm;

  const ExtendDueDateSheet({
    super.key,
    required this.merchantName,
    required this.originalAmountLabel,
    required this.originalDueLabel,
    required this.options,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String merchantName,
    required String originalAmountLabel,
    required String originalDueLabel,
    required List<ExtendOption> options,
    required ValueChanged<ExtendOption> onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ExtendDueDateSheet(
        merchantName: merchantName,
        originalAmountLabel: originalAmountLabel,
        originalDueLabel: originalDueLabel,
        options: options,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<ExtendDueDateSheet> createState() => _ExtendDueDateSheetState();
}

class _ExtendDueDateSheetState extends State<ExtendDueDateSheet> {
  int _selectedIndex = 0; // Default to first option

  @override
  void initState() {
    super.initState();
    // Try to select the second option (14 days) by default if it exists
    if (widget.options.length > 1) {
      _selectedIndex = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    if (widget.options.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('لا توجد خيارات تمديد')),
      );
    }

    // Safety check for index
    final index = _selectedIndex >= widget.options.length ? 0 : _selectedIndex;
    final selected = widget.options[index];

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط علوي بسيط (أيقونة المساعدة + عنوان المتجر + سهم)
          Row(
            children: [
              _CircleIcon(
                icon: Icons.help_outline,
                bg: const Color(0xFFF3F4F6),
                fg: const Color(0xFF111827),
              ),
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.merchantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${widget.originalAmountLabel} · ${l10n.due} ${widget.originalDueLabel}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const Spacer(),
              _CircleIcon(
                icon: Icons.arrow_forward_ios_rounded,
                bg: const Color(0xFFF3F4F6),
                fg: const Color(0xFF111827),
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // أيقونة التقويم داخل دائرة بنفسجية
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: Color(0xFFF2ECFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: Color(0xFF7C3AED), size: 38),
          ),

          const SizedBox(height: 18),

          // عنوان ووصف
          Text(
            l10n.getExtraDaysToPay,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.extendDueDateDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          // بطاقات الخيارات
          Column(
            children: List.generate(widget.options.length, (i) {
              final o = widget.options[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OptionCard(
                  option: o,
                  selected: i == _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = i),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          // زر التأكيد
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // إغلاق شاشة التمديد أولاً
                Navigator.pop(context);
                
                // الانتقال لتأكيد التمديد وبدء عملية الدفع
                widget.onConfirm(selected);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              child: Text('${l10n.pay} ${selected.feeLabel}'),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ====== UI Parts ======

class _OptionCard extends StatelessWidget {
  final ExtendOption option;
  final bool selected;
  final VoidCallback onTap;
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final border = selected ? const Color(0xFF0F172A) : const Color(0xFFE5E7EB);
    final badgeColor = const Color(0xFF7C3AED);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: border,
            width: selected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // المبلغ يسار
            Expanded(
              child: Text(
                option.feeLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            // الأيام + التاريخ
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+${option.days} ${l10n.days}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (option.popular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2ECFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 14, color: badgeColor),
                            const SizedBox(width: 2),
                            Text(
                              l10n.mostPopular,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  option.targetDateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;
  const _CircleIcon({
    required this.icon,
    required this.bg,
    required this.fg,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: size),
    );
  }
}
