import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../services/payment_service.dart';

class PaymentsHistoryPage extends StatefulWidget {
  const PaymentsHistoryPage({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaymentsHistoryPage(),
      ),
    );
  }

  @override
  State<PaymentsHistoryPage> createState() => _PaymentsHistoryPageState();
}

class _PaymentsHistoryPageState extends State<PaymentsHistoryPage> {
  final _paymentService = PaymentService();
  DateTimeRange? _selectedDateRange;
  bool _isLoading = true;
  List<_Hist> _dbHistories = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _paymentService.getPaymentHistory(status: 'completed');
      
      if (response['success'] == true) {
        final backendData = response['data'];
        List<dynamic> data = [];
        
        if (backendData is Map && backendData['data'] is List) {
          data = backendData['data'];
        } else if (backendData is List) {
          data = backendData;
        }

        setState(() {
          _dbHistories = data.map((item) {
            // Safe parsing of date
            DateTime date = DateTime.now();
            String? dateStr = item['paidAt'] ?? item['createdAt'];
            
            if (dateStr != null) {
              try {
                // Handle formats like "2026-03-24 15:15:15" by replacing space with T
                String formattedDate = dateStr.contains(' ') && !dateStr.contains('T')
                    ? dateStr.replaceFirst(' ', 'T')
                    : dateStr;
                date = DateTime.parse(formattedDate);
              } catch (e) {
                debugPrint('Failed to parse date: $dateStr');
              }
            }

            return _Hist(
              merchant: item['merchantName'] ?? item['storeName'] ?? 'متجر',
              amount: double.tryParse(item['amount'].toString()) ?? 0.0,
              statusKey: 'paid',
              date: date,
              icon: Icons.store_mall_directory_rounded,
              color: Colors.green,
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading payment history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<_Hist> get _filteredHistories {
    return _dbHistories.where((hist) {
      // فلترة حسب التاريخ فقط
      if (_selectedDateRange != null) {
        return hist.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
               hist.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }
      
      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date)); // ترتيب من الأحدث للأقدم
  }

  Map<String, List<_Hist>> get _groupedHistories {
    final grouped = <String, List<_Hist>>{};
    
    for (final hist in _filteredHistories) {
      final key = _getDateGroupKey(hist.date);
      grouped[key] = (grouped[key] ?? [])..add(hist);
    }
    
    return grouped;
  }

  String _getDateGroupKey(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final isArabic = languageService.isArabic;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final histDate = DateTime(date.year, date.month, date.day);
    
    if (histDate == today) {
      return l10n.today;
    } else if (histDate == yesterday) {
      return l10n.yesterday;
    } else if (histDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return l10n.thisWeek;
    } else if (histDate.isAfter(today.subtract(const Duration(days: 30)))) {
      return l10n.thisMonth;
    } else {
      return DateFormat('MMMM yyyy', isArabic ? 'ar' : 'en').format(date);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Directionality(
          textDirection: Directionality.of(context),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.paymentsHistory,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF111827)),
        ),
      ),
      body: Column(
        children: [
          // فلترة التاريخ
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6ECF3)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dateFilter,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFF6B7280)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedDateRange != null
                                ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
                                : l10n.selectTimeRange,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),



          // قائمة السجل مجمعة حسب التاريخ
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A66A)))
                : _filteredHistories.isEmpty
                                 ? Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(
                           Icons.history_rounded,
                           size: 64,
                           color: Color(0xFF6B7280),
                         ),
                         const SizedBox(height: 16),
                         Text(
                           l10n.noPaidTransactions,
                           style: const TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.w700,
                             color: Color(0xFF6B7280),
                           ),
                         ),
                       ],
                     ),
                   )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _groupedHistories.keys.length,
                    itemBuilder: (context, index) {
                      final dateGroup = _groupedHistories.keys.elementAt(index);
                      final histories = _groupedHistories[dateGroup]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // عنوان المجموعة
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00A66A),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  dateGroup,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${histories.length} ${histories.length == 1 ? l10n.transaction : l10n.transactions}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // قائمة المعاملات في هذه المجموعة
                          ...histories.map((hist) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HistoryCard(hist: hist),
                          )),
                          
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final _Hist hist;
  
  const _HistoryCard({required this.hist});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6ECF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة المتجر
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00A66A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(hist.icon, color: const Color(0xFF00A66A), size: 24),
          ),
          const SizedBox(width: 16),
          
          // تفاصيل المعاملة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hist.merchant,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(hist.date),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // المبلغ فقط
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'JD ${hist.amount.toStringAsFixed(3)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A66A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.paid,
                  style: const TextStyle(
                    color: Color(0xFF00A66A),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hist {
  final String merchant;
  final double amount;
  final String statusKey;
  final DateTime date;
  final IconData icon;
  final Color color;

  _Hist({
    required this.merchant,
    required this.amount,
    required this.statusKey,
    required this.date,
    required this.icon,
    required this.color,
  });
}
