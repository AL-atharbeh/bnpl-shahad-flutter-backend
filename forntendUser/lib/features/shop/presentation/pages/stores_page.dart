import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/language_service.dart';
import '../../../../services/store_service.dart';
import '../../../../services/product_service.dart';
import '../../../../routing/app_router.dart';
import '../../../../config/env/env_dev.dart';

class CategoryBrowsePage extends StatefulWidget {
  final String title; // Category name like "Dresses"
  final int? categoryId; // Category ID from database
  const CategoryBrowsePage({super.key, required this.title, this.categoryId});

  @override
  State<CategoryBrowsePage> createState() => _CategoryBrowsePageState();
}

class _CategoryBrowsePageState extends State<CategoryBrowsePage> {
  int _tab = 0; // 0=stores, 1=products
  final TextEditingController _search = TextEditingController();
  final StoreService _storeService = StoreService();
  final ProductService _productService = ProductService();

  // Store data from database
  List<Map<String, dynamic>> _stores = [];
  bool _isLoadingStores = false;

  // Product data from database
  List<Map<String, dynamic>> _products = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    if (EnvDev.enableLogging) {
      print('🔍 CategoryBrowsePage initialized with categoryId: ${widget.categoryId}, title: ${widget.title}');
    }
    if (widget.categoryId != null) {
      _loadStores();
      _loadProducts();
    } else {
      if (EnvDev.enableLogging) {
        print('⚠️ categoryId is null, cannot load stores and products');
      }
    }
  }

  Future<void> _loadStores() async {
    if (widget.categoryId == null) {
      if (EnvDev.enableLogging) {
        print('⚠️ Cannot load stores: categoryId is null');
      }
      return;
    }
    
    setState(() => _isLoadingStores = true);
    
    if (EnvDev.enableLogging) {
      print('📦 Loading stores for categoryId: ${widget.categoryId}');
    }
    
    try {
      final response = await _storeService.getAllStores(categoryId: widget.categoryId);
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic storesData;
        
        if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            storesData = backendData['data'];
          } else if (backendData['data'] != null) {
            storesData = backendData['data'];
          } else {
            storesData = backendData;
          }
        } else if (backendData is List) {
          storesData = backendData;
        } else {
          storesData = backendData;
        }
        
        if (storesData is List) {
          setState(() {
            _stores = storesData.map((item) {
              if (item is Map<String, dynamic>) {
                return item;
              } else if (item is Map) {
                return Map<String, dynamic>.from(item);
              } else {
                return <String, dynamic>{};
              }
            }).toList().cast<Map<String, dynamic>>();
            _isLoadingStores = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_stores.length} stores for category ${widget.categoryId}');
          }
        } else {
          setState(() {
            _stores = [];
            _isLoadingStores = false;
          });
        }
      } else {
        setState(() {
          _stores = [];
          _isLoadingStores = false;
        });
      }
    } catch (e) {
      setState(() {
        _stores = [];
        _isLoadingStores = false;
      });
      if (EnvDev.enableLogging) {
        print('❌ Error loading stores: $e');
      }
    }
  }

  Future<void> _loadProducts() async {
    if (widget.categoryId == null) {
      if (EnvDev.enableLogging) {
        print('⚠️ Cannot load products: categoryId is null');
      }
      return;
    }
    
    setState(() => _isLoadingProducts = true);
    
    if (EnvDev.enableLogging) {
      print('📦 Loading products for categoryId: ${widget.categoryId}');
    }
    
    try {
      final response = await _productService.getAllProducts(categoryId: widget.categoryId);
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic productsData;
        
        if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            productsData = backendData['data'];
          } else if (backendData['data'] != null) {
            productsData = backendData['data'];
          } else {
            productsData = backendData;
          }
        } else if (backendData is List) {
          productsData = backendData;
        } else {
          productsData = backendData;
        }
        
        if (productsData is List) {
          setState(() {
            _products = productsData.map((item) {
              if (item is Map<String, dynamic>) {
                return item;
              } else if (item is Map) {
                return Map<String, dynamic>.from(item);
              } else {
                return <String, dynamic>{};
              }
            }).toList().cast<Map<String, dynamic>>();
            _isLoadingProducts = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_products.length} products for category ${widget.categoryId}');
          }
        } else {
          setState(() {
            _products = [];
            _isLoadingProducts = false;
          });
        }
      } else {
        setState(() {
          _products = [];
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        _products = [];
        _isLoadingProducts = false;
      });
      if (EnvDev.enableLogging) {
        print('❌ Error loading products: $e');
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = LanguageService();
    final isRTL = languageService.isArabic;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: const Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.tune, color: Color(0xFF0F172A)),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _search,
                            style: const TextStyle(color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              hintText: l10n.whatAreYouLookingFor,
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Color(0xFF0F172A)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Segmented control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _SegmentedPill(
                    selected: _tab == 0,
                    label: l10n.stores,
                    onTap: () => setState(() => _tab = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SegmentedPill(
                    selected: _tab == 1,
                    label: l10n.products,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Subtitle (category name)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment:
                  isRTL ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _tab == 0
                  ? _isLoadingStores
                      ? const Center(child: CircularProgressIndicator())
                      : _stores.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noStoresFound,
                                style: const TextStyle(color: Color(0xFF6B7280)),
                              ),
                            )
                          : _StoresList(stores: _stores)
                  : _isLoadingProducts
                      ? const Center(child: CircularProgressIndicator())
                      : _products.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noProductsFound,
                                style: const TextStyle(color: Color(0xFF6B7280)),
                              ),
                            )
                          : _ProductsGrid(products: _products),
            ),
          ),
        ],
      ),
    );
  }
}

/*----------------------- SEGMENTED PILL -----------------------*/

class _SegmentedPill extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _SegmentedPill({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/*----------------------- STORES -----------------------*/

class _StoresList extends StatelessWidget {
  final List<Map<String, dynamic>> stores;
  const _StoresList({required this.stores});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: stores.length,
      separatorBuilder: (_, __) => const Divider(
          height: 1, thickness: .6, color: Color(0xFFEDEFF3)),
      itemBuilder: (ctx, i) => _StoreRow(store: stores[i], index: i),
    );
  }
}

class _StoreRow extends StatelessWidget {
  final Map<String, dynamic> store;
  final int index;
  const _StoreRow({required this.store, required this.index});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();
    final isRTL = languageService.isArabic;
    final storeName = isRTL && store['nameAr'] != null && store['nameAr'].toString().isNotEmpty
        ? store['nameAr'].toString()
        : (store['name']?.toString() ?? 'Store');
    final storeLogo = store['logoUrl']?.toString() ?? 'assets/images/zara.jpg';
    final ratingValue = store['rating'];
    final rating = ratingValue is String 
        ? (double.tryParse(ratingValue) ?? 0.0)
        : (ratingValue is num ? ratingValue.toDouble() : 0.0);
    final hasDeal = store['hasDeal'] == true;
    final storeId = store['id'] as int?;
    
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        AppRouter.navigateToStoreDetails(
          context,
          storeId: storeId,
          storeName: storeName,
          storeLogo: storeLogo,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEDEFF3), width: 1),
              ),
              child: ClipOval(
                child: _buildStoreLogo(storeLogo),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row: Name + Deal chip
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          storeName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (hasDeal)
                        _chip(
                          text: '%',
                          bg: const Color(0xFFFEF2F2),
                          fg: const Color(0xFFE11D48),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Second row: Rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStoreLogo(String logoUrl) {
    final isNetworkImage = logoUrl.startsWith('http://') || logoUrl.startsWith('https://');
    
    if (isNetworkImage) {
      return Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.store_rounded,
          color: const Color(0xFF0F172A).withValues(alpha: 0.55),
        ),
      );
    } else {
      return Image.asset(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.store_rounded,
          color: const Color(0xFF0F172A).withValues(alpha: 0.55),
        ),
      );
    }
  }

  Widget _chip({required String text, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/*----------------------- PRODUCTS -----------------------*/

class _ProductsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  const _ProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(product: products[i], index: i),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;
  const _ProductCard({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();
    final isRTL = languageService.isArabic;
    
    final productName = isRTL && product['nameAr'] != null && product['nameAr'].toString().isNotEmpty
        ? product['nameAr'].toString()
        : (product['name']?.toString() ?? 'Product');
    
    final priceValue = product['price'];
    final price = priceValue is String
        ? (double.tryParse(priceValue) ?? 0.0)
        : (priceValue is num ? priceValue.toDouble() : 0.0);
    final priceText = 'JD ${price.toStringAsFixed(2)}';
    
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () async {
          final productUrl = product['productUrl']?.toString();
          if (productUrl != null && productUrl.isNotEmpty) {
            try {
              final uri = Uri.parse(productUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (EnvDev.enableLogging) {
                  print('❌ Cannot launch URL: $productUrl');
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.cannotOpenUrl),
                    ),
                  );
                }
              }
            } catch (e) {
              if (EnvDev.enableLogging) {
                print('❌ Error opening URL: $e');
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.errorOpeningUrl),
                  ),
                );
              }
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.noStoreUrlAvailable),
                ),
              );
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: _buildProductImage(),
            ),
            // Information
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    priceText,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
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
  
  Widget _buildProductImage() {
    final imagesList = product['images'] as List<dynamic>?;
    final imageUrl = product['imageUrl']?.toString() ??
        (imagesList != null && imagesList.isNotEmpty
            ? imagesList[0]?.toString()
            : null);
    
    final isNetworkImage = imageUrl != null && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    
    if (imageUrl != null) {
      return isNetworkImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 40),
              ),
            )
          : Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 40),
              ),
            );
    } else {
      return Container(
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 40),
      );
    }
  }
}
