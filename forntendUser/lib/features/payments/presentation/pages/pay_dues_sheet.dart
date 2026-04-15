import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../services/payment_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'quick_pay_sheet.dart';

enum DuesFilter { next7, next30, all }

class PayDuesSheet extends StatefulWidget {
  final List<Map<String, dynamic>>? initialPayments;

  const PayDuesSheet({super.key, this.initialPayments});

  static Future<void> show(BuildContext context, {List<Map<String, dynamic>>? payments}) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayDuesSheet(initialPayments: payments),
    );
  }

  @override
  State<PayDuesSheet> createState() => _PayDuesSheetState();
}

class _PayDuesSheetState extends State<PayDuesSheet> with SingleTickerProviderStateMixin {
  DuesFilter filter = DuesFilter.all;
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  final Set<int> _selected = {};
  late AnimationController _animController;

  static const _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  static const _weekDays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.initialPayments != null && widget.initialPayments!.isNotEmpty) {
      _payments = widget.initialPayments!;
      _isLoading = false;
      // Select all by default
      for (int i = 0; i < _payments.length; i++) {
        _selected.add(i);
      }
      _animController.forward();
    } else {
      _loadPayments();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final token = await authService.getSavedToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _payments = [];
          _isLoading = false;
        });
        return;
      }
      authService.setAuthToken(token);

      final paymentService = PaymentService();
      final response = await paymentService.getUserPayments();

      if (response['success'] == true) {
        dynamic data = response['data'];
        List<Map<String, dynamic>> allPayments = [];
        if (data is Map && data['data'] != null) {
          allPayments = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          allPayments = List<Map<String, dynamic>>.from(data);
        }

        setState(() {
          // Filter for pending status only
          _payments = allPayments.where((p) => p['status'] == 'pending').toList();
          
          // Select all by default
          _selected.clear();
          for (int i = 0; i < _payments.length; i++) {
            _selected.add(i);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading payments in PayDuesSheet: $e');
    }
    setState(() => _isLoading = false);
    _animController.forward();
  }

  int _getDueDays(Map<String, dynamic> payment) {
    final isPostponed = payment['isPostponed'] == true;
    final dueDateStr = isPostponed && payment['postponedDueDate'] != null
        ? payment['postponedDueDate'].toString()
        : payment['dueDate']?.toString();
    if (dueDateStr == null) return 999;
    try {
      final dueDate = DateTime.parse(dueDateStr);
      return dueDate.difference(DateTime.now()).inDays;
    } catch (e) {
      return 999;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatShortDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}\n${_months[date.month - 1]}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getWeekDay(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return _weekDays[date.weekday - 1];
    } catch (e) {
      return '';
    }
  }

  String _getDueDateStr(Map<String, dynamic> payment) {
    final isPostponed = payment['isPostponed'] == true;
    return isPostponed && payment['postponedDueDate'] != null
        ? payment['postponedDueDate'].toString()
        : payment['dueDate']?.toString() ?? '';
  }

  List<int> _filteredIndexes() {
    return List.generate(_payments.length, (i) => i).where((i) {
      final d = _getDueDays(_payments[i]);
      switch (filter) {
        case DuesFilter.next7:
          return d <= 7;
        case DuesFilter.next30:
          return d <= 30;
        case DuesFilter.all:
          return true;
      }
    }).toList();
  }

  double _totalSelected() {
    double total = 0;
    for (final i in _selected) {
      if (i < _payments.length) {
        final amount = _payments[i]['amount'];
        total += amount is num
            ? amount.toDouble()
            : (double.tryParse(amount.toString()) ?? 0.0);
      }
    }
    return total;
  }

  Color _getStatusColor(int dueDays) {
    if (dueDays < 0) return const Color(0xFFEF4444);
    if (dueDays <= 3) return const Color(0xFFF59E0B);
    if (dueDays <= 7) return const Color(0xFFF97316);
    return const Color(0xFF10B981);
  }

  String _getStatusText(int dueDays, AppLocalizations l10n, bool isRTL) {
    if (dueDays < 0) return 'متأخر ${dueDays.abs()} يوم';
    if (dueDays == 0) return isRTL ? 'يستحق اليوم' : 'Due Today';
    if (dueDays == 1) return l10n.dueTomorrow;
    return l10n.dueInDays(dueDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    final indexes = _filteredIndexes();
    final totalSel = _totalSelected();
    final selectedCount = _selected.where((i) {
      final d = _getDueDays(_payments[i]);
      switch (filter) {
        case DuesFilter.next7: return d <= 7;
        case DuesFilter.next30: return d <= 30;
        case DuesFilter.all: return true;
      }
    }).length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF6B7280)),
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.payDues,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 36), // Balance the close button
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Segmented Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _Segmented(
              segments: [l10n.next7Days, l10n.next30Days, l10n.all],
              selectedIndex: {DuesFilter.next7: 0, DuesFilter.next30: 1, DuesFilter.all: 2}[filter]!,
              onChanged: (i) => setState(() => filter = [DuesFilter.next7, DuesFilter.next30, DuesFilter.all][i]),
            ),
          ),

          const SizedBox(height: 8),

          // Summary bar
          if (!_isLoading && indexes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${indexes.length} مستحق',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (selectedCount > 0)
                    Text(
                      'تم تحديد $selectedCount',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(strokeWidth: 2.5),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل المستحقات...',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : indexes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.check_circle_outline_rounded, size: 32, color: Color(0xFF10B981)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noPaymentsFound,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'لا توجد مستحقات في هذه الفترة',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        itemCount: indexes.length,
                        itemBuilder: (_, idx) {
                          final i = indexes[idx];
                          final payment = _payments[i];
                          final sel = _selected.contains(i);
                          final dueDays = _getDueDays(payment);
                          final statusColor = _getStatusColor(dueDays);
                          final dateStr = _getDueDateStr(payment);

                          final storeName = payment['storeNameAr']?.toString() ??
                              payment['merchantName']?.toString() ??
                              payment['storeName']?.toString() ??
                              payment['store']?['nameAr']?.toString() ??
                              payment['store']?['name']?.toString() ??
                              'متجر';

                          final amountValue = payment['amount'];
                          final amount = amountValue is num
                              ? amountValue.toDouble()
                              : (double.tryParse(amountValue.toString()) ?? 0.0);

                          final installmentNumber = payment['installmentNumber'] as int? ?? 1;
                          final installmentsCount = payment['installmentsCount'] as int? ?? 1;
                          final isPostponed = payment['isPostponed'] == true;

                          return AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              final delay = (idx * 0.1).clamp(0.0, 0.5);
                              final progress = Curves.easeOutCubic.transform(
                                ((_animController.value - delay) / (1 - delay)).clamp(0.0, 1.0),
                              );
                              return Opacity(
                                opacity: progress,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - progress)),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  sel ? _selected.remove(i) : _selected.add(i);
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: sel ? const Color(0xFFF8FFFE) : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: sel ? AppColors.primary.withOpacity(0.3) : const Color(0xFFF3F4F6),
                                      width: sel ? 1.5 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: sel
                                          ? AppColors.primary.withOpacity(0.06)
                                          : const Color(0x08000000),
                                        blurRadius: sel ? 16 : 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Row 1: Checkbox + Store name + Amount
                                      Row(
                                        children: [
                                          // Animated checkbox
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: sel ? AppColors.primary : Colors.transparent,
                                              borderRadius: BorderRadius.circular(7),
                                              border: Border.all(
                                                color: sel ? AppColors.primary : const Color(0xFFD1D5DB),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: sel
                                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),

                                          // Store icon
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(11),
                                            ),
                                            child: Icon(Icons.store_rounded, size: 18, color: statusColor),
                                          ),
                                          const SizedBox(width: 10),

                                          // Store name and installment info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  storeName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                    color: Color(0xFF111827),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  l10n.installmentOf(installmentNumber, installmentsCount),
                                                  style: const TextStyle(
                                                    color: Color(0xFF9CA3AF),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Amount
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'JD ${amount.toStringAsFixed(3)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Divider
                                      Container(
                                        height: 1,
                                        color: const Color(0xFFF3F4F6),
                                      ),

                                      const SizedBox(height: 12),

                                      // Row 2: Due date + status + progress
                                      Row(
                                        children: [
                                          // Calendar icon + date
                                          Icon(Icons.calendar_today_rounded, size: 14, color: const Color(0xFF9CA3AF)),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatDate(dateStr),
                                            style: const TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '(${_getWeekDay(dateStr)})',
                                            style: const TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 11,
                                            ),
                                          ),

                                          const Spacer(),

                                          // Status badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: statusColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  _getStatusText(dueDays, l10n, isRTL),
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Progress bar
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          minHeight: 4,
                                          value: installmentNumber / installmentsCount,
                                          backgroundColor: const Color(0xFFF3F4F6),
                                          valueColor: AlwaysStoppedAnimation(statusColor.withOpacity(0.7)),
                                        ),
                                      ),

                                      // Postponed badge
                                      if (isPostponed) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF7ED),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFFED7AA)),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.schedule_rounded, size: 12, color: Color(0xFFF59E0B)),
                                              SizedBox(width: 4),
                                              Text(
                                                'مؤجّل',
                                                style: TextStyle(
                                                  color: Color(0xFFF59E0B),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Bottom pay button
          if (!_isLoading && indexes.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Column(
                children: [
                  // Total summary
                  if (_selected.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الإجمالي ($selectedCount مستحق)',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'JD ${totalSel.toStringAsFixed(3)}',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Pay button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selected.isEmpty
                            ? const Color(0xFFE5E7EB)
                            : AppColors.primary,
                        foregroundColor: _selected.isEmpty
                            ? const Color(0xFF9CA3AF)
                            : Colors.white,
                        elevation: _selected.isEmpty ? 0 : 2,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _selected.isEmpty
                          ? null
                          : () async {
                              // Collect selected payment IDs
                              final selectedPayments = _selected
                                  .where((i) => i < _payments.length)
                                  .map((i) => _payments[i])
                                  .toList();
                              
                              final paymentIds = selectedPayments
                                  .map((p) => p['id'] as int)
                                  .toList();

                              // Show quick pay sheet with saved cards
                              final result = await QuickPaySheet.show(
                                context,
                                paymentIds: paymentIds,
                                totalAmount: totalSel,
                                currency: 'JOD',
                              );

                              if (result == true && mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.paymentSuccessful(totalSel.toStringAsFixed(3))),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              }
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selected.isEmpty
                                ? 'اختر مستحقات للدفع'
                                : l10n.payAmount(totalSel.toStringAsFixed(3)),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Segmented Control ─────────────────────────
class _Segmented extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _Segmented({required this.segments, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(segments.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      segments[i],
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                        color: selected ? const Color(0xFF111827) : const Color(0xFF6B7280),
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
