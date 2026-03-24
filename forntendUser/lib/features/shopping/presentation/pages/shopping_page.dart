import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../services/category_service.dart';
import '../../../../services/deal_service.dart';
import '../../../../config/env/env_dev.dart';

/// ألوان وهوية بسيطة
class ShopColors {
  static const bg = Color(0xFFF0F2F5);
  static final primary = AppColors.primary; // Financial Green
  static const text = Color(0xFF0F172A);
  static const subtext = Color(0xFF6B7280);
  static const card = Colors.white;
  static const stroke = Color(0xFFE7EDF3);
}

/// ارتفاع شريط الـ NavBar العائم (عدِّله لو كان مقاسك مختلف)
const double kGlassNavHeight = 78;

/// مساحة التمرير السفلي المطلوبة حتى ما يتغطّى آخر المحتوى بالـ NavBar
double _scrollBottomSpacer(BuildContext context) {
  return kGlassNavHeight + MediaQuery.of(context).padding.bottom + 24;
}

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});
  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  int selectedCategory = 0; // 0 نساء، 1 رجال، 2 أطفال
  
  final CategoryService _categoryService = CategoryService();
  final DealService _dealService = DealService();
  
  // Categories from database (filtered by gender type)
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = false;

  // Featured deals from database
  List<Map<String, dynamic>> _featuredDeals = [];
  bool _isLoadingDeals = false;

  // === الفئات الرئيسية (نساء/رجال/أطفال) ===
  final List<Map<String, dynamic>> _mainCategories = const [
    {'titleAr': 'نساء', 'titleEn': 'Women', 'name': 'Women'},
    {'titleAr': 'رجال', 'titleEn': 'Men', 'name': 'Men'},
    {'titleAr': 'أطفال', 'titleEn': 'Kids', 'name': 'Kids'},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadFeaturedDeals();
  }
  
  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    
    try {
      // Get gender type based on selected category
      String? genderType;
      switch (selectedCategory) {
        case 0: // Women
          genderType = 'Women';
          break;
        case 1: // Men
          genderType = 'Men';
          break;
        case 2: // Kids
          genderType = 'Kids';
          break;
      }
      
      final response = await _categoryService.getAllCategories(genderType: genderType);
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic categoriesData;
        
        if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            categoriesData = backendData['data'];
          } else if (backendData['data'] != null) {
            categoriesData = backendData['data'];
          } else {
            categoriesData = backendData;
          }
        } else if (backendData is List) {
          categoriesData = backendData;
        } else {
          categoriesData = backendData;
        }
        
        if (categoriesData is List) {
          setState(() {
            _categories = categoriesData.map((item) {
              if (item is Map<String, dynamic>) {
                return item;
              } else if (item is Map) {
                return Map<String, dynamic>.from(item);
              } else {
                return <String, dynamic>{};
              }
            }).toList().cast<Map<String, dynamic>>();
            _isLoadingCategories = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_categories.length} categories for gender type: $genderType');
          }
        } else {
          setState(() {
            _categories = [];
            _isLoadingCategories = false;
          });
        }
      } else {
        setState(() {
          _categories = [];
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() {
        _categories = [];
        _isLoadingCategories = false;
      });
      if (EnvDev.enableLogging) {
        print('❌ Error loading categories: $e');
      }
    }
  }
  
  Future<void> _loadFeaturedDeals() async {
    setState(() => _isLoadingDeals = true);
    
    try {
      if (EnvDev.enableLogging) {
        print('📦 Loading featured deals...');
      }
      
      final response = await _dealService.getActiveDeals(limit: 10);
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic dealsData;
        
        if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            dealsData = backendData['data'];
          } else if (backendData['data'] != null) {
            dealsData = backendData['data'];
          } else {
            dealsData = backendData;
          }
        } else if (backendData is List) {
          dealsData = backendData;
        } else {
          dealsData = backendData;
        }
        
        if (dealsData is List) {
          setState(() {
            _featuredDeals = dealsData.map((item) {
              if (item is Map<String, dynamic>) {
                return item;
              } else if (item is Map) {
                return Map<String, dynamic>.from(item);
              } else {
                return <String, dynamic>{};
              }
            }).toList().cast<Map<String, dynamic>>();
            _isLoadingDeals = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_featuredDeals.length} featured deals');
          }
        } else {
          setState(() {
            _featuredDeals = [];
            _isLoadingDeals = false;
          });
        }
      } else {
        setState(() {
          _featuredDeals = [];
          _isLoadingDeals = false;
        });
      }
    } catch (e) {
      setState(() {
        _featuredDeals = [];
        _isLoadingDeals = false;
      });
      if (EnvDev.enableLogging) {
        print('❌ Error loading featured deals: $e');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;

    return Scaffold(
      extendBody: true, // ✅ يسمح للمحتوى بالامتداد تحت الشريط العائم
      backgroundColor: ShopColors.bg,
      body: RefreshIndicator(
        onRefresh: () async {
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
          slivers: [
          // الهيدر + شريط البحث المُحسّن
          SliverAppBar(
            backgroundColor: ShopColors.bg,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            title: Text(
              l10n.shopping,
              style: AppTextStyles.changaH3.copyWith(color: ShopColors.text),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: const _SmartSearchBar(),
              ),
            ),
          ),

          // الفئات الرئيسية (نساء/رجال/أطفال)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 56,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                scrollDirection: Axis.horizontal,
                reverse: isRTL,
                itemCount: _mainCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final item = _mainCategories[i];
                  final active = i == selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedCategory = i);
                      _loadCategories(); // Reload categories when gender changes
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: active ? ShopColors.primary : ShopColors.stroke,
                          width: active ? 1.6 : 1,
                        ),
                                                 boxShadow: active
                             ? [
                                 BoxShadow(
                                   color: ShopColors.primary.withValues(alpha: 0.09),
                                   blurRadius: 12,
                                   offset: const Offset(0, 6),
                                 )
                               ]
                             : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isRTL ? item['titleAr'] : item['titleEn'],
                        style: GoogleFonts.changa(
                          color: active ? ShopColors.primary : ShopColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // أقسام ضمن الفئة (من قاعدة البيانات)
          _isLoadingCategories
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : _categories.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            isRTL ? 'لا توجد فئات' : 'No categories found',
                            style: GoogleFonts.mada(
                              fontSize: 14,
                              color: ShopColors.subtext,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      sliver: SliverGrid.builder(
                        itemCount: _categories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.35,
                        ),
                        itemBuilder: (_, i) {
                          final category = _categories[i];
                          final categoryName = isRTL 
                              ? (category['nameAr']?.toString() ?? category['name']?.toString() ?? '')
                              : (category['name']?.toString() ?? category['nameAr']?.toString() ?? '');
                          final categoryId = category['id'] as int?;
                          final imageUrl = category['imageUrl']?.toString() ?? '';
                          final storesCount = category['storesCount'] as int? ?? 0;
                          
                          return _ImageCategoryTile(
                            imagePath: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                                ? imageUrl
                                : 'assets/images/zara.jpg', // Fallback
                            title: categoryName,
                            count: storesCount,
                            isRTL: isRTL,
                            onTap: () {
                              if (categoryId != null) {
                                AppRouter.navigateToCategoryBrowse(
                                  context,
                                  categoryId: categoryId,
                                  categoryName: categoryName,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),

          // عروض مميّزة (كروت محسنة)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Text(l10n.featuredOffers,
                      style: AppTextStyles.changaH5.copyWith(color: ShopColors.text)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/offers');
                    },
                    child: Text(
                      l10n.viewAll,
                      style: AppTextStyles.madaLabelLarge.copyWith(color: ShopColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Featured Deals from Database
          _isLoadingDeals
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : _featuredDeals.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            isRTL ? 'لا توجد عروض مميزة' : 'No featured offers found',
                            style: GoogleFonts.mada(
                              fontSize: 14,
                              color: ShopColors.subtext,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          reverse: isRTL,
                          itemCount: _featuredDeals.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final deal = _featuredDeals[i];
                            
                            // Safe data extraction with fallbacks
                            String getDealTitle() {
                              if (isRTL) {
                                return deal['titleAr']?.toString() ?? 
                                       deal['title']?.toString() ?? 
                                       deal['name']?.toString() ?? 
                                       deal['nameAr']?.toString() ?? 
                                       'عرض خاص';
                              } else {
                                return deal['title']?.toString() ?? 
                                       deal['name']?.toString() ?? 
                                       deal['titleEn']?.toString() ?? 
                                       deal['nameEn']?.toString() ?? 
                                       'Special Offer';
                              }
                            }
                            
                            String getImageUrl() {
                              final img = deal['imageUrl']?.toString() ?? 
                                         deal['image']?.toString() ?? 
                                         deal['productImageUrl']?.toString() ?? '';
                              return img;
                            }
                            
                            double getPrice() {
                              final price = deal['discountedPrice'] ?? deal['price'] ?? deal['finalPrice'] ?? 0;
                              if (price is String) {
                                return double.tryParse(price) ?? 0.0;
                              } else if (price is num) {
                                return price.toDouble();
                              }
                              return 0.0;
                            }
                            
                            double getOriginalPrice() {
                              final price = deal['originalPrice'] ?? deal['regularPrice'] ?? 0;
                              if (price is String) {
                                return double.tryParse(price) ?? 0.0;
                              } else if (price is num) {
                                return price.toDouble();
                              }
                              return 0.0;
                            }
                            
                            String getDiscount() {
                              return deal['discount']?.toString() ?? 
                                     deal['discountPercentage']?.toString() ?? 
                                     deal['discountPercent']?.toString() ?? '';
                            }
                            
                            final dealTitle = getDealTitle();
                            final imageUrl = getImageUrl();
                            final price = getPrice();
                            final originalPrice = getOriginalPrice();
                            final discount = getDiscount();
                            
                            return _DealCard(
                              title: dealTitle,
                              imageUrl: imageUrl,
                              price: price,
                              originalPrice: originalPrice,
                              discount: discount,
                              isRTL: isRTL,
                            );
                          },
                        ),
                      ),
                    ),

          /// ✅ Spacer في النهاية حتى ما يختفي المحتوى خلف الـ NavBar العائم
          SliverToBoxAdapter(
            child: SizedBox(height: _scrollBottomSpacer(context)),
          ),
        ],
        ),
      ),
    );
  }
}

/// شريط بحث ذكي (زجاجي خفيف + أزرار أكشن)
class _SmartSearchBar extends StatelessWidget {
  const _SmartSearchBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
                         color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ShopColors.stroke),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search_rounded, color: ShopColors.subtext),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchProductOrBrand,
                    hintStyle: const TextStyle(color: ShopColors.subtext),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بلاطة قسم بصورة
class _ImageCategoryTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final int count;
  final bool isRTL;
  final VoidCallback? onTap;
  const _ImageCategoryTile({
    required this.imagePath,
    required this.title,
    required this.count,
    required this.isRTL,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFEDEFF3),
                        child: const Icon(Icons.category, size: 40, color: Color(0xFF94A3B8)),
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFEDEFF3),
                        child: const Icon(Icons.category, size: 40, color: Color(0xFF94A3B8)),
                      ),
                    ),
            ),
            // تدرّج سفلي لقراءة النص
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: isRTL ? null : 10,
              right: isRTL ? 10 : null,
              bottom: 10,
              child: Column(
                crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.changa(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 2),
                  Text('$count ${l10n.product}',
                      style: GoogleFonts.mada(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deal Card Widget - Premium Modern Design
class _DealCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double price;
  final double originalPrice;
  final String discount;
  final bool isRTL;

  const _DealCard({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = discount.isNotEmpty && originalPrice > 0;
    
    return Container(
      width: 340,
      height: 220,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ShopColors.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image with Parallax Effect
            Positioned.fill(
              child: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ShopColors.primary.withValues(alpha: 0.15),
                              ShopColors.primary.withValues(alpha: 0.05),
                              Colors.purple.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.local_offer_outlined,
                            size: 80,
                            color: ShopColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ShopColors.primary.withValues(alpha: 0.15),
                            ShopColors.primary.withValues(alpha: 0.05),
                            Colors.purple.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_offer_outlined,
                          size: 80,
                          color: ShopColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
            ),
            
            // Sophisticated Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            
            // Discount Badge - Premium Design
            if (hasDiscount)
              Positioned(
                top: 16,
                right: isRTL ? null : 16,
                left: isRTL ? 16 : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF6B6B),
                        const Color(0xFFEE5A6F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$discount%',
                        style: GoogleFonts.changa(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'OFF',
                        style: GoogleFonts.changa(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Content Section - Bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with Premium Typography
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.changa(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: 0.3,
                      shadows: [
                        const Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Glassmorphism Offer Card - Subtle Design
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              ShopColors.primary.withValues(alpha: 0.85),
                              ShopColors.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ShopColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.discount_outlined,
                                        color: Colors.white.withValues(alpha: 0.85),
                                        size: 13,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        isRTL ? 'نسبة العرض' : 'Offer Rate',
                                        style: GoogleFonts.mada(
                                          fontSize: 10,
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    hasDiscount 
                                        ? '$discount%'
                                        : isRTL ? 'عرض خاص' : 'Special',
                                    style: GoogleFonts.changa(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.0,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                isRTL ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
