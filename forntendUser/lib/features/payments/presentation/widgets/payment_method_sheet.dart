import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../services/saved_cards_service.dart';
import '../../../../services/api_service.dart';
import '../../../../core/theme/app_colors.dart';

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

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  PaymentMethod _selected = PaymentMethod.savedCard;
  final SavedCardsService _savedCardsService = SavedCardsService();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _cards = [];
  int? _selectedCardIndex;
  bool _isLoadingCards = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
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
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: const Color(0xFF1F2937),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),

          // Total Label
          Text(
            l10n.totalAmountDue,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.amountLabel,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 40),

          // Selection Section
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- Apple Pay Option ---
                  _buildPaymentRow(
                    isSelected: _selected == PaymentMethod.applePay,
                    onTap: () => setState(() => _selected = PaymentMethod.applePay),
                    icon: const Icon(Icons.apple, size: 24, color: Colors.black),
                    title: 'Apple Pay',
                  ),
                  const SizedBox(height: 12),

                  // --- Saved Cards List ---
                  if (_isLoadingCards)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_cards.isNotEmpty)
                    ..._cards.asMap().entries.map((entry) {
                      final i = entry.key;
                      final card = entry.value;
                      final isSelected = _selected == PaymentMethod.savedCard && _selectedCardIndex == i;
                      final brand = card['brand']?.toString().toUpperCase() ?? 'CARD';
                      final last4 = card['last4']?.toString() ?? '****';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPaymentRow(
                          isSelected: isSelected,
                          onTap: () => setState(() {
                            _selected = PaymentMethod.savedCard;
                            _selectedCardIndex = i;
                          }),
                          icon: const Icon(Icons.credit_card_outlined, size: 22, color: Color(0xFF4B5563)),
                          title: '$brand •••• $last4',
                        ),
                      );
                    }),

                  // --- New Card Option ---
                  _buildPaymentRow(
                    isSelected: _selected == PaymentMethod.newCard,
                    onTap: () => setState(() => _selected = PaymentMethod.newCard),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 22, color: Color(0xFF4B5563)),
                    title: isRTL ? 'إضافة بطاقة جديدة' : 'Add New Card',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () async {
                if (_selected == PaymentMethod.savedCard) {
                  await _payWithSavedCard();
                } else if (_selected == PaymentMethod.newCard) {
                  widget.onCardAdded?.call(AddedCard(last4: 'NEW', holder: '', exp: ''));
                  Navigator.pop(context);
                } else if (_selected == PaymentMethod.applePay) {
                  widget.onApplePay();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                disabledBackgroundColor: const Color(0xFF9CA3AF),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isRTL ? 'تأكيد الدفع' : 'Confirm Payment',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget icon,
    required String title,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF9FAFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF111827), size: 22)
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AddedCard {
  final String last4;
  final String holder;
  final String exp;
  AddedCard({required this.last4, required this.holder, required this.exp});
}
