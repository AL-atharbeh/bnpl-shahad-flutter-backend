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
import '../../../../services/saved_cards_service.dart';
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
    // Prefetch saved cards so they appear instantly when clicking Pay
    SavedCardsService().getCards();
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
      final response = await _paymentService.getPendingPayments(nextOnly: true);
      
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

  void _showPaymentMethod(BuildContext context, double amount, int? paymentId) {
    if (paymentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في رقم الدفعة')),
      );
      return;
    }

    PaymentMethodSheet.show(
      context,
      amountLabel: 'JD ${amount.toStringAsFixed(3)}',
      amount: amount,
      paymentId: paymentId,
      onApplePay: () => _initiatePaymentFlow(context, amount, paymentId, isApplePay: true),
      onCardAdded: (card) {
        _initiatePaymentFlow(context, amount, paymentId, isApplePay: false);
      },
      onPaymentSuccess: () {
        _handleSuccessfulPayment(context, amount);
        _loadPayments();
      },
    );
  }

  Future<void> _initiatePaymentFlow(BuildContext context, double amount, int paymentId, {bool isApplePay = false}) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      String? paymentUrl;
      
      if (isApplePay) {
        // Fallback or specific Apple Pay logic if needed
        final response = await _paymentService.getStripeInstallmentUrl(paymentId);
        if (response['success'] == true && response['data'] != null && response['data']['url'] != null) {
          paymentUrl = response['data']['url'];
        } else if (response['url'] != null) {
          paymentUrl = response['url'];
        }
      } else {
        // Real Stripe flow
        final response = await _paymentService.getStripeInstallmentUrl(paymentId);
        
        var data = response;
        if (response['success'] == true && response['data'] != null) {
          data = response['data'];
        }

        if (data['success'] == true && data['url'] != null) {
          paymentUrl = data['url'];
        } else if (data['url'] != null) {
          paymentUrl = data['url'];
        }
      }

      // Hide loading
      if (context.mounted) Navigator.pop(context);

      if (paymentUrl == null) {
        throw 'فشل الحصول على رابط الدفع';
      }

      if (context.mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebViewPage(
              paymentUrl: paymentUrl!,
              sessionId: 'payment_$paymentId',
            ),
          ),
        );

        // Check result from WebView
        if (result == true) {
          if (context.mounted) {
            await _handleSuccessfulPayment(context, amount);
            _loadPayments(); // Refresh list
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }
      
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
  
  Future<void> _handleSuccessfulPayment(BuildContext context, double amount) async {
    final l10n = AppLocalizations.of(context)!;
    final pointsService = Provider.of<PointsService>(context, listen: false);
    
    try {
      final pointsEarned = await pointsService.addPointsFromPayment(
        paymentAmount: amount,
        description: 'دفع مستحق JD ${amount.toStringAsFixed(3)}',
      );
      
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
            backgroundColor: AppColors.primary,
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
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _showExtendDueDate(BuildContext context, String merchantName, double amount, String dueDate, int? paymentId) async {
    if (paymentId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    bool dialogShowing = false;

    try {
      // Show loading
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (dialogCtx) {
          dialogShowing = true;
          return const Center(child: CircularProgressIndicator());
        }
      ).then((_) => dialogShowing = false);
      
      final response = await _paymentService.getExtensionOptions();
      
      // Safe pop for loading dialog - ONLY if it's actually showing
      if (context.mounted && dialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShowing = false;
      }

      if (response['success'] == true) {
        final backendResponse = response['data'];
        List<dynamic> optionsData = [];
        
        if (backendResponse is Map) {
          optionsData = backendResponse['data'] ?? [];
        } else if (backendResponse is List) {
          optionsData = backendResponse;
        }

        if (optionsData.isEmpty) {
          messenger.showSnackBar(const SnackBar(content: Text('لا توجد خيارات تمديد متاحة حالياً')));
          return;
        }

        final List<ExtendOption> options = optionsData.map((opt) {
          return ExtendOption(
            id: opt['id'],
            days: opt['days'],
            fee: double.tryParse(opt['fee'].toString()),
            feeLabel: 'JD ${opt['fee']}',
            targetDateLabel: 'مُمدّد إلى $dueDate', 
            popular: opt['isPopular'] == true,
          );
        }).toList();

        if (context.mounted) {
          // Add a tiny delay to ensure the dialog pop animation doesn't interfere with the sheet
          await Future.delayed(const Duration(milliseconds: 100));
          if (!context.mounted) return;

          ExtendDueDateSheet.show(
            context,
            merchantName: merchantName,
            originalAmountLabel: 'JD ${amount.toStringAsFixed(3)}',
            originalDueLabel: dueDate,
            options: options,
            onConfirm: (option) => _handleExtendConfirm(context, paymentId, option),
          );
        }
      } else {
        throw response['error'] ?? 'فشل تحميل خيارات التمديد';
      }
    } catch (e) {
      if (context.mounted) {
        if (dialogShowing) {
          try { Navigator.of(context, rootNavigator: true).pop(); } catch (_) {}
        }
        messenger.showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  Future<void> _handleExtendConfirm(BuildContext context, int? paymentId, ExtendOption option) async {
    if (paymentId == null || option.id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    bool dialogShowing = false;

    try {
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (dialogCtx) {
          dialogShowing = true;
          return const Center(child: CircularProgressIndicator());
        }
      ).then((_) => dialogShowing = false);
      
      final response = await _paymentService.initiatePaidExtension(
        paymentId: paymentId,
        optionId: option.id!,
      );
      
      if (context.mounted && dialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShowing = false;
      }
      
      if (response['success'] == true && response['data'] != null) {
        final backendResponse = response['data'];
        String? paymentUrl;
        
        if (backendResponse is Map && backendResponse['data'] != null && backendResponse['data']['url'] != null) {
          paymentUrl = backendResponse['data']['url'];
        } else if (backendResponse is Map && backendResponse['url'] != null) {
          paymentUrl = backendResponse['url'];
        }
        
        if (paymentUrl != null) {
          if (context.mounted) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentWebViewPage(
                  paymentUrl: paymentUrl!,
                  sessionId: 'extension_$paymentId',
                ),
              ),
            );

            if (result == true) {
              _loadPayments(); // Refresh list after successful payment
            }
          }
        }
      } else {
        throw response['error'] ?? 'فشل بدء عملية الدفع';
      }
    } catch (e) {
      if (context.mounted) {
        if (dialogShowing) {
          try { Navigator.of(context, rootNavigator: true).pop(); } catch (_) {}
        }
        messenger.showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  void _showFreePostpone(BuildContext context, Map<String, dynamic> payment, String storeName, double amount, VoidCallback onRefresh) async {
    final l10n = AppLocalizations.of(context)!;
    final postponeService = Provider.of<PostponeService>(context, listen: false);
    
    final paymentId = payment['id'] as int?;
    
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
            showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
            final response = await _paymentService.postponePayment(
              paymentId: paymentId,
              daysToPostpone: 30,
            );
            if (context.mounted) Navigator.pop(context);
            
            if (response['success'] == true && context.mounted) {
              onRefresh();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.postponeSuccess)),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
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
               try { Navigator.pop(context); } catch (_) {}
            }
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
      },
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    Map<String, dynamic> payment,
    PostponeService postponeService,
    AppLocalizations l10n,
    bool isRTL,
  ) {
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
    
    final isPostponed = payment['isPostponed'] == true;
    final dueDateStr = isPostponed && payment['postponedDueDate'] != null
        ? payment['postponedDueDate'].toString()
        : payment['dueDate']?.toString();
    
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
      } catch (e) { }
    }
    
    final canPostpone = !isPostponed && !_userFreePostponeUsed;
    
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
        onFreePostpone: canPostpone ? () => _showFreePostpone(context, payment, storeName, amount, _loadPayments) : null,
        freePostponeAvailable: canPostpone,
        l10n: l10n,
        isRTL: isRTL,
        dueDays: dueDays,
        currentInstallment: installmentNumber,
        totalInstallments: installmentsCount,
      ),
    );
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
        itemBuilder: (context, payment, postponeService) => _buildPaymentCard(context, payment, postponeService, l10n, isRTL),
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
  final Widget Function(BuildContext, Map<String, dynamic>, PostponeService) itemBuilder;
  
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
    required this.itemBuilder,
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
                 itemCount: payments.length,
                 itemBuilder: (context, i) {
                   final payment = payments[i];
                   return Consumer<PostponeService>(
                     builder: (context, postponeService, _) {
                       return itemBuilder(context, payment, postponeService);
                     },
                   );
                 },
               ),

        // مسافة سفلية كبيرة لضمان ظهور المحتوى فوق شريط التنقل العائم
        SliverToBoxAdapter(child: SizedBox(height: bottomSafe + 110)),
      ],
    ));
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E293B), // Slate 800
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.totalAmountDue,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JD ${total.toStringAsFixed(3)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _metricV2(l10n.dueIn7Days, 'JD ${dueIn7.toStringAsFixed(3)}', const Color(0xFFFACC15)), // Yellow 400
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _metricV2(l10n.dueIn30Days, 'JD ${dueIn30.toStringAsFixed(3)}', const Color(0xFF4ADE80)), // Green 400
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricV2(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// بطاقة تفاعلية سريعة
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00A66A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF00A66A), size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, 
              style: const TextStyle(
                fontWeight: FontWeight.w800, 
                fontSize: 14,
                color: Color(0xFF1E293B)
              )
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة فاتورة فاخرة بتصميم عصري
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
    // Status color logic
    Color statusColor;
    if (dueTextKey == 'overdueDays') {
      statusColor = const Color(0xFFEF4444); // Red 500
    } else if (dueDays <= 3) {
      statusColor = const Color(0xFFF97316); // Orange 500
    } else {
      statusColor = const Color(0xFF00A66A); // BNPL Custom Green
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status sidebar
              Container(width: 6, color: statusColor),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Merchant & Icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: const Color(0xFF475569), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  merchant,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  _getCycleText(),
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'JD ${amount.toStringAsFixed(3)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                _getDueText(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      if (freePostponeAvailable) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: Color(0xFFEA580C), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                l10n.oneTimeFreePostpone,
                                style: const TextStyle(
                                  color: Color(0xFFEA580C),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // Actions
                      Row(
                        children: [
                          // Pay Button (Primary)
                          Expanded(
                            flex: 2,
                            child: _actionButton(
                              label: l10n.pay,
                              onTap: onPay,
                              color: const Color(0xFF00A66A),
                              isPrimary: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Extend Button
                          Expanded(
                            flex: 1,
                            child: _actionButton(
                              label: l10n.extend,
                              onTap: onExtend,
                              color: const Color(0xFF1E293B),
                              isPrimary: false,
                            ),
                          ),
                          if (freePostponeAvailable && onFreePostpone != null) ...[
                             const SizedBox(width: 10),
                             GestureDetector(
                               onTap: onFreePostpone,
                               child: Container(
                                 padding: const EdgeInsets.all(12),
                                 decoration: BoxDecoration(
                                   color: const Color(0xFFFFF7ED),
                                   borderRadius: BorderRadius.circular(14),
                                   border: Border.all(color: const Color(0xFFFED7AA)),
                                 ),
                                 child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFEA580C), size: 20),
                               ),
                             ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isPrimary ? Colors.transparent : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : color,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
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
      case 'overdueDays':
        return isRTL ? 'متأخر منذ $dueDays يوم' : 'Overdue $dueDays days';
      case 'dueToday':
        return l10n.today;
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

