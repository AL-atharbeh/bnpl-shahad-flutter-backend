import 'package:flutter/material.dart';
import '../../../../services/saved_cards_service.dart';
import '../../../../services/api_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom sheet to let user pick a saved card and pay instantly
class QuickPaySheet extends StatefulWidget {
  /// List of payment IDs to process
  final List<int> paymentIds;

  /// Total amount to display
  final double totalAmount;

  /// Currency
  final String currency;

  const QuickPaySheet({
    super.key,
    required this.paymentIds,
    required this.totalAmount,
    this.currency = 'JOD',
  });

  /// Show the quick pay sheet
  static Future<bool?> show(
    BuildContext context, {
    required List<int> paymentIds,
    required double totalAmount,
    String currency = 'JOD',
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickPaySheet(
        paymentIds: paymentIds,
        totalAmount: totalAmount,
        currency: currency,
      ),
    );
  }

  @override
  State<QuickPaySheet> createState() => _QuickPaySheetState();
}

class _QuickPaySheetState extends State<QuickPaySheet>
    with SingleTickerProviderStateMixin {
  final SavedCardsService _savedCardsService = SavedCardsService();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _cards = [];
  int? _selectedCardIndex;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _savedCardsService.getCards();
      if (result['success'] == true) {
        final cards = List<Map<String, dynamic>>.from(result['cards'] ?? []);
        setState(() {
          _cards = cards;
          // Auto-select the default card
          for (int i = 0; i < cards.length; i++) {
            if (cards[i]['isDefault'] == true) {
              _selectedCardIndex = i;
              break;
            }
          }
          // If no default, select first card
          if (_selectedCardIndex == null && cards.isNotEmpty) {
            _selectedCardIndex = 0;
          }
          _isLoading = false;
        });
        _animController.forward();
      } else {
        setState(() {
          _error = result['error'] ?? 'فشل تحميل البطاقات';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (_selectedCardIndex == null) return;

    setState(() => _isProcessing = true);

    try {
      final card = _cards[_selectedCardIndex!];
      final cardId = card['id'];

      // Call backend to charge using saved card for each payment
      bool allSucceeded = true;
      String? lastError;

      for (final paymentId in widget.paymentIds) {
        final response = await _apiService.post('/saved-cards/charge', {
          'paymentId': paymentId,
          'cardId': cardId,
        });

        if (response['success'] != true) {
          allSucceeded = false;
          lastError = response['error'] ?? 'فشل الدفع';
          break;
        }
      }

      if (allSucceeded) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _error = lastError;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  String _getBrandIcon(String? brand) {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return '💳';
      case 'mastercard':
        return '💳';
      case 'amex':
        return '💳';
      default:
        return '💳';
    }
  }

  String _getBrandName(String? brand) {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'Amex';
      default:
        return brand ?? 'Card';
    }
  }

  Color _getBrandColor(String? brand) {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF2E77BC);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.flash_on_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'دفع سريع',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        'اختر بطاقة للدفع الفوري',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Amount summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF111827),
                  const Color(0xFF1F2937),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF111827).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبلغ المستحق',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.currency} ${widget.totalAmount.toStringAsFixed(3)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.paymentIds.length} قسط',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cards list or loading/error
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  CircularProgressIndicator(strokeWidth: 2.5),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل البطاقات...',
                    style: TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 14),
                  ),
                ],
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFEF4444), size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _loadCards,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          else if (_cards.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.credit_card_off_rounded,
                        size: 28, color: Color(0xFFF59E0B)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد بطاقات محفوظة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'أضف بطاقة من الملف الشخصي لتفعيل الدفع السريع',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _cards.length,
                itemBuilder: (_, index) {
                  final card = _cards[index];
                  final isSelected = _selectedCardIndex == index;
                  final brand = card['brand']?.toString();
                  final last4 = card['last4']?.toString() ?? '****';
                  final expMonth = card['expMonth']?.toString() ?? '--';
                  final expYear = card['expYear']?.toString() ?? '--';
                  final isDefault = card['isDefault'] == true;
                  final brandColor = _getBrandColor(brand);

                  return AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final delay = (index * 0.15).clamp(0.0, 0.5);
                      final progress = Curves.easeOutCubic.transform(
                        ((_animController.value - delay) / (1 - delay))
                            .clamp(0.0, 1.0),
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
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCardIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.04)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFF3F4F6),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              // Radio
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFFD1D5DB),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 14),

                              // Brand icon
                              Container(
                                width: 48,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: brandColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: brandColor.withOpacity(0.15)),
                                ),
                                child: Center(
                                  child: Text(
                                    _getBrandName(brand),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: brandColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Card info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '•••• $last4',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF111827),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        if (isDefault) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'افتراضية',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'تنتهي $expMonth/$expYear',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Pay button
          Container(
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, MediaQuery.of(context).padding.bottom + 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    (_selectedCardIndex == null || _isProcessing || _cards.isEmpty)
                        ? null
                        : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  disabledForegroundColor: const Color(0xFF9CA3AF),
                  elevation: _selectedCardIndex != null ? 4 : 0,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'جاري الدفع...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flash_on_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _cards.isEmpty
                                ? 'أضف بطاقة أولاً'
                                : 'ادفع ${widget.currency} ${widget.totalAmount.toStringAsFixed(3)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
