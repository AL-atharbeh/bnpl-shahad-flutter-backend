import 'dart:ui';
import '../../../../utils/image_helper.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/language_service.dart';
import '../../../../services/store_service.dart';
import '../../../../services/category_service.dart';
import '../../../../config/env/env_dev.dart';
import '../../../../routing/app_router.dart';

class _C {
  static const bg = Color(0xFFF7F9FC);
  static const text = Color(0xFF0F172A);
  static const sub  = Color(0xFF6B7280);
  static const stroke = Color(0xFFE7EDF3);
  static const primary = Color(0xFF00A66A);
}

class StoreItem {
  final int id;
  final String name;
  final String nameAr;
  final String logo;      // مسار الصورة في assets أو network URL
  final String category;
  final int? categoryId;
  const StoreItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logo,
    required this.category,
    this.categoryId,
  });
}

class AllStoresPage extends StatefulWidget {
  const AllStoresPage({super.key});
  @override
  State<AllStoresPage> createState() => _AllStoresPageState();
}

class _AllStoresPageState extends State<AllStoresPage> {
  final StoreService _storeService = StoreService();
  final CategoryService _categoryService = CategoryService();
  
  List<StoreItem> _stores = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _q = '';
  String _filter = '';
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
      
      // Load stores
      await _loadStores();
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

  Future<void> _loadStores({int? categoryId, String? searchQuery}) async {
    try {
      Map<String, dynamic> response;
      
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        // Use search API
        response = await _storeService.searchStores(searchQuery.trim(), categoryId: categoryId);
      } else {
        // Use getAllStores API - get ALL stores (not just top stores)
        response = await _storeService.getAllStores(categoryId: categoryId);
      }
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic storesData;
        if (backendData is List) {
          storesData = backendData;
        } else if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            storesData = backendData['data'];
          } else if (backendData['data'] != null) {
            storesData = backendData['data'];
          } else {
            storesData = backendData;
          }
        } else {
          storesData = backendData;
        }
        
        if (storesData is List) {
          final languageService = Provider.of<LanguageService>(context, listen: false);
          final isArabic = languageService.isArabic;
          
          setState(() {
            _stores = storesData.map<StoreItem>((store) {
              final category = store['categoryRelation'] ?? {};
              final categoryName = category['name'] ?? category['nameAr'] ?? store['category'] ?? '';
              final categoryNameAr = category['nameAr'] ?? category['name'] ?? '';
              
              return StoreItem(
                id: store['id'] ?? 0,
                name: store['name'] ?? '',
                nameAr: store['nameAr'] ?? store['name'] ?? '',
                logo: store['logoUrl'] ?? 'assets/images/zara.jpg',
                category: isArabic 
                    ? (categoryNameAr.isNotEmpty ? categoryNameAr : categoryName)
                    : (categoryName.isNotEmpty ? categoryName : 'General'),
                categoryId: store['categoryId'] ?? category['id'],
              );
            }).toList();
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_stores.length} stores');
          }
        }
      }
    } catch (e) {
      if (EnvDev.enableLogging) {
        print('❌ Error loading stores: $e');
      }
    }
  }

  void _onFilterChanged(String filter) {
    final filters = _getFilters();
    
    setState(() {
      _filter = filter;
      
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
    
    // Reload stores with new filter
    _loadStores(categoryId: _selectedCategoryId);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _q = query;
    });
    
    // Debounce search - reload after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_q == query) {
        _loadStores(categoryId: _selectedCategoryId, searchQuery: query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isArabic = languageService.isArabic;
    
    // Initialize filter with first item if empty
    final filters = _getFilters();
    if (_filter.isEmpty && filters.isNotEmpty) {
      _filter = filters.first;
    }
    
    // Filter stores locally (for instant UI update)
    final data = _stores.where((s) {
      // Use ID for filtering instead of string comparison for robustness
      final f = _selectedCategoryId == null || s.categoryId == _selectedCategoryId;
      final q = _q.trim().isEmpty || 
                s.name.toLowerCase().contains(_q.toLowerCase()) ||
                s.nameAr.toLowerCase().contains(_q.toLowerCase());
      return f && q;
    }).toList();

    return Scaffold(
      backgroundColor: _C.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _C.bg,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            title: Text(l10n.allStores,
                style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w800,color: _C.text)),
            leading: IconButton(
              icon: Icon(_isRTL ? Icons.arrow_forward : Icons.arrow_back, color: _C.text),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16,0,16,12),
                child: _SearchBar(
                  hint: l10n.searchStores,
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
          ),

          // فلاتر مثل صفحة العروض
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
                  final active = label == _filter;
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
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // شبكة شعارات فقط (بدون كروت)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
            sliver: _isLoading
                ? SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: _C.primary),
                    ),
                  )
                : data.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store_outlined, size: 64, color: _C.sub),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noStoresFound,
                                style: TextStyle(color: _C.sub, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.crossAxisExtent;
                          final cols = w > 900 ? 6 : w > 700 ? 5 : w > 500 ? 4 : 3;

                          return SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, i){
                                final s = data[i];
                                return _LogoOnly(
                                  name: isArabic ? s.nameAr : s.name,
                                  logo: s.logo,
                                  storeId: s.id,
                                  onTap: (){
                                    AppRouter.navigateToStoreDetails(
                                      context,
                                      storeId: s.id,
                                      storeName: isArabic ? s.nameAr : s.name,
                                      storeLogo: s.logo,
                                      storeBanner: s.logo,
                                    );
                                  },
                                );
                              },
                              childCount: data.length,
                            ),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: .82,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// شريط بحث زجاجي بسيط
class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const _SearchBar({required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.stroke),
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

/// عنصر شبكة "شعار فقط" بدون أي إطار
class _LogoOnly extends StatelessWidget {
  final String name;
  final String logo;
  final int? storeId;
  final VoidCallback? onTap;
  const _LogoOnly({required this.name,required this.logo,this.storeId,this.onTap});

  Widget _buildStoreImage(String imageUrl) {
    return ImageHelper.buildImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorWidget: Container(
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.store_rounded, color: _C.text, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // دائرة الشعار مع ظل خفييف جدًا
          Container(
            width: 74, height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0,6)),
              ],
            ),
            child: ClipOval(
              child: _buildStoreImage(logo),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 90,
            child: Text(
              name,
              maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: _C.text,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
