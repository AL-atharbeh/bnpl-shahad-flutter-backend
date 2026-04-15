import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/saved_cards_service.dart';
import '../../../../core/theme/app_colors.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _savedCardsService = SavedCardsService();
  bool _isLoading = false;
  CardEditController? _cardController;

  @override
  void initState() {
    super.initState();
    _cardController = CardEditController();
  }

  @override
  void dispose() {
    _cardController?.dispose();
    super.dispose();
  }

  Future<void> _handleSaveCard() async {
    if (_cardController?.details.complete != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال بيانات البطاقة بشكل صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create SetupIntent on backend
      debugPrint('🔄 Creating SetupIntent...');
      final setupResult = await _savedCardsService.createSetupIntent();
      if (!setupResult['success']) {
        throw setupResult['error'] ?? 'فشل إعداد البطاقة';
      }

      final clientSecret = setupResult['clientSecret'];
      debugPrint('✅ Got clientSecret: ${clientSecret.toString().substring(0, 20)}...');

      // 2. Confirm SetupIntent using Stripe SDK
      debugPrint('🔄 Confirming SetupIntent with Stripe SDK...');
      final setupIntent = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      debugPrint('📋 SetupIntent status: ${setupIntent.status}');
      debugPrint('📋 SetupIntent paymentMethodId: ${setupIntent.paymentMethodId}');

      // SetupIntent.status is a String, not an enum!
      // Valid success statuses: 'Succeeded', 'succeeded', 'RequiresAction'
      final status = setupIntent.status.toLowerCase();
      if (status == 'succeeded' || status == 'requiresaction') {
        // 3. Send PaymentMethod ID to backend to save for future use
        debugPrint('🔄 Confirming card on backend...');
        final confirmResult = await _savedCardsService.confirmCard(setupIntent.paymentMethodId);
        
        if (confirmResult['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمت إضافة البطاقة بنجاح ✅'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(confirmResult['card']);
          }
        } else {
          throw confirmResult['error'] ?? 'فشل حفظ البطاقة';
        }
      } else {
        debugPrint('❌ SetupIntent failed with status: ${setupIntent.status}');
        throw 'فشل التحقق من البطاقة (الحالة: ${setupIntent.status})';
      }
    } catch (e) {
      debugPrint('❌ Error in _handleSaveCard: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          l10n.addNewCard,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أدخل بيانات البطاقة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم التحقق من البطاقة وربطها بعمليات الدفع التلقائي للأقساط المستقبلية بأمان.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Stripe Card Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: CardField(
                controller: _cardController,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.security_rounded, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'تشفير آمن متوافق مع معايير Stripe PCI DSS',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSaveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_card_rounded),
                          const SizedBox(width: 12),
                          const Text(
                            'حفظ البطاقة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            Center(
              child: Text(
                'لن نقوم بخصم أي مبلغ الآن، هذه العملية فقط للربط.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
