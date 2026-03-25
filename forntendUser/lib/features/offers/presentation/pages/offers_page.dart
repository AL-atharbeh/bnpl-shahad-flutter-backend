import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/language_service.dart';
import '../../../../services/deal_service.dart';
import '../../../../services/category_service.dart';
import '../../../../config/env/env_dev.dart';

/// نموذج البيانات
class Offer {
  final int id;
  final String storeName;
  final String storeNameAr;
  final String storeLogo;     // مسار الأصول (Asset) أو network URL
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
  
  List<Offer> _offers = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
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
    setState(() => _isLoading = true);
    
    try {
      // Load categories
      await _loadCategories();
      
      // Load deals
      await _loadDeals();
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
          
          setState(() {
            _offers = dealsData.map<Offer>((deal) {
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
              
              return Offer(
                id: deal['id'] ?? 0,
                storeName: store['name'] ?? '',
                storeNameAr: store['nameAr'] ?? store['name'] ?? '',
                storeLogo: store['logoUrl'] ?? 'assets/images/zara.jpg',
                discountText: discountText,
                discountLabel: discountLabel,
                category: isArabic 
                    ? (categoryNameAr.isNotEmpty ? categoryNameAr : categoryName)
                    : (categoryName.isNotEmpty ? categoryName : 'General'),
                categoryId: store['categoryId'] ?? category['id'],
                storeUrl: deal['storeUrl'] ?? store['storeUrl'] ?? store['websiteUrl'],
              );
            }).toList();
            
            // Filter by category if selected
            if (categoryId != null) {
              _offers = _offers.where((offer) => offer.categoryId == categoryId).toList();
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
              icon: Icon(_isRTL ? Icons.arrow_forward : Icons.arrow_back, color: _C.text),
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
                            return _LogoOfferTile(
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
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: .92, // توازن ارتفاع/عرض الكرت
                        ),
                      ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

/// شريط بحث زجاجي
class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const _SearchBar({required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.stroke),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search_rounded, color: _C.sub),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: _C.sub, fontSize: 14),
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

/// بلاطة شعار العرض (كارت راقٍ – شعار كبير + اسم المتجر + الخصم)
class _LogoOfferTile extends StatelessWidget {
  final Offer offer;
  final bool isArabic;
  final VoidCallback? onTap;
  const _LogoOfferTile({required this.offer, required this.isArabic, this.onTap});

  Widget _buildStoreImage(String imageUrl) {
    final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    
    if (isNetworkImage) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFF1F5F9),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: _C.primary,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF1F5F9),
          child: const Icon(Icons.store, color: _C.text),
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF1F5F9),
          child: const Icon(Icons.store, color: _C.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: _C.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.stroke),
            boxShadow: const [
              BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 6)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // شعار داخل حلقة أنيقة
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                    ),
                    border: Border.all(color: _C.stroke),
                    boxShadow: const [
                      BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 6)),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildStoreImage(offer.storeLogo),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // اسم المتجر + شارة "أونلاين فقط"
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isArabic ? offer.storeNameAr : offer.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _C.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF8F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD5F0E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.public, size: 12, color: _C.primary),
                        SizedBox(width: 4),
                        Text('Online Only',
                            style: TextStyle(color: _C.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // الخصم الكبير أسفل الكرت
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  offer.discountText,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _C.text,
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
