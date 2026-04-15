import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/product_service.dart';
import '../../../../config/env/env_dev.dart';
import '../../../../core/theme/app_colors.dart';

class ProductDetailsPage extends StatefulWidget {
  // إذا كان productId موجود، سيتم جلب البيانات من API
  final int? productId;
  
  // البيانات المباشرة (للتوافق مع الكود القديم)
  final List<String>? images;
  final String? title;
  final String? subtitle;
  final String? priceText;
  final String? oldPriceText;
  final int? discountPercent;
  final String? storeName;
  final String? storeLogo;
  final bool? onlineOnly;
  final Map<String, String>? attributes;

  const ProductDetailsPage({
    super.key,
    this.productId,
    this.images,
    this.title,
    this.subtitle,
    this.priceText,
    this.oldPriceText,
    this.discountPercent,
    this.storeName,
    this.storeLogo,
    this.onlineOnly,
    this.attributes,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final PageController _pageController;
  int _page = 0;
  final ProductService _productService = ProductService();

  // Size options examples - replace with what suits you
  List<String> _sizes = [];
  
  // Data loaded from API
  bool _isLoading = false;
  Map<String, dynamic>? _productData;
  
  // Computed getters for product data
  List<String> get _images {
    if (_productData != null) {
      final imagesList = _productData!['images'] as List<dynamic>?;
      final imageUrl = _productData!['imageUrl']?.toString();
      if (imagesList != null && imagesList.isNotEmpty) {
        return imagesList.map((e) => e.toString()).toList();
      } else if (imageUrl != null) {
        return [imageUrl];
      }
    }
    return widget.images ?? [];
  }
  
  String get _title {
    if (_productData != null) {
      final isRTL = Directionality.of(context) == TextDirection.rtl;
      if (isRTL && _productData!['nameAr'] != null) {
        return _productData!['nameAr'].toString();
      }
      return _productData!['name']?.toString() ?? '';
    }
    return widget.title ?? '';
  }
  
  String get _subtitle {
    if (_productData != null) {
      final isRTL = Directionality.of(context) == TextDirection.rtl;
      if (isRTL && _productData!['descriptionAr'] != null) {
        return _productData!['descriptionAr'].toString();
      }
      return _productData!['description']?.toString() ?? '';
    }
    return widget.subtitle ?? '';
  }
  
  String get _priceText {
    if (_productData != null) {
      final price = _productData!['price'];
      double priceValue = 0.0;
      if (price is String) {
        priceValue = double.tryParse(price) ?? 0.0;
      } else if (price is num) {
        priceValue = price.toDouble();
      }
      return 'JD ${priceValue.toStringAsFixed(2)}';
    }
    return widget.priceText ?? '';
  }
  
  String get _storeName {
    if (_productData != null) {
      final store = _productData!['store'];
      if (store != null) {
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        if (isRTL && store['nameAr'] != null) {
          return store['nameAr'].toString();
        }
        return store['name']?.toString() ?? '';
      }
    }
    return widget.storeName ?? '';
  }
  
  String get _storeLogo {
    if (_productData != null) {
      final store = _productData!['store'];
      if (store != null && store['logoUrl'] != null) {
        return store['logoUrl'].toString();
      }
    }
    return widget.storeLogo ?? '';
  }
  
  Map<String, String> get _attributes {
    if (_productData != null) {
      final attrs = <String, String>{};
      if (_productData!['category'] != null) {
        attrs['Category'] = _productData!['category'].toString();
      }
      if (_productData!['currency'] != null) {
        attrs['Currency'] = _productData!['currency'].toString();
      }
      return attrs;
    }
    return widget.attributes ?? {};
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.productId != null) {
      _loadProductData();
    }
  }
  
  Future<void> _loadProductData() async {
    if (widget.productId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await _productService.getProductById(widget.productId!);
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic productData;
        
        if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            productData = backendData['data'];
          } else if (backendData['data'] != null) {
            productData = backendData['data'];
          } else {
            productData = backendData;
          }
        } else {
          productData = backendData;
        }
        
        if (productData is Map) {
          setState(() {
            _productData = productData as Map<String, dynamic>;
            _isLoading = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded product data: ${_productData!['name']}');
          }
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
        if (EnvDev.enableLogging) {
          print('❌ Failed to load product: ${response['error']}');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (EnvDev.enableLogging) {
        debugPrint('❌ Failed to load product: $e');
      }
    }
  }

  void _initializeSizes(AppLocalizations l10n) {
    if (_sizes.isNotEmpty) return; // Already initialized
    _sizes = [l10n.oneSize, '-', '-', '-', '-', '-', '-', l10n.eu];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get isRTL => Directionality.of(context) == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;
    
    // Show loading indicator if loading product data
    if (_isLoading && widget.productId != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Initialize sizes with localized strings
    _initializeSizes(l10n);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Image slider inside SliverAppBar
              SliverAppBar(
                pinned: false,
                floating: false,
                snap: false,
                elevation: 0,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                expandedHeight: 360,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemCount: _images.length,
                        itemBuilder: (_, i) => _safeImage(_images[i]),
                      ),
                                             // Light gradient below the image
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withValues(alpha: 0.08),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                                                                                           // Top slider buttons (back) + dots indicator
                       Positioned(
                         top: topPadding + 12,
                         left: 16,
                         child: _circleButton(
                           icon: isRTL ? Icons.arrow_forward : Icons.arrow_back,
                           onTap: () => Navigator.pop(context),
                         ),
                       ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _images.length,
                            (i) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _page == i
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

                             // Content
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                             // Title and description
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          _title,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          _subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                                             // Size/options bar
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          reverse: isRTL,
                          itemBuilder: (_, i) {
                            final label = _sizes[i];
                                                         final isSelected = i == 2; // Example selection highlight
                            return _chip(label, selected: isSelected);
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemCount: _sizes.length,
                        ),
                      ),
                      const SizedBox(height: 16),

                                             // Price + Discount + Store
                      Row(
                        children: [
                          _storeBlock(l10n),
                          const SizedBox(width: 12),
                          Expanded(child: _priceBlock()),
                        ],
                      ),
                      const SizedBox(height: 16),

                                             // Installment banner
                      _installmentBanner(l10n),
                      const SizedBox(height: 24),

                                             // Current offers (section title)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l10n.currentOffers,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                                             // Attributes table
                      _attributesTable(_attributes),
                                             const SizedBox(height: 120), // Space before bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),

                     // Floating bottom button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: _bottomCTA(l10n),
            ),
          ),
        ],
      ),
    );
  }

     // =================== UI Components ===================

  Widget _safeImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFE5E7EB),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1.5,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: const Color(0xFF111827), size: 22),
        ),
      ),
    );
  }

  Widget _chip(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF111827) : const Color(0xFFEFF3F7),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF111827),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _priceBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
                 // Current price
        Text(
          _priceText,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.oldPriceText != null)
              Text(
                widget.oldPriceText!,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (widget.discountPercent != null) ...[
              const SizedBox(width: 8),
              Text(
                "-${widget.discountPercent}%",
                style: const TextStyle(
                  color: Color(0xFFE11D48),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _storeBlock(AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFF1F5F9),
          child: _storeLogo.isNotEmpty
              ? (_storeLogo.startsWith('http')
                  ? ClipOval(
                      child: Image.network(
                        _storeLogo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.store, color: Color(0xFF111827)),
                      ),
                    )
                  : ClipOval(
                      child: Image.asset(
                        _storeLogo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.store, color: Color(0xFF111827)),
                      ),
                    ))
              : const Icon(Icons.store, color: Color(0xFF111827)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _storeName,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            if (widget.onlineOnly ?? true)
              Text(
                l10n.onlineOnly,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _installmentBanner(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.tabby,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${l10n.startingFrom} JD 0.825 ${l10n.monthly} / ${l10n.orIn4Installments}',
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attributesTable(Map<String, String> attrs) {
    final entries = attrs.entries.toList();
    return Column(
      children: List.generate(entries.length, (i) {
        final e = entries[i];
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      e.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  Widget _bottomCTA(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(26),
      ),
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
                     onTap: () {
             // TODO: Navigate to store/purchase
           },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.north_east, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.shop,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
