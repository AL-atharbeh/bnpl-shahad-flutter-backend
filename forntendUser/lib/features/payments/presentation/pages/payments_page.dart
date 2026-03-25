import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../services/points_service.dart';
import '../../../../services/postpone_service.dart';
import '../../../../services/payment_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../config/env/env_dev.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'pay_dues_sheet.dart';
import 'payments_history_page.dart';
import '../widgets/payment_method_sheet.dart';
import '../widgets/extend_due_date_sheet.dart';
import '../widgets/free_postpone_sheet.dart';
import 'payment_webview_page.dart';

class BNPLColors {
  static const bg = Color(0xFFF0F2F5);
  static const text = Color(0xFF111827);
  static const subtext = Color(0xFF6B7280);
  static final primary = AppColors.primary; // Financial Green
  static const accent = Color(0xFF7C8CF8);
  static const card = Colors.white;
  static const stroke = Color(0xFFE6ECF3);
}

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final PaymentService _paymentService = PaymentService();
  
  // Payments from database
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  bool _userFreePostponeUsed = false; // Track from backend response
  
  @override
  void initState() {
    super.initState();
    _loadPayments();
  }
  
  Future<void> _loadPayments() async {
    print('📦 [_loadPayments CALLED]');
    print('   Timestamp: ${DateTime.now()}');
    
    setState(() => _isLoading = true);
    
    // Check if user is logged in and has token
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    final token = await authService.getSavedToken();
    
    if (EnvDev.enableLogging) {
      print('🔍 User logged in: $isLoggedIn, Token exists: ${token != null}');
      if (token != null) {
        print('   Token length: ${token.length}');
        print('   Token preview: ${token.length > 30 ? token.substring(0, 30) + "..." : token}');
      }
    }
    
    if (!isLoggedIn || token == null || token.isEmpty) {
      if (EnvDev.enableLogging) {
        print('❌ User not logged in or token missing');
      }
      setState(() {
        _payments = [];
        _isLoading = false;
      });
      return;
    }
    
    // Ensure token is set in ApiService
    authService.setAuthToken(token);
    
    if (EnvDev.enableLogging) {
      print('🔑 Token set in ApiService, making request...');
    }
    
    try {
      final response = await _paymentService.getPendingPayments(nextOnly: false);
      
      if (EnvDev.enableLogging) {
        print('📥 API Response: success=${response['success']}');
        print('   Response keys: ${response.keys.toList()}');
        if (response['statusCode'] != null) {
          print('   Status code: ${response['statusCode']}');
        }
        if (response['error'] != null) {
          print('   Error: ${response['error']}');
        }
      }
      
      // Check for 401 Unauthorized - token expired or invalid
      if (response['statusCode'] == 401) {
        if (EnvDev.enableLogging) {
          print('❌ 401 Unauthorized - Token expired or invalid');
        }
        // Clear login state and show message
        await authService.clearLoginState();
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: l10n?.login ?? 'تسجيل الدخول',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to login page
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/phone-input',
                    (route) => false,
                  );
                },
              ),
            ),
          );
        }
        setState(() {
          _payments = [];
          _isLoading = false;
        });
        return;
      }
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic paymentsData;
        
        if (EnvDev.enableLogging) {
          print('   Backend data type: ${backendData.runtimeType}');
          if (backendData is Map) {
            print('   Backend data keys: ${backendData.keys.toList()}');
          }
        }
        
        // Backend returns: { success: true, data: [...], filters: {...} }
        // ApiService wraps it: { success: true, data: { success: true, data: [...], filters: {...} } }
        if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            paymentsData = backendData['data'];
            if (EnvDev.enableLogging) {
              print('   ✅ Found data in backendData[\'data\']');
            }
          } else if (backendData['data'] != null) {
            paymentsData = backendData['data'];
            if (EnvDev.enableLogging) {
              print('   ✅ Found data in backendData[\'data\'] (no success flag)');
            }
          } else {
            paymentsData = backendData;
            if (EnvDev.enableLogging) {
              print('   ⚠️ Using backendData directly');
            }
          }
        } else if (backendData is List) {
          paymentsData = backendData;
          if (EnvDev.enableLogging) {
            print('   ✅ Backend data is already a List');
          }
        } else {
          paymentsData = backendData;
          if (EnvDev.enableLogging) {
            print('   ⚠️ Backend data is neither Map nor List: ${backendData.runtimeType}');
          }
        }
        
        if (paymentsData is List) {
          if (EnvDev.enableLogging) {
            print('   ✅ Payments data is List with ${paymentsData.length} items');
            if (paymentsData.isNotEmpty) {
              print('   Sample item type: ${paymentsData[0].runtimeType}');
              if (paymentsData[0] is Map) {
                print('   Sample item keys: ${(paymentsData[0] as Map).keys.toList()}');
              }
            }
          }
          
          // Convert all payments to Map<String, dynamic>
          final allPaymentsList = paymentsData.map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else {
              if (EnvDev.enableLogging) {
                print('   ⚠️ Item is not a Map: ${item.runtimeType}');
              }
              return <String, dynamic>{};
            }
          }).toList().cast<Map<String, dynamic>>();

          // Filter for pending status only
          final paymentsList = allPaymentsList.where((p) => p['status'] == 'pending').map((item) {
            final converted = Map<String, dynamic>.from(item);
            // Ensure dueDate is properly formatted
            if (converted['dueDate'] != null) {
              final dueDate = converted['dueDate'];
              if (dueDate is DateTime) {
                converted['dueDate'] = dueDate.toIso8601String();
              } else if (dueDate is String) {
                // Already a string, keep it
              } else {
                // Try to convert
                try {
                  converted['dueDate'] = DateTime.parse(dueDate.toString()).toIso8601String();
                } catch (e) {
                  if (EnvDev.enableLogging) {
                    print('   ⚠️ Could not parse dueDate: $dueDate');
                  }
                }
              }
            }
            return converted;
          }).toList();
          
          if (EnvDev.enableLogging) {
            print('   ✅ Filtered to ${paymentsList.length} pending installments out of ${allPaymentsList.length} total');
          }
          
          // Sort payments by effective due date (nearest first)
          paymentsList.sort((a, b) {
            final isPostponedA = a['isPostponed'] == true;
            final dateAStr = isPostponedA && a['postponedDueDate'] != null
                ? a['postponedDueDate'].toString()
                : a['dueDate']?.toString();
            
            final isPostponedB = b['isPostponed'] == true;
            final dateBStr = isPostponedB && b['postponedDueDate'] != null
                ? b['postponedDueDate'].toString()
                : b['dueDate']?.toString();
            
            if (dateAStr == null) return 1;
            if (dateBStr == null) return -1;
            
            try {
              final dateA = DateTime.parse(dateAStr);
              final dateB = DateTime.parse(dateBStr);
              return dateA.compareTo(dateB);
            } catch (e) {
              return 0;
            }
          });
          
          // Extract user.freePostponeUsed from response
          bool userFreePostponeUsed = false;
          if (backendData is Map && backendData['user'] != null) {
            final userData = backendData['user'] as Map<String, dynamic>;
            userFreePostponeUsed = userData['freePostponeUsed'] == true;
            print('📌 [User Data from Backend]');
            print('   userData: $userData');
            print('   freePostponeUsed value: ${userData['freePostponeUsed']}');
            print('   userFreePostponeUsed (parsed): $userFreePostponeUsed');
          } else {
            print('⚠️ [No user data in response!]');
            print('   backendData type: ${backendData.runtimeType}');
            print('   backendData keys: ${backendData is Map ? backendData.keys : "not a map"}');
          }
          
          setState(() {
            _payments = paymentsList;
            _userFreePostponeUsed = userFreePostponeUsed;
            _isLoading = false;
          });
          
          print('✅ [State Updated]');
          print('   _userFreePostponeUsed: $_userFreePostponeUsed');
          print('   _payments count: ${_payments.length}');
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_payments.length} pending payments');
            if (_payments.isNotEmpty) {
              final firstPayment = _payments[0];
              print('   Sample payment keys: ${firstPayment.keys.toList()}');
              print('   Sample payment:');
              print('     id: ${firstPayment['id']}');
              print('     amount: ${firstPayment['amount']}');
              print('     storeName: ${firstPayment['storeName']}');
              print('     merchantName: ${firstPayment['merchantName']}');
              print('     storeNameAr: ${firstPayment['storeNameAr']}');
              print('     dueDate: ${firstPayment['dueDate']}');
              print('     installmentNumber: ${firstPayment['installmentNumber']}');
              print('     installmentsCount: ${firstPayment['installmentsCount']}');
              if (firstPayment['store'] != null) {
                print('     store: ${firstPayment['store']}');
              }
            }
          }
        } else {
          if (EnvDev.enableLogging) {
            print('⚠️ Payments data is not a List: ${paymentsData.runtimeType}');
            if (paymentsData is Map) {
              print('   Payments data keys: ${paymentsData.keys.toList()}');
            }
          }
          setState(() {
            _payments = [];
            _isLoading = false;
          });
        }
      } else {
        if (EnvDev.enableLogging) {
          print('❌ API returned success=false: ${response['error']}');
        }
        setState(() {
          _payments = [];
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        _payments = [];
        _isLoading = false;
      });
      if (EnvDev.enableLogging) {
        print('❌ Error loading payments: $e');
        print('   Stack trace: $stackTrace');
      }
    }
  }
  
  // Calculate summary totals
  double _calculateTotal() {
    return _payments.fold(0.0, (sum, payment) {
      final amount = payment['amount'];
      return sum + (amount is num ? amount.toDouble() : (double.tryParse(amount.toString()) ?? 0.0));
    });
  }
  
  double _calculateDueIn7Days() {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    
    return _payments.fold(0.0, (sum, payment) {
      final dueDateStr = payment['dueDate']?.toString();
      if (dueDateStr == null) return sum;
      
      try {
        final dueDate = DateTime.parse(dueDateStr);
        if (dueDate.isBefore(sevenDaysLater) || dueDate.isAtSameMomentAs(sevenDaysLater)) {
          final amount = payment['amount'];
          return sum + (amount is num ? amount.toDouble() : (double.tryParse(amount.toString()) ?? 0.0));
        }
      } catch (e) {
        // Invalid date format
      }
      return sum;
    });
  }
  
  double _calculateDueIn30Days() {
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));
    
    return _payments.fold(0.0, (sum, payment) {
      final dueDateStr = payment['dueDate']?.toString();
      if (dueDateStr == null) return sum;
      
      try {
        final dueDate = DateTime.parse(dueDateStr);
        if (dueDate.isBefore(thirtyDaysLater) || dueDate.isAtSameMomentAs(thirtyDaysLater)) {
          final amount = payment['amount'];
          return sum + (amount is num ? amount.toDouble() : (double.tryParse(amount.toString()) ?? 0.0));
        }
      } catch (e) {
        // Invalid date format
      }
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    return Scaffold(
      backgroundColor: BNPLColors.bg,
      body: _Content(
        l10n: l10n,
        isRTL: isRTL,
        payments: _payments,
        isLoading: _isLoading,
        userFreePostponeUsed: _userFreePostponeUsed,
        total: _calculateTotal(),
        dueIn7: _calculateDueIn7Days(),
        dueIn30: _calculateDueIn30Days(),
        onRefresh: _loadPayments,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isRTL;
  final List<Map<String, dynamic>> payments;
  final bool isLoading;
  final bool userFreePostponeUsed;
  final double total;
  final double dueIn7;
  final double dueIn30;
  final VoidCallback onRefresh;
  
  const _Content({
    required this.l10n,
    required this.isRTL,
    required this.payments,
    required this.isLoading,
    required this.userFreePostponeUsed,
    required this.total,
    required this.dueIn7,
    required this.dueIn30,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
      return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.refreshComplete),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          elevation: 0,
          backgroundColor: BNPLColors.bg,
          centerTitle: true,
          title: Text(
            l10n.payLaterPurchases,
            style: AppTextStyles.changaH4.copyWith(color: BNPLColors.text),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(12),
            child: const SizedBox(height: 12),
          ),
        ),

        // بطاقة الملخص الهادئة
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SummaryCard(
              dueIn30: dueIn30,
              dueIn7: dueIn7,
              total: total,
              l10n: l10n,
              payments: payments,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // أزرار سريعة
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _QuickAction(
                  icon: Icons.receipt_long_rounded, 
                  label: l10n.payDues,
                  l10n: l10n,
                  onTap: () => PayDuesSheet.show(context, payments: payments),
                )),
                const SizedBox(width: 12),
                Expanded(child: _QuickAction(
                  icon: Icons.history_rounded, 
                  label: l10n.viewHistory,
                  l10n: l10n,
                  onTap: () => PaymentsHistoryPage.show(context),
                )),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

                 // قسم الشهر الحالي
         SliverToBoxAdapter(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: Builder(
               builder: (context) {
                 final now = DateTime.now();
                 const months = [
                   'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                   'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
                 ];
                 final currentMonth = '${months[now.month - 1]} ${now.year}';
                 return Row(
                   children: [
                     Text(currentMonth, 
                       style: const TextStyle(
                         fontWeight: FontWeight.w800, 
                         fontSize: 16, 
                         color: BNPLColors.text
                       )
                     ),
                     const SizedBox(width: 8),
                     const Icon(Icons.brightness_1, size: 6, color: BNPLColors.accent),
                     const SizedBox(width: 6),
                     Text(l10n.dueSoon, 
                       style: const TextStyle(
                         color: BNPLColors.accent, 
                         fontWeight: FontWeight.w700
                       )
                     ),
                   ],
                 );
               },
             ),
           ),
         ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                 // فواتير (بطاقات هادئة)
         isLoading
           ? const SliverToBoxAdapter(
               child: Padding(
                 padding: EdgeInsets.all(32.0),
                 child: Center(child: CircularProgressIndicator()),
               ),
             )
           : payments.isEmpty
             ? SliverToBoxAdapter(
                 child: Padding(
                   padding: const EdgeInsets.all(32.0),
                   child: Center(
                     child: Text(
                       l10n.noPaymentsFound,
                       style: const TextStyle(
                         color: BNPLColors.subtext,
                         fontSize: 16,
                       ),
                     ),
                   ),
                 ),
               )
             : SliverList.builder(
                 itemCount: payments.isNotEmpty ? 1 : 0,
                 itemBuilder: (context, i) {
                   final payment = payments[i];
                   return Consumer<PostponeService>(
                     builder: (context, postponeService, _) {
                       return _buildPaymentCard(context, payment, postponeService, l10n, isRTL);
                     },
                   );
                 },
               ),

        // مسافة سفلية مريحة
        SliverToBoxAdapter(child: SizedBox(height: bottomSafe + 32)),
      ],
    ));
  }

  Widget _buildPaymentCard(
    BuildContext context,
    Map<String, dynamic> payment,
    PostponeService postponeService,
    AppLocalizations l10n,
    bool isRTL,
  ) {
    // Backend returns merchantName, storeName, or storeNameAr
    final storeName = isRTL 
        ? (payment['storeNameAr']?.toString() ?? payment['merchantName']?.toString() ?? payment['storeName']?.toString() ?? payment['store']?['nameAr']?.toString() ?? payment['store']?['name']?.toString() ?? 'متجر')
        : (payment['storeName']?.toString() ?? payment['merchantName']?.toString() ?? payment['store']?['name']?.toString() ?? 'Store');
    final amountValue = payment['amount'];
    final amount = amountValue is num 
        ? amountValue.toDouble() 
        : (double.tryParse(amountValue.toString()) ?? 0.0);
    final installmentNumber = payment['installmentNumber'] as int? ?? 1;
    final installmentsCount = payment['installmentsCount'] as int? ?? 1;
    final paymentId = payment['id'] as int?;
    
    // Use postponedDueDate if payment is postponed, otherwise use dueDate
    final isPostponed = payment['isPostponed'] == true;
    final dueDateStr = isPostponed && payment['postponedDueDate'] != null
        ? payment['postponedDueDate'].toString()
        : payment['dueDate']?.toString();
    
    // Calculate due days
    int dueDays = 0;
    String dueTextKey = 'dueInDays';
    if (dueDateStr != null) {
      try {
        final dueDate = DateTime.parse(dueDateStr);
        dueDays = dueDate.difference(DateTime.now()).inDays;
        if (dueDays < 0) {
          dueTextKey = 'overdueDays';
          dueDays = dueDays.abs();
        } else if (dueDays == 0) {
          dueTextKey = 'dueToday';
        } else {
          dueTextKey = 'dueInDays';
        }
      } catch (e) {
        // Invalid date
      }
    }
    
    
    final installmentId = '${paymentId}_${installmentNumber}';
    
    // User can postpone for free if:
    // 1. This payment is NOT already postponed, AND
    // 2. User has NOT used their one-time free postponement
    final canPostpone = !isPostponed && !userFreePostponeUsed;
    
    // Debug logging
    print('🔍 [canPostpone Check]');
    print('   Payment ID: $paymentId');
    print('   isPostponed: $isPostponed');
    print('   userFreePostponeUsed: $userFreePostponeUsed');
    print('   canPostpone: $canPostpone');
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: _BillCard(
        merchant: storeName,
        amount: amount,
        dueTextKey: dueTextKey,
        cycleTextKey: 'installmentOf',
        icon: Icons.store_rounded,
        onPay: () => _showPaymentMethod(context, amount, paymentId),
        onExtend: () => _showExtendDueDate(context, storeName, amount, dueDateStr ?? '', paymentId),
        onFreePostpone: canPostpone ? () => _showFreePostpone(context, payment, storeName, amount, onRefresh) : null,
        freePostponeAvailable: canPostpone,
        l10n: l10n,
        isRTL: isRTL,
        dueDays: dueDays,
        currentInstallment: installmentNumber,
        totalInstallments: installmentsCount,
      ),
    );
  }
  void _showPaymentMethod(BuildContext context, double amount, int? paymentId) {
    PaymentMethodSheet.show(
      context,
      amountLabel: 'JD ${amount.toStringAsFixed(3)}',
      onApplePay: () => _initiatePaymentFlow(context, amount),
      onCardAdded: (card) {
        // For now, treating "Add Card" as "Pay with Card"
        // In a real app, we would tokenize the card first
        print('تمت إضافة بطاقة جديدة: ${card.last4}');
        Navigator.pop(context); // Close sheet if open
        _initiatePaymentFlow(context, amount);
      },
    );
  }

  Future<void> _initiatePaymentFlow(BuildContext context, double amount) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Use mock payment URL (same as session confirmation)
      final ngrokUrl = 'http://localhost:3000'; // Replace with your ngrok URL if needed
      final url = '$ngrokUrl/api/v1/payments/mock-payment?amount=$amount';
      
      // Hide loading
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebViewPage(
              paymentUrl: url,
              sessionId: 'payment_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        );

        // For mock payments, always assume success
        if (context.mounted) {
          await _handleSuccessfulPayment(context, amount);
          onRefresh();
        }
      }
    } catch (e) {
      // Hide loading if showing
      if (context.mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }
      // We can't easily check if dialog is showing, but usually it's popped above
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// معالجة عملية دفع ناجحة وإضافة النقاط
  Future<void> _handleSuccessfulPayment(BuildContext context, double amount) async {
    final l10n = AppLocalizations.of(context)!;
    final pointsService = Provider.of<PointsService>(context, listen: false);
    
    try {
      // إضافة النقاط من عملية الدفع
      final pointsEarned = await pointsService.addPointsFromPayment(
        paymentAmount: amount,
        description: 'دفع مستحق JD ${amount.toStringAsFixed(3)}',
      );
      
      // عرض رسالة نجاح مع النقاط المكتسبة
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      l10n.paymentSuccessfulApplePay,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                if (pointsEarned > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.earnedPointsMessage(pointsEarned),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error handling payment: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentSuccessfulApplePay),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    }
  }

  void _showExtendDueDate(BuildContext context, String merchantName, double amount, String dueDate, int? paymentId) {
    // Sample extend options - you can customize these based on your business logic
    final options = [
      ExtendOption(
        days: 7,
        feeLabel: 'JD 0.500',
        targetDateLabel: 'مُمدّد إلى ${dueDate}',
      ),
      ExtendOption(
        days: 14,
        feeLabel: 'JD 0.950',
        targetDateLabel: 'مُمدّد إلى ${dueDate}',
        popular: true,
      ),
      ExtendOption(
        days: 30,
        feeLabel: 'JD 1.500',
        targetDateLabel: 'مُمدّد إلى ${dueDate}',
      ),
    ];

    ExtendDueDateSheet.show(
      context,
      merchantName: merchantName,
      originalAmountLabel: 'JD ${amount.toStringAsFixed(3)}',
      originalDueLabel: dueDate,
      options: options,
      onConfirm: (selectedOption) async {
        if (paymentId != null) {
          try {
            final paymentService = PaymentService();
            final response = await paymentService.extendDueDate(
              paymentId: paymentId,
              extensionDays: selectedOption.days,
            );
            if (response['success'] == true) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تمديد تاريخ الاستحقاق بنجاح'),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
                // Refresh payments list
                onRefresh();
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response['error']?.toString() ?? 'فشل تمديد التاريخ'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('حدث خطأ: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تمديد تاريخ الاستحقاق بنجاح'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
      },
    );
  }

  void _showFreePostpone(BuildContext context, Map<String, dynamic> payment, String storeName, double amount, VoidCallback onRefresh) async {
    final l10n = AppLocalizations.of(context)!;
    final postponeService = Provider.of<PostponeService>(context, listen: false);
    
    final paymentId = payment['id'] as int?;
    final installmentNumber = payment['installmentNumber'] as int? ?? 1;
    final installmentId = '${paymentId}_${installmentNumber}';
    
    // حساب التواريخ
    final dueDateStr = payment['dueDate']?.toString();
    DateTime currentDue;
    if (dueDateStr != null) {
      try {
        currentDue = DateTime.parse(dueDateStr);
      } catch (e) {
        currentDue = DateTime.now().add(const Duration(days: 7));
      }
    } else {
      currentDue = DateTime.now().add(const Duration(days: 7));
    }
    final newDue = currentDue.add(const Duration(days: 30)); // Free postponement: 30 days
    
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    
    final currentDueStr = '${currentDue.day} ${months[currentDue.month - 1]} ${currentDue.year}';
    final newDueStr = '${newDue.day} ${months[newDue.month - 1]} ${newDue.year}';
    
    FreePostponeSheet.show(
      context,
      merchantName: storeName,
      amount: amount,
      currentDueDate: currentDueStr,
      newDueDate: newDueStr,
      onConfirm: () async {
        if (paymentId != null) {
          try {
            final paymentService = PaymentService();
            final response = await paymentService.postponePayment(
              paymentId: paymentId,
              daysToPostpone: 30,
            );
            
            if (response['success'] == true && context.mounted) {
              // Refresh payments to get updated data from backend
              print('🔄 [Before onRefresh]');
              print('   response success: ${response['success']}');
              print('   context.mounted: ${context.mounted}');
              
              onRefresh();
              
              print('✅ [After onRefresh called]');
              
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(l10n.postponeSuccess),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response['error']?.toString() ?? 'فشل التأجيل'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('حدث خطأ: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Fallback if paymentId is null
          final success = await postponeService.postponeForFree(
            installmentId,
            merchantName: storeName,
            amount: amount,
            originalDueDate: currentDueStr,
            newDueDate: newDueStr,
          );
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l10n.postponeSuccess),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF16A34A),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }
}

/// بطاقة ملخص زجاجية بنعومة
class _SummaryCard extends StatelessWidget {
  final double dueIn30;
  final double dueIn7;
  final double total;
  final AppLocalizations l10n;
  final List<Map<String, dynamic>> payments;

  const _SummaryCard({
    required this.dueIn30,
    required this.dueIn7,
    required this.total,
    required this.l10n,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withValues(alpha: 0.7),
            border: Border.all(color: BNPLColors.stroke),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => PayDuesSheet.show(context, payments: payments),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: BNPLColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.pie_chart, color: BNPLColors.accent),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l10n.dueIn30Days, 
                        style: const TextStyle(
                          color: BNPLColors.subtext, 
                          fontWeight: FontWeight.w700
                        )
                      ),
                      Text('JD ${dueIn30.toStringAsFixed(3)}',
                          style: const TextStyle(
                            fontSize: 26, 
                            fontWeight: FontWeight.w900, 
                            color: BNPLColors.text
                          )
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _metric(l10n.totalAmountDue, 'JD ${total.toStringAsFixed(3)}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metric(l10n.dueIn7Days, 'JD ${dueIn7.toStringAsFixed(3)}', alignEnd: true),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // شريط تقدّم بسيط يوحي بالدورات (ديكور بسيط)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: .6,
                  backgroundColor: const Color(0xFFEFF3F8),
                  valueColor: AlwaysStoppedAnimation(BNPLColors.primary.withValues(alpha: 0.9)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String title, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title, 
          style: const TextStyle(
            color: BNPLColors.subtext, 
            fontWeight: FontWeight.w700
          )
        ),
        const SizedBox(height: 4),
        Text(value, 
          style: const TextStyle(
            color: BNPLColors.text, 
            fontWeight: FontWeight.w900
          )
        ),
      ],
    );
  }
}

/// زر سريع ناعم
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppLocalizations l10n;
  final VoidCallback? onTap;
  
  const _QuickAction({
    required this.icon, 
    required this.label,
    required this.l10n,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BNPLColors.stroke),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: BNPLColors.text),
            const SizedBox(width: 10),
            Text(label, 
              style: const TextStyle(
                fontWeight: FontWeight.w800, 
                color: BNPLColors.text
              )
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة فاتورة هادئة ومريحة
class _BillCard extends StatelessWidget {
  final String merchant;
  final double amount;
  final String dueTextKey;
  final String cycleTextKey;
  final IconData icon;
  final VoidCallback onPay;
  final VoidCallback onExtend;
  final VoidCallback? onFreePostpone;
  final bool freePostponeAvailable;
  final AppLocalizations l10n;
  final bool isRTL;
  final int dueDays;
  final int currentInstallment;
  final int totalInstallments;

  const _BillCard({
    required this.merchant,
    required this.amount,
    required this.dueTextKey,
    required this.cycleTextKey,
    required this.icon,
    required this.onPay,
    required this.onExtend,
    this.onFreePostpone,
    this.freePostponeAvailable = false,
    required this.l10n,
    required this.isRTL,
    this.dueDays = 0,
    this.currentInstallment = 4,
    this.totalInstallments = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: BNPLColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BNPLColors.stroke),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // المبلغ
              Text('JD ${amount.toStringAsFixed(3)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900, 
                    color: BNPLColors.text
                  )
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  merchant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800, 
                    color: BNPLColors.text
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: BNPLColors.subtext, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
             children: [
               Expanded(
                 child: Text(
                   _getDueText(),
                   style: const TextStyle(
                     color: BNPLColors.accent, 
                     fontWeight: FontWeight.w700
                   ),
                 ),
               ),
               Text(
                 _getCycleText(),
                 style: const TextStyle(
                   color: BNPLColors.subtext, 
                   fontWeight: FontWeight.w700
                 ),
               ),
             ],
           ),

          // Badge التأجيل المجاني إذا كان متاحاً
          if (freePostponeAvailable) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF4E6), Color(0xFFFFFBEB)],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFEF3C7),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    size: 14,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.oneTimeFreePostpone,
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // الأزرار
          if (freePostponeAvailable && onFreePostpone != null)
            // عرض زر التأجيل المجاني بشكل بارز
            Column(
              children: [
                _softButton(
                  label: l10n.postponeForFree,
                  onTap: onFreePostpone!,
                  special: true,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _softButton(
                        label: l10n.pay,
                        onTap: onPay,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _softButton(
                        label: l10n.extend,
                        onTap: onExtend,
                        gray: true,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            // عرض الأزرار العادية فقط
            Row(
              children: [
                Expanded(
                  child: _softButton(
                    label: l10n.pay,
                    onTap: onPay,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _softButton(
                    label: l10n.extend,
                    onTap: onExtend,
                    gray: true,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _softButton({
    required String label, 
    required VoidCallback onTap, 
    bool gray = false, 
    bool special = false,
  }) {
    // لون خاص للتأجيل المجاني
    final bg = special 
        ? const LinearGradient(
            colors: [Color(0xFFFFF4E6), Color(0xFFFFFBEB)],
          )
        : null;
    final solidBg = !special 
        ? (gray ? const Color(0xFFF2F5F9) : BNPLColors.primary.withValues(alpha: 0.1))
        : null;
    final txt = special 
        ? const Color(0xFFF59E0B) 
        : (gray ? BNPLColors.text : BNPLColors.primary);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: bg,
          color: solidBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: special ? const Color(0xFFFEF3C7) : BNPLColors.stroke,
            width: special ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (special)
              const Padding(
                padding: EdgeInsets.only(left: 6, right: 6),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 18,
                  color: Color(0xFFF59E0B),
                ),
              ),
            Text(
              label, 
              style: TextStyle(
                fontWeight: FontWeight.w800, 
                color: txt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDueText() {
    switch (dueTextKey) {
      case 'dueTomorrow':
        return l10n.dueTomorrow;
      case 'dueInDays':
        return l10n.dueInDays(dueDays);
      default:
        return dueTextKey;
    }
  }

  String _getCycleText() {
    if (cycleTextKey == 'installmentOf') {
      return l10n.installmentOf(currentInstallment, totalInstallments);
    }
    return cycleTextKey;
  }
}

