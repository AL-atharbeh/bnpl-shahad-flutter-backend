import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../routing/app_router.dart';
import '../../../../services/points_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/saved_cards_service.dart';

/// صفحة البروفايل (للاستعراض)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // تهيئة خدمة النقاط من السيرفر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PointsService>(context, listen: false).initialize();
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await authService.getProfile();

      if (response['success']) {
        // Backend يعيد: { success: true, data: { user: {...} } }
        // api_service يضع الكل في response['data']
        final backendResponse = response['data'];
        final innerData = backendResponse?['data'] ?? backendResponse;
        final user = innerData?['user'] ?? innerData;

        setState(() {
          _userData = user;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['error'] ?? 'فشل تحميل الملف الشخصي';
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

  // Handle logout
  void _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Get AuthService from provider
        final authService = Provider.of<AuthService>(context, listen: false);
        
        // Simulate logout process
        await Future.delayed(const Duration(seconds: 1));
        
        // Clear login state locally
        print('🗑️ Clearing login state in profile page...');
        await authService.clearLoginState();
        print('✅ Login state cleared, navigating to login...');
        
        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
          
          // Navigate to phone input page
          AppRouter.navigateToPhoneInput(context);
        }
      } catch (e) {
        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.myAccount,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _PointsIconButton(),
        ),
        actions: [
          // أيقونة الإشعارات
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => AppRouter.navigateToNotifications(context),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
             body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      _AvatarAndName(
                        name: _userData?['name'] ?? 'المستخدم',
                        avatarUrl: _userData?['avatarUrl']?.toString(),
                      ),
                      const SizedBox(height: 16),
            
            PaymentCardsCarousel(), // <-- قسم وسائل الدفع الجديد
            const SizedBox(height: 24),
            _SettingItem(
              title: l10n.personalData, 
              icon: Icons.person_outline_rounded,
              onTap: () async {
                // الانتقال لصفحة البيانات الشخصية وانتظار النتيجة
                await Navigator.pushNamed(context, AppRouter.personalData);
                // إعادة تحميل البيانات بعد العودة
                _loadUserProfile();
              },
            ),
            _SettingItem(
              title: l10n.contactUs, 
              icon: Icons.support_agent,
              onTap: () => AppRouter.navigateToContactUs(context),
            ),
            _SettingItem(
              title: l10n.privacyAndSecurity, 
              icon: Icons.lock_outline_rounded,
              onTap: () => AppRouter.navigateToPrivacySecurity(context),
            ),
                         _SettingItem(
              title: l10n.language,
              icon: Icons.public_rounded,
              onTap: () => AppRouter.navigateToLanguage(context),
            ),
            _SettingItem(
              title: l10n.bnplForBusiness,
              icon: Icons.business_rounded,
              onTap: () => AppRouter.navigateToBNPLBusiness(context),
            ),
             const SizedBox(height: 32),
           
           // زر تسجيل الخروج
           Center(
             child: Container(
               width: 120,
               height: 40,
               decoration: BoxDecoration(
                 color: const Color(0xFFFFF5F5),
                 borderRadius: BorderRadius.circular(20),
                 border: Border.all(
                   color: const Color(0xFFFEE2E2),
                   width: 1,
                 ),
               ),
               child: Material(
                 color: Colors.transparent,
                 child: InkWell(
                   borderRadius: BorderRadius.circular(20),
                   onTap: () => _handleLogout(context),
                   child: Center(
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(
                           Icons.logout_rounded,
                           size: 18,
                           color: const Color(0xFFDC2626),
                         ),
                         const SizedBox(width: 6),
                         Text(
                           l10n.logout,
                           style: TextStyle(
                             fontFamily: 'Mada',
                             fontSize: 14,
                             fontWeight: FontWeight.w600,
                             color: const Color(0xFFDC2626),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
             ),
                        ),
             
             const SizedBox(height: 24),
           
           // رسالة شكر جميلة
           Container(
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: const Color(0xFFF8FAFC),
               borderRadius: BorderRadius.circular(16),
               border: Border.all(
                 color: const Color(0xFFE2E8F0),
                 width: 1,
               ),
             ),
             child: Column(
               children: [
                 Text(
                   l10n.youHonoredUs,
                   style: TextStyle(
                     fontFamily: 'Changa',
                     fontSize: 18,
                     fontWeight: FontWeight.w700,
                     color: const Color(0xFF1E293B),
                   ),
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 8),
                 Text(
                   _formatJoinDate(_userData?['createdAt']),
                   style: TextStyle(
                     fontFamily: 'Mada',
                     fontSize: 14,
                     fontWeight: FontWeight.w500,
                     color: const Color(0xFF64748B),
                   ),
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 12),
                 Text(
                   l10n.thankYouMessage,
                   style: TextStyle(
                     fontFamily: 'Mada',
                     fontSize: 13,
                     fontWeight: FontWeight.w400,
                     color: const Color(0xFF64748B),
                     height: 1.5,
                   ),
                   textAlign: TextAlign.center,
                 ),
               ],
             ),
                        ),
             
             // مساحة إضافية في الأسفل للتمرير
             const SizedBox(height: 100),
         ],
       ),
      ),
    );
  }

  String _formatJoinDate(dynamic createdAt) {
    if (createdAt == null) return 'تاريخ الانضمام غير متاح';
    
    try {
      DateTime date;
      if (createdAt is String) {
        date = DateTime.parse(createdAt);
      } else if (createdAt is DateTime) {
        date = createdAt;
      } else {
        return 'تاريخ الانضمام غير متاح';
      }
      
      final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                     'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
      return 'انضم في ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'تاريخ الانضمام غير متاح';
    }
  }
}

// ---------------- واجهة أعلى الصفحة ----------------
class _AvatarAndName extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  const _AvatarAndName({required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? _buildAvatarImage(avatarUrl!)
              : CircleAvatar(
                  backgroundColor: const Color(0xFFEFF3F8),
                  child: Icon(Icons.person,
                      size: 56, color: const Color(0xFF111827).withOpacity(.35)),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage(String url) {
    // إذا كانت الصورة Base64 (تبدأ بـ data:image)
    if (url.startsWith('data:image')) {
      try {
        // استخراج Base64 string
        final base64String = url.split(',')[1];
        final imageBytes = base64Decode(base64String);
        return ClipOval(
          child: Image.memory(
            imageBytes,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => CircleAvatar(
              backgroundColor: const Color(0xFFEFF3F8),
              child: Icon(Icons.person,
                  size: 56, color: const Color(0xFF111827).withOpacity(.35)),
            ),
          ),
        );
      } catch (e) {
        // إذا فشل تحويل Base64، استخدم الصورة الافتراضية
        return CircleAvatar(
          backgroundColor: const Color(0xFFEFF3F8),
          child: Icon(Icons.person,
              size: 56, color: const Color(0xFF111827).withOpacity(.35)),
        );
      }
    } else {
      // إذا كانت URL عادية
      return ClipOval(
        child: Image.network(
          url,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => CircleAvatar(
            backgroundColor: const Color(0xFFEFF3F8),
            child: Icon(Icons.person,
                size: 56, color: const Color(0xFF111827).withOpacity(.35)),
          ),
        ),
      );
    }
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  const _SettingItem({
    required this.title, 
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6ECF3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // الأيقونة على اليمين (في العربية)
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F4F7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF111827)),
                ),
                const SizedBox(width: 12),
                // النص في الوسط
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                      fontSize: 16,
                    ),
                  ),
                ),
                // السهم على اليسار (في العربية)
                Icon(
                  isRTL ? Icons.chevron_left : Icons.chevron_right,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================
// =============== وسائل الدفع (الكروت) ===============
// ===================================================

class PaymentCardData {
  final int? id;
  final String holder;
  final String masked;
  final String balance; 
  final String validThru; 
  final String brand;
  final bool isDefault;

  PaymentCardData({
    this.id,
    required this.holder,
    required this.masked,
    required this.balance,
    required this.validThru,
    this.brand = 'mastercard',
    this.isDefault = false,
  });

  factory PaymentCardData.fromMap(Map<String, dynamic> map) {
    final expMonth = map['expMonth']?.toString().padLeft(2, '0') ?? '00';
    final expYear = map['expYear']?.toString().substring(map['expYear']?.toString().length == 4 ? 2 : 0) ?? '00';
    
    return PaymentCardData(
      id: map['id'],
      holder: map['cardholderName'] ?? 'بطاقة دفع',
      masked: '•••• •••• •••• ${map['last4']}',
      balance: 'JOD 0.00', // Actual balance is not stored on Stripe for credit cards
      validThru: '$expMonth/$expYear',
      brand: (map['brand']?.toString().toLowerCase() ?? 'mastercard'),
      isDefault: map['isDefault'] ?? false,
    );
  }
}

class PaymentCardsCarousel extends StatefulWidget {
  const PaymentCardsCarousel({super.key});

  @override
  State<PaymentCardsCarousel> createState() => _PaymentCardsCarouselState();
}

class _PaymentCardsCarouselState extends State<PaymentCardsCarousel> {
  final _controller = PageController(viewportFraction: .88);
  final _savedCardsService = SavedCardsService();
  int _page = 0;
  List<PaymentCardData> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _savedCardsService.getCards();
      if (result['success']) {
        final List<dynamic> cardsData = result['cards'];
        setState(() {
          _cards = cardsData.map((m) => PaymentCardData.fromMap(m)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading cards: $e');
      setState(() => _isLoading = false);
    }
  }

  void _openAddPage() async {
    final result = await Navigator.pushNamed(context, AppRouter.addCard);

    if (result != null && result is Map<String, dynamic>) {
      // Re-load cards to ensure default status etc. is correct
      _loadCards();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _cards.isNotEmpty) {
          _controller.animateToPage(
            _cards.length - 1, 
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _deleteCard(int index) async {
    final cardId = _cards[index].id;
    if (cardId == null) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCardConfirmation),
        content: Text(l10n.deleteCardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _savedCardsService.deleteCard(cardId);
      if (result['success']) {
        _loadCards();
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'فشل حذف البطاقة')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // العنوان + زر إضافة
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.paymentMethods,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openAddPage,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF111827),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  backgroundColor: const Color(0xFFF2F4F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(l10n.add, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
 
        SizedBox(
          height: 200,
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : PageView.builder(
              controller: _controller,
              itemCount: _cards.length + 1, // آخر عنصر = إضافة
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                if (i == _cards.length) {
                  return _AddCardInline(onTap: _openAddPage);
                }
                return _PaymentCard(
                  data: _cards[i],
                  onDelete: () => _deleteCard(i),
                );
              },
            ),
        ),

        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _cards.length + 1,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _page == i ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _page == i ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const double _cardWidth = 330;

class _PaymentCard extends StatelessWidget {
  final PaymentCardData data;
  final VoidCallback? onDelete;
  const _PaymentCard({required this.data, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        width: _cardWidth,
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232629), Color(0xFF1C1F22)],
          ),
          border: Border.all(
            color: const Color(0xFFE7EDF3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            if (onDelete != null)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.currentBalance,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const _MastercardLogo(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.balance,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    data.masked,
                    style: const TextStyle(
                      color: Color(0xFFE5E7EB),
                      fontSize: 16,
                      letterSpacing: 1.4,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.cardholder,
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.holder,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.validThru,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.validThru,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCardInline extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCardInline({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: _cardWidth,
          height: 190,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Icon(Icons.add_rounded, color: Color(0xFF111827), size: 28),
              ),
              SizedBox(height: 10),
              Text(
                'إضافة بطاقة جديدة',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardLogo extends StatelessWidget {
  final String brand;
  const _CardLogo({required this.brand});

  @override
  Widget build(BuildContext context) {
    if (brand.toLowerCase() == 'visa') {
      return const _VisaLogo();
    }
    return const _MastercardLogo();
  }
}

class _VisaLogo extends StatelessWidget {
  const _VisaLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'VISA',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _MastercardLogo extends StatelessWidget {
  const _MastercardLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Positioned(left: 6, child: _LogoCircle(color: Color(0xFFFF5F58))),
          Positioned(right: 6, child: _LogoCircle(color: Color(0xFFFFB14B))),
        ],
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  final Color color;
  const _LogoCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ---------------- BottomSheet إضافة بطاقة ----------------
class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _form = GlobalKey<FormState>();
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _balance = TextEditingController(text: '\$0.00');

  @override
  void dispose() {
    _holder.dispose();
    _number.dispose();
    _expiry.dispose();
    _balance.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState?.validate() ?? false) {
      final masked = _maskNumber(_number.text);
      Navigator.pop(
        context,
        PaymentCardData(
          holder: _holder.text.trim(),
          masked: masked,
          balance: _balance.text.trim(),
          validThru: _expiry.text.trim(),
        ),
      );
    }
  }

  String _maskNumber(String input) {
    final clean = input.replaceAll(RegExp(r'\s+'), '');
    if (clean.length < 4) return '•••• •••• •••• ${clean.padLeft(4, '•')}';
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• •••• $last4';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  l10n.addNewCard,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 14),
                _field(
                  label: l10n.cardholderName,
                  controller: _holder,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.enterName : null,
                ),
                const SizedBox(height: 10),
                _field(
                  label: l10n.cardNumber,
                  controller: _number,
                  keyboard: TextInputType.number,
                  validator: (v) {
                    final c = v?.replaceAll(RegExp(r'\s+'), '') ?? '';
                    if (c.length < 12) return l10n.invalidNumber;
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        label: l10n.expiryDate,
                        controller: _expiry,
                        keyboard: TextInputType.number,
                        hintText: 'MM/YY',
                        inputFormatters: [_ExpiryDateFormatter()],
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.enterExpiryDate;
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) return l10n.invalidFormat;
                          
                          // Validate month (01-12)
                          final parts = v.split('/');
                          final month = int.tryParse(parts[0]);
                          if (month == null || month < 1 || month > 12) {
                            return l10n.invalidMonth;
                          }
                          
                          // Validate year (current year or later)
                          final year = int.tryParse('20${parts[1]}');
                          final currentYear = DateTime.now().year;
                          if (year == null || year < currentYear) {
                            return l10n.invalidYear;
                          }
                          
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        label: l10n.initialBalance,
                        controller: _balance,
                        keyboard: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_rounded),
                    label: Text(
                      l10n.saveCard,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

// Custom formatter for expiry date MM/YY
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 4 digits
    if (text.length > 4) {
      return oldValue;
    }
    
    // Format as MM/YY
    String formatted = text;
    if (text.length >= 2) {
      formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ===================================================
// =============== أيقونة نقاط المكافآت ===============
// ===================================================

class _PointsIconButton extends StatelessWidget {
  const _PointsIconButton();

  @override
  Widget build(BuildContext context) {
    final pointsService = Provider.of<PointsService>(context);
    final currentPoints = pointsService.currentPoints;
    final displayPoints = currentPoints > 999 ? '+999' : currentPoints.toString();

    return GestureDetector(
      onTap: () => _showPointsBottomSheet(context),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$displayPoints نقطة',
            style: const TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  void _showPointsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: const _PointsBottomSheet(),
      ),
    );
  }
}

// ===================================================
// ============= نافذة تفاصيل النقاط ================
// ===================================================

class _PointsBottomSheet extends StatelessWidget {
  const _PointsBottomSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pointsService = Provider.of<PointsService>(context);
    final currentPoints = pointsService.currentPoints;
    final jodValue = pointsService.jodValue;
    final eligible = pointsService.cashoutEligible;
    final pending = pointsService.hasPendingCashout;
    const minCashout = 1000; // 10 JOD
    final progress = (currentPoints / minCashout).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7), // iOS system background
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D1D6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Main balance card ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label
                        Text(
                          'رصيد النقاط',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8E8E93),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Points number
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              currentPoints.toString(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                                height: 1,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'نقطة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF8E8E93),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '= ${jodValue.toStringAsFixed(2)} دينار أردني',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Progress toward cashout ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              eligible ? 'جاهز للصرف' : 'التقدم نحو الصرف',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                            Text(
                              '$currentPoints / $minCashout',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF48484A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFF2F2F7),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              eligible ? AppColors.primary : const Color(0xFF34C759),
                            ),
                          ),
                        ),
                        if (!eligible) ...[
                          const SizedBox(height: 6),
                          Text(
                            'تحتاج ${(minCashout - currentPoints).clamp(0, minCashout)} نقطة للوصول إلى 10 دنانير',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Info row: rate ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'معدل الاستبدال',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '100 نقطة = 1 دينار',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Actions ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        // Cashout button
                        _ActionRow(
                          label: pending
                              ? 'طلب صرف قيد المراجعة'
                              : eligible
                                  ? 'صرف الرصيد'
                                  : 'صرف الرصيد (${minCashout - currentPoints} نقطة متبقية)',
                          enabled: eligible && !pending,
                          onTap: () => _showCashoutDialog(context, pointsService),
                          isLast: false,
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 0,
                            color: Color(0xFFF2F2F7)),
                        // History button
                        _ActionRow(
                          label: 'سجل النقاط',
                          enabled: true,
                          onTap: () {
                            Navigator.pop(context);
                            _showPointsHistory(context);
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  // ── Recent transactions title ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      'العمليات الأخيرة',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E8E93),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  // ── Transactions list ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: pointsService.transactions.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'لا توجد عمليات بعد',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: pointsService.transactions.length > 5
                                ? 5
                                : pointsService.transactions.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1, indent: 20, endIndent: 0,
                              color: Color(0xFFF2F2F7),
                            ),
                            itemBuilder: (context, index) {
                              final t = pointsService.transactions[index];
                              final isEarned = t.type == PointsTransactionType.earned;
                              final isLast = index == (pointsService.transactions.length > 5
                                  ? 4
                                  : pointsService.transactions.length - 1);
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: isLast
                                      ? const BorderRadius.vertical(bottom: Radius.circular(14))
                                      : (index == 0
                                          ? const BorderRadius.vertical(top: Radius.circular(14))
                                          : BorderRadius.zero),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              t.description ?? (isEarned ? 'نقاط مكتسبة' : 'نقاط مستخدمة'),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1C1C1E),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _formatDate(t.timestamp),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF8E8E93),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${isEarned ? '+' : '-'}${t.points}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isEarned
                                              ? const Color(0xFF34C759)
                                              : const Color(0xFFFF3B30),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Reusable action row (iOS style) ──
class _ActionRow extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool isLast;

  const _ActionRow({
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(14))
              : const BorderRadius.vertical(top: Radius.circular(14)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: enabled ? const Color(0xFF1C1C1E) : const Color(0xFFAEAEB2),
                fontWeight: FontWeight.w400,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: enabled
                  ? const Color(0xFFC7C7CC)
                  : const Color(0xFFD1D1D6),
            ),
          ],
        ),
      ),
    );
  }
}

void _showPointsHistory(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final pointsService = Provider.of<PointsService>(context, listen: false);
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.pointsHistory,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: pointsService.transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد عمليات مسجلة',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: pointsService.transactions.length,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final transaction = pointsService.transactions[index];
                        return _PointsTransactionItem(transaction: transaction);
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Ensure backward compatibility if anything else implicitly references it
void _showRedeemDialog(BuildContext context, PointsService pointsService) {
  _showCashoutDialog(context, pointsService);
}

void _showCashoutDialog(BuildContext context, PointsService pointsService) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        bool isLoading = false;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7), // iOS style dialog bg
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clean Header
                const Text(
                  'طلب صرف الرصيد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم تقديم طلب لسحب مبلغ ${pointsService.jodValue.toStringAsFixed(2)} دينار أردني، يرجى تزويدنا بالكليك الخاص بك.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 24),

                // Link Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: controller,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'سيتم عرض الطلب على الإدارة فور الإرسال للموافقة عليه وتحويل المبلغ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading ? null : () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              color: Color(0xFF007AFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading ? null : () async {
                          final link = controller.text.trim();
                          if (link.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('يرجى إدخال الرابط'),
                                backgroundColor: const Color(0xFFFF3B30),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isLoading = true);
                          final result = await pointsService.requestCashout(link);
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] as String),
                              backgroundColor: result['success'] == true ? AppColors.primary : const Color(0xFFFF3B30),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'إرسال',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}


// ===================================================
// ========== (قديم - للحذف لاحقاً) =================
// ===================================================

class RewardsPointsCard extends StatelessWidget {
  const RewardsPointsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pointsService = Provider.of<PointsService>(context);
    final currentPoints = pointsService.currentPoints;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
            AppColors.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان مع الأيقونة
          Row(
            children: [
              // أيقونة النقاط
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rewardsPoints,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.earnPointsWithPayments,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // النقاط الحالية - تصميم محسّن
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.yourPoints,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            currentPoints.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.points,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // القيمة المالية
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '100 ${l10n.points}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '= 1 JD',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // الأزرار
          Row(
            children: [
              // زر السجل
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showPointsHistory(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.pointsHistory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              if (currentPoints >= 100) ...[
                const SizedBox(width: 12),
                // زر الاستبدال
                Expanded(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => _showRedeemDialog(context, pointsService),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.redeemPoints,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showPointsHistory(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pointsService = Provider.of<PointsService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // العنوان
                Text(
                  l10n.pointsHistory,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // القائمة
                Expanded(
                  child: pointsService.transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noPaidTransactions,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: pointsService.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = pointsService.transactions[index];
                            return _PointsTransactionItem(transaction: transaction);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, PointsService pointsService) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.redeemPoints),
        content: Text(
          'هذه الميزة قيد التطوير. قريباً ستتمكن من استبدال نقاطك بخصومات ومكافآت!',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _PointsTransactionItem extends StatelessWidget {
  final PointsTransaction transaction;
  
  const _PointsTransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEarned = transaction.type == PointsTransactionType.earned;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // الأيقونة البسيطة
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isEarned 
                  ? AppColors.financialGreen50
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEarned ? Icons.add_rounded : Icons.remove_rounded,
              color: isEarned ? AppColors.primary : const Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 14),
          
          // التفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEarned ? l10n.earnedPoints : l10n.redeemedPoints,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.timestamp, l10n),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (transaction.relatedPaymentAmount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'JD ${transaction.relatedPaymentAmount!.toStringAsFixed(3)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 10),
          
          // النقاط البسيطة
          Text(
            '${isEarned ? '+' : '-'}${transaction.points}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isEarned ? AppColors.primary : const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}


