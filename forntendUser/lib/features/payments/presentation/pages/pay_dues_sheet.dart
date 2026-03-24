import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';

enum DuesFilter { next7, next30, all }

class _DueItem {
  final String merchant;
  final double amount;
  final int dueInDays;
  final String dueChip;
  final String cycleTextKey;
  final int currentInstallment;
  final int totalInstallments;
  final String? dueTextKey;
  final int? dueDays;

  _DueItem({
    required this.merchant,
    required this.amount,
    required this.dueInDays,
    required this.dueChip,
    required this.cycleTextKey,
    required this.currentInstallment,
    required this.totalInstallments,
    this.dueTextKey,
    this.dueDays,
  });
}

class PayDuesSheet extends StatefulWidget {
  const PayDuesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const PayDuesSheet(),
    );
  }

  @override
  State<PayDuesSheet> createState() => _PayDuesSheetState();
}

class _PayDuesSheetState extends State<PayDuesSheet> {
  DuesFilter filter = DuesFilter.next7;

  final _items = <_DueItem>[
    _DueItem(merchant: 'Boutiqaat', amount: 4.060, dueInDays: 1, dueChip: '24\nأغسطس', cycleTextKey: 'installmentOfCycle', currentInstallment: 4, totalInstallments: 4, dueTextKey: 'dueTomorrow'),
    _DueItem(merchant: 'The Athlete\'s Foot KWT', amount: 11.375, dueInDays: 3, dueChip: '26\nأغسطس', cycleTextKey: 'installmentOfCycle', currentInstallment: 4, totalInstallments: 4, dueTextKey: 'dueInDays', dueDays: 3),
    _DueItem(merchant: 'The Athletes Foot', amount: 16.750, dueInDays: 7, dueChip: '30\nأغسطس', cycleTextKey: 'installmentOfCycle', currentInstallment: 4, totalInstallments: 4),
  ];
  final _selected = <int>{0};

  List<int> _filteredIndexes() {
    return List.generate(_items.length, (i) => i).where((i) {
      final d = _items[i].dueInDays;
      switch (filter) {
        case DuesFilter.next7:  return d <= 7;
        case DuesFilter.next30: return d <= 30;
        case DuesFilter.all:    return true;
      }
    }).toList();
  }

  double get _totalSel =>
      _selected.fold<double>(0, (s, i) => s + _items[i].amount);

  String _getCycleText(_DueItem item, AppLocalizations l10n) {
    final cycleText = l10n.installmentOfCycle(item.currentInstallment, item.totalInstallments);
    
    if (item.dueTextKey != null) {
      String dueText;
      switch (item.dueTextKey) {
        case 'dueTomorrow':
          dueText = l10n.dueTomorrow;
          break;
        case 'dueInDays':
          dueText = l10n.dueInDays(item.dueDays!);
          break;
        default:
          dueText = item.dueTextKey!;
      }
      return '$cycleText · $dueText';
    }
    
    return cycleText;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    final indexes = _filteredIndexes();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // عنوان + إغلاق
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  const Spacer(),
                  Text(l10n.payDues, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  ),
                ],
              ),
            ),

            // Segmented
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _Segmented(
                segments: [l10n.next7Days, l10n.next30Days, l10n.all],
                selectedIndex: {DuesFilter.next7:0, DuesFilter.next30:1, DuesFilter.all:2}[filter]!,
                onChanged: (i) => setState(() => filter = [DuesFilter.next7, DuesFilter.next30, DuesFilter.all][i]),
              ),
            ),

            const SizedBox(height: 12),

            // القائمة
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: indexes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (_, idx) {
                  final i = indexes[idx];
                  final it = _items[i];
                  final sel = _selected.contains(i);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () => setState(() => sel ? _selected.remove(i) : _selected.add(i)),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF111827) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                          ),
                          child: sel ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // النصوص
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(it.merchant, textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 6),
                            Text('JD ${it.amount.toStringAsFixed(3)}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            const SizedBox(height: 6),
                            Text(_getCycleText(it, l10n), style: const TextStyle(color: Color(0xFF6B7280), height: 1.2)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),
                      _DateChip(text: it.dueChip),
                    ],
                  );
                },
              ),
            ),

            // زر الإجمالي
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _selected.isEmpty ? null : () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.paymentSuccessful(_totalSel.toStringAsFixed(3))))
                      );
                    },
                    child: Text(l10n.payAmount(_totalSel.toStringAsFixed(3))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _Segmented({required this.segments, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(28)),
      child: Row(
        children: List.generate(segments.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF111827) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => onChanged(i),
                  child: Center(
                    child: Text(
                      segments[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String text;
  const _DateChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
          height: 1.2,
        ),
      ),
    );
  }
}
