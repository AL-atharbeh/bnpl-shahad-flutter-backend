import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/language_service.dart';
import '../../../../services/deal_service.dart';
import '../../../../services/category_service.dart';
import '../../../../config/env/env_dev.dart';
import '../../../../utils/image_helper.dart';

/// نموذج البيانات
class Offer {
  final int id;
  final String storeName;
  final String storeNameAr;
  final String storeLogo;     // مسار الأصول (Asset) أو network URL
  final String offerImage;    // صورة العرض (Banner)
  final String discountText;  // مثال: "%90"
  final String discountLabel; // مثال: "خصم"
  final String category;      // مثال: "الأزياء"
  final int? categoryId;
  final bool onlineOnly;
  final String? storeUrl;     // رابط المتجر

  const Offer({
    required this.id,
    required this.storeName,
    required this.storeNameAr,
    required this.storeLogo,
    required this.offerImage,
    required this.discountText,
    required this.discountLabel,
    required this.category,
    this.categoryId,
    this.onlineOnly = true,
    this.storeUrl,
  });
}

/// ألوان موحّدة
class _C {
  static const bg = Color(0xFFF7F9FC);
  static const card = Colors.white;
  static const text = Color(0xFF0F172A);
  static const sub = Color(0xFF6B7280);
  static const primary = Color(0xFF00A66A);
  static const stroke = Color(0xFFE7EDF3);
}

/// صفحة العروض كشبكة شعارات
class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final DealService _dealService = DealService();
  final CategoryService _categoryService = CategoryService();
  
  // ذاكرة مؤقتة استاتيكية لتحميل الصفحة فورياً
  static List<Offer> _cachedOffers = [];
  static List<Map<String, dynamic>> _cachedCategories = [];
  static bool _hasLoadedOnce = false;

  List<Offer> _offers = _cachedOffers;
  List<Map<String, dynamic>> _categories = _cachedCategories;
  bool _isLoading = !_hasLoadedOnce;
  String _activeFilter = '';
  String _query = '';
  int? _selectedCategoryId;

  List<String> _getFilters() {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final isArabic = languageService.isArabic;
    
    // Start with "All" option
    List<String> filters = [l10n.all];
    
    // Add categories from database
    for (var category in _categories) {
      final categoryName = isArabic 
          ? (category['nameAr'] ?? category['name'] ?? '')
          : (category['name'] ?? category['nameAr'] ?? '');
      if (categoryName.isNotEmpty) {
        filters.add(categoryName);
      }
    }
    
    return filters;
  }

  bool get _isRTL => Directionality.of(context) == TextDirection.rtl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!_hasLoadedOnce) {
      setState(() => _isLoading = true);
    }
    
    try {
      // Load categories
      await _loadCategories();
      
      // Load deals
      await _loadDeals(categoryId: _selectedCategoryId);
    } catch (e) {
      if (EnvDev.enableLogging) {
        print('❌ Error loading data: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _categoryService.getAllCategories();
      
      if (response['success']) {
        final backendData = response['data'];
        final categoriesData = backendData is List 
            ? backendData 
            : (backendData['data'] ?? backendData);
        
        if (categoriesData is List) {
          setState(() {
            _categories = categoriesData.cast<Map<String, dynamic>>();
            _cachedCategories = _categories;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_categories.length} categories');
          }
        }
      }
    } catch (e) {
      if (EnvDev.enableLogging) {
        print('❌ Error loading categories: $e');
      }
    }
  }

  Future<void> _loadDeals({int? categoryId}) async {
    try {
      // Get all active deals
      final response = await _dealService.getAllDeals(
        isActive: true,
        includeExpired: false,
      );
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic dealsData;
        if (backendData is List) {
          dealsData = backendData;
        } else if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            dealsData = backendData['data'];
          } else if (backendData['data'] != null) {
            dealsData = backendData['data'];
          } else {
            dealsData = backendData;
          }
        } else {
          dealsData = backendData;
        }
        
        if (dealsData is List) {
          final languageService = Provider.of<LanguageService>(context, listen: false);
          final isArabic = languageService.isArabic;
          
          final loadedOffers = dealsData.map<Offer>((deal) {
            final store = deal['store'] ?? {};
            final category = store['categoryRelation'] ?? {};
            
            final categoryName = category['name'] ?? category['nameAr'] ?? store['category'] ?? '';
            final categoryNameAr = category['nameAr'] ?? category['name'] ?? '';
            
            // Get discount text
            final discountValue = deal['discountValue'] ?? deal['discountLabel'] ?? '';
            final discountLabel = deal['discountLabel'] ?? '';
            final discountText = discountValue.isNotEmpty 
                ? discountValue 
                : (discountLabel.isNotEmpty ? discountLabel : 'خصم');
            
            final offerImage = deal['imageUrl'] ?? deal['bannerUrl'] ?? deal['image'] ?? store['coverUrl'] ?? store['logoUrl'] ?? 'assets/images/zara.jpg';

            return Offer(
              id: deal['id'] ?? 0,
              storeName: store['name'] ?? '',
              storeNameAr: store['nameAr'] ?? store['name'] ?? '',
              storeLogo: store['logoUrl'] ?? 'assets/images/zara.jpg',
              offerImage: offerImage,
              discountText: discountText,
              discountLabel: discountLabel,
              category: isArabic 
                  ? (categoryNameAr.isNotEmpty ? categoryNameAr : categoryName)
                  : (categoryName.isNotEmpty ? categoryName : 'General'),
              categoryId: store['categoryId'] ?? category['id'],
              storeUrl: deal['storeUrl'] ?? store['storeUrl'] ?? store['websiteUrl'],
            );
          }).toList();

          setState(() {
            _offers = loadedOffers;
            if (categoryId == null) {
              _cachedOffers = loadedOffers;
              _hasLoadedOnce = true;
            }
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_offers.length} deals');
          }
        }
      }
    } catch (e) {
      if (EnvDev.enableLogging) {
        print('❌ Error loading deals: $e');
      }
    }
  }

  void _onFilterChanged(String filter) {
    final filters = _getFilters();
    
    setState(() {
      _activeFilter = filter;
      
      // Find category ID if filter is not "All"
      if (filter == filters.first) {
        _selectedCategoryId = null;
      } else {
        final languageService = Provider.of<LanguageService>(context, listen: false);
        final isArabic = languageService.isArabic;
        
        final category = _categories.firstWhere(
          (cat) {
            final catName = isArabic 
                ? (cat['nameAr'] ?? cat['name'] ?? '')
                : (cat['name'] ?? cat['nameAr'] ?? '');
            return catName == filter;
          },
          orElse: () => {},
        );
        _selectedCategoryId = category['id'];
      }
    });
    
    // Reload deals with new filter
    _loadDeals(categoryId: _selectedCategoryId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isArabic = languageService.isArabic;
    
    // Initialize filter with first item if empty
    final filters = _getFilters();
    if (_activeFilter.isEmpty && filters.isNotEmpty) {
      _activeFilter = filters.first;
    }
    
    // Filter deals locally (for instant UI update)
    final filtered = _offers.where((o) {
      final passFilter = _activeFilter == filters.first || o.category == _activeFilter;
      final passQuery = _query.trim().isEmpty ||
          o.storeName.toLowerCase().contains(_query.toLowerCase()) ||
          o.storeNameAr.toLowerCase().contains(_query.toLowerCase()) ||
          o.discountText.contains(_query);
      return passFilter && passQuery;
    }).toList();

    return Scaffold(
      backgroundColor: _C.bg,
      body: CustomScrollView(
        slivers: [
          // AppBar + Search
          SliverAppBar(
            backgroundColor: _C.bg,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            title: Text(
              l10n.bestOffers,
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: _C.text),
            ),
            leading: IconButton(
              icon: const Icon(Icons.chevron_right_rounded, color: _C.text, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _SearchBar(
                  hint: l10n.searchOffers,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
          ),

          // Filters
          SliverToBoxAdapter(
            child: SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                reverse: false,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final label = filters[i];
                  final active = label == _activeFilter;
                  return GestureDetector(
                    onTap: () => _onFilterChanged(label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? _C.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: active ? _C.primary : _C.stroke),
                        boxShadow: active
                            ? [BoxShadow(color: _C.primary.withOpacity(.12), blurRadius: 14, offset: const Offset(0, 8))]
                            : [],
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: active ? Colors.white : _C.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // GRID
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _isLoading
                ? SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: _C.primary),
                    ),
                  )
                : filtered.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_offer_outlined, size: 64, color: _C.sub),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noOffersFound,
                                style: TextStyle(color: _C.sub, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final o = filtered[index];
                            return _OfferCard(
                              offer: o,
                              isArabic: isArabic,
                              onTap: () async {
                                // افتح رابط المتجر إذا كان موجوداً
                                final url = o.storeUrl;
                                if (url != null && url.isNotEmpty) {
                                  try {
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      if (EnvDev.enableLogging) {
                                        print('❌ Cannot launch URL: $url');
                                      }
                                    }
                                  } catch (e) {
                                    if (EnvDev.enableLogging) {
                                      print('❌ Error launching URL: $e');
                                    }
                                  }
                                }
                              },
                            );
                          },
                          childCount: filtered.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.25, // تصميم بطاقة العروض أفقية مثل بطاقات الفيزا الراقية
                        ),
                      ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

/// شريط بحث بتصميم ناعم ونظيف
class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const _SearchBar({required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _C.primary,
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// كرت العرض بتصميم أنعم وألطف ويحتوي على صورة العرض بتصميم قسيمة التذاكر المبتكر
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    // تجويف لليسار
    path.lineTo(0, size.height / 2 - 6);
    path.arcToPoint(
      Offset(0, size.height / 2 + 6),
      radius: const Radius.circular(6),
      clockwise: true,
    );
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    // تجويف لليمين
    path.lineTo(size.width, size.height / 2 + 6);
    path.arcToPoint(
      Offset(size.width, size.height / 2 - 6),
      radius: const Radius.circular(6),
      clockwise: true,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final bool isArabic;
  final VoidCallback? onTap;
  const _OfferCard({required this.offer, required this.isArabic, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias, // لقص الخلفية الزجاجية على الحواف الدائرية للكرت
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: const Color(0xFFEFF3F8), width: 1.2),
        ),
        child: Stack(
          children: [
            // 1. الصورة تملأ الكارت بالكامل كخلفية (Full Background Image) لمنع الفراغات تماماً
            Positioned.fill(
              child: ImageHelper.buildImage(
                imageUrl: offer.offerImage,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: const Color(0xFFF8FAFC),
                  child: const Icon(Icons.local_offer_rounded, color: Color(0xFF94A3B8), size: 36),
                ),
              ),
            ),
            
            // علامة الأونلاين (Online Badge) ناعمة جداً وصغيرة في الأعلى
            if (offer.onlineOnly)
              Positioned(
                top: 8,
                left: isArabic ? 8 : null,
                right: isArabic ? null : 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      color: Colors.white.withOpacity(0.85),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public_rounded, size: 10, color: Color(0xFF00A66A)),
                          SizedBox(width: 4),
                          Text(
                            'Online',
                            style: TextStyle(
                              color: Color(0xFF00A66A),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
            // تدرج ظل سفلي ناعم خلف النصوص لتحسين المقروئية
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            
            // 2. الشريط الزجاجي الفاخر في الأسفل (Frosted Glass Overlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 48,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.white.withOpacity(0.88),
                    child: Row(
                      children: [
                        // شعار المتجر الدائري الصغير
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFEFF3F8), width: 1),
                          ),
                          child: ClipOval(
                            child: ImageHelper.buildImage(
                              imageUrl: offer.storeLogo,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(Icons.store_rounded, color: Color(0xFF94A3B8), size: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // اسم المتجر وتصنيفه بخطوط ناعمة وألوان داكنة عالية التباين
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isArabic ? offer.storeNameAr : offer.storeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                offer.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 3. الخصم ككبسولة خضراء جذابة وعريضة في زاوية الشريط الزجاجي
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A66A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            offer.discountText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
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
