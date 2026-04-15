import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../services/saved_cards_service.dart';
import '../../../../services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../presentation/pages/payment_webview_page.dart';

enum PaymentMethod { savedCard, newCard, applePay }

class PaymentMethodSheet extends StatefulWidget {
  final String amountLabel;
  final double amount;
  final int? paymentId;
  final VoidCallback onApplePay;
  final ValueChanged<AddedCard>? onCardAdded;
  final VoidCallback? onPaymentSuccess;

  const PaymentMethodSheet({
    super.key,
    required this.amountLabel,
    required this.amount,
    this.paymentId,
    required this.onApplePay,
    this.onCardAdded,
    this.onPaymentSuccess,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String amountLabel,
    double amount = 0,
    int? paymentId,
    required VoidCallback onApplePay,
    ValueChanged<AddedCard>? onCardAdded,
    VoidCallback? onPaymentSuccess,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentMethodSheet(
        amountLabel: amountLabel,
        amount: amount,
        paymentId: paymentId,
        onApplePay: onApplePay,
        onCardAdded: onCardAdded,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet>
    with SingleTickerProviderStateMixin {
  PaymentMethod _selected = PaymentMethod.savedCard;
  final SavedCardsService _savedCardsService = SavedCardsService();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _cards = [];
  int? _selectedCardIndex;
  bool _isLoadingCards = true;
  bool _isProcessing = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadSavedCards();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCards() async {
    try {
      final result = await _savedCardsService.getCards();
      if (result['success'] == true) {
        final cards = List<Map<String, dynamic>>.from(result['cards'] ?? []);
        setState(() {
          _cards = cards;
          _isLoadingCards = false;
          // Auto-select the default card
          for (int i = 0; i < cards.length; i++) {
            if (cards[i]['isDefault'] == true) {
              _selectedCardIndex = i;
              break;
            }
          }
          if (_selectedCardIndex == null && cards.isNotEmpty) {
            _selectedCardIndex = 0;
          }
          // If no saved cards, switch to new card method
          if (cards.isEmpty) {
            _selected = PaymentMethod.newCard;
          }
        });
        _animController.forward();
      } else {
        setState(() {
          _isLoadingCards = false;
          _selected = PaymentMethod.newCard;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCards = false;
        _selected = PaymentMethod.newCard;
      });
    }
  }

  Future<void> _payWithSavedCard() async {
    if (_selectedCardIndex == null || widget.paymentId == null) return;
    setState(() => _isProcessing = true);

    try {
      final card = _cards[_selectedCardIndex!];
      final response = await _apiService.post('/saved-cards/charge', {
        'paymentId': widget.paymentId,
        'cardId': card['id'],
      });

      if (response['success'] == true) {
        widget.onPaymentSuccess?.call();
        if (mounted) Navigator.of(context).pop(true);
      } else {
        final errorData = response['data'];
        final errorMsg = errorData is Map ? (errorData['message'] ?? response['error']) : response['error'];
        throw errorMsg ?? 'فشل الدفع';
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getBrandName(String? brand) {
    switch (brand?.toLowerCase()) {
      case 'visa': return 'Visa';
      case 'mastercard': return 'Mastercard';
      case 'amex': return 'Amex';
      default: return brand ?? 'Card';
    }
  }

  Color _getBrandColor(String? brand) {
    switch (brand?.toLowerCase()) {
      case 'visa': return const Color(0xFF1A1F71);
      case 'mastercard': return const Color(0xFFEB001B);
      case 'amex': return const Color(0xFF2E77BC);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header + Amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  l10n.choosePaymentMethod,
                  style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Text(
                    widget.amountLabel,
                    style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Saved Cards Section
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Saved Cards ===
                  if (_isLoadingCards)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (_cards.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(Icons.credit_card_rounded, size: 18,
                            color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            isRTL ? 'البطاقات المحفوظة' : 'Saved Cards',
                            style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._cards.asMap().entries.map((entry) {
                      final i = entry.key;
                      final card = entry.value;
                      final isSelected = _selected == PaymentMethod.savedCard && _selectedCardIndex == i;
                      final brand = card['brand']?.toString();
                      final last4 = card['last4']?.toString() ?? '****';
                      final expMonth = card['expMonth']?.toString().padLeft(2, '0') ?? '--';
                      final expYear = card['expYear']?.toString() ?? '--';
                      final isDefault = card['isDefault'] == true;
                      final brandColor = _getBrandColor(brand);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selected = PaymentMethod.savedCard;
                            _selectedCardIndex = i;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.04)
                                  : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : const Color(0xFFE6ECF3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Radio
                                _RadioDot(selected: isSelected),
                                const SizedBox(width: 12),
                                // Brand
                                Container(
                                  width: 44, height: 30,
                                  decoration: BoxDecoration(
                                    color: brandColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getBrandName(brand),
                                      style: TextStyle(
                                        fontSize: 9, fontWeight: FontWeight.w800,
                                        color: brandColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '•••• $last4',
                                            style: const TextStyle(
                                              fontSize: 15, fontWeight: FontWeight.w700,
                                              color: Color(0xFF111827),
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          if (isDefault) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '⭐',
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        '$expMonth/$expYear',
                                        style: const TextStyle(
                                          fontSize: 12, color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded,
                                    color: AppColors.primary, size: 22),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  // === Divider ===
                  if (_cards.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade200)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              isRTL ? 'أو' : 'OR',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12, fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade200)),
                        ],
                      ),
                    ),

                  // === New Card / Stripe ===
                  GestureDetector(
                    onTap: () => setState(() => _selected = PaymentMethod.newCard),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _selected == PaymentMethod.newCard
                            ? const Color(0xFFF0F7FF)
                            : const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selected == PaymentMethod.newCard
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFE6ECF3),
                          width: _selected == PaymentMethod.newCard ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _RadioDot(selected: _selected == PaymentMethod.newCard,
                            activeColor: const Color(0xFF3B82F6)),
                          const SizedBox(width: 12),
                          Container(
                            width: 44, height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.credit_card_rounded,
                              size: 16, color: Color(0xFF3B82F6)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isRTL ? 'بطاقة جديدة / Stripe' : 'New Card / Stripe',
                              style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE6ECF3)),
                            ),
                            child: const Text(
                              'Visa / MC',
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // === Apple Pay ===
                  GestureDetector(
                    onTap: () => setState(() => _selected = PaymentMethod.applePay),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _selected == PaymentMethod.applePay
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selected == PaymentMethod.applePay
                              ? const Color(0xFF111827)
                              : const Color(0xFFE6ECF3),
                          width: _selected == PaymentMethod.applePay ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _RadioDot(selected: _selected == PaymentMethod.applePay,
                            activeColor: const Color(0xFF111827)),
                          const SizedBox(width: 12),
                          Container(
                            width: 44, height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.apple, size: 18, color: Color(0xFF111827)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Apple Pay',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.apple, size: 14, color: Colors.white),
                                SizedBox(width: 3),
                                Text('Pay', style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Pay Button
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () async {
                  if (_selected == PaymentMethod.savedCard && _selectedCardIndex != null) {
                    await _payWithSavedCard();
                  } else if (_selected == PaymentMethod.newCard) {
                    widget.onCardAdded?.call(AddedCard(
                      last4: 'STRIPE', holder: 'STRIPE', exp: '00/00'));
                    Navigator.pop(context);
                  } else if (_selected == PaymentMethod.applePay) {
                    widget.onApplePay();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selected == PaymentMethod.savedCard
                      ? AppColors.primary
                      : _selected == PaymentMethod.applePay
                          ? const Color(0xFF111827)
                          : const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                          SizedBox(width: 12),
                          Text('جاري الدفع...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selected == PaymentMethod.savedCard
                                ? Icons.flash_on_rounded
                                : _selected == PaymentMethod.applePay
                                    ? Icons.apple
                                    : Icons.credit_card_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${l10n.pay} ${widget.amountLabel}',
                            style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700,
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

// ========= Radio Dot =========
class _RadioDot extends StatelessWidget {
  final bool selected;
  final bool dimmed;
  final Color activeColor;
  const _RadioDot({
    required this.selected,
    this.dimmed = false,
    this.activeColor = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22, height: 22,
      decoration: BoxDecoration(
        color: selected ? activeColor : (dimmed ? const Color(0xFFE7EBF2) : Colors.white),
        border: Border.all(
          color: selected ? activeColor : const Color(0xFFD7DCE4),
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: selected
          ? const Center(
              child: Icon(Icons.check_rounded, color: Colors.white, size: 14),
            )
          : null,
    );
  }
}

// ========= AddedCard Model =========
class AddedCard {
  final String last4;
  final String holder;
  final String exp;
  AddedCard({required this.last4, required this.holder, required this.exp});
}
