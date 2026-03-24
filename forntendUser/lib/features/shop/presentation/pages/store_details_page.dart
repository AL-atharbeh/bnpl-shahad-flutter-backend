import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../utils/image_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/store_service.dart';
import '../../../../config/env/env_dev.dart';

class StoreDetailsPage extends StatefulWidget {
  final int? storeId;
  final String? storeName;
  final String? logoImage;
  final String? bannerImage;
  final double? rating;
  final int? reviewsCount;
  final String? description;

  const StoreDetailsPage({
    super.key,
    this.storeId,
    this.storeName,
    this.logoImage,
    this.bannerImage,
    this.rating,
    this.reviewsCount,
    this.description,
  });

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  final StoreService _storeService = StoreService();
  
  Map<String, dynamic>? _storeData;
  List<Map<String, dynamic>> _products = [];
  bool _isLoadingStore = true;
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    if (widget.storeId != null) {
      _loadStoreData();
      _loadProducts();
    } else {
      setState(() {
        _isLoadingStore = false;
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _loadStoreData() async {
    if (widget.storeId == null) return;

    setState(() => _isLoadingStore = true);

    try {
      final response = await _storeService.getStoreById(widget.storeId!);
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic storeData;
        if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            storeData = backendData['data'];
          } else if (backendData['data'] != null) {
            storeData = backendData['data'];
          } else {
            storeData = backendData;
          }
        } else {
          storeData = backendData;
        }
        
        if (storeData is Map) {
          setState(() {
            _storeData = storeData as Map<String, dynamic>;
            _isLoadingStore = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded store data: ${_storeData!['name']}');
          }
        } else {
          setState(() => _isLoadingStore = false);
        }
      } else {
        setState(() => _isLoadingStore = false);
      }
    } catch (e) {
      setState(() => _isLoadingStore = false);
      if (EnvDev.enableLogging) {
        debugPrint('❌ Failed to load store data: $e');
      }
    }
  }

  Future<void> _loadProducts() async {
    if (widget.storeId == null) return;

    setState(() => _isLoadingProducts = true);

    try {
      final response = await _storeService.getStoreProducts(widget.storeId!);
      
      if (EnvDev.enableLogging) {
        print('📦 Products Response Type: ${response.runtimeType}');
        print('📦 Products Response Keys: ${response.keys}');
      }
      
      if (response['success'] == true) {
        dynamic backendData = response['data'];
        
        if (EnvDev.enableLogging) {
          print('📦 Backend Data Type: ${backendData.runtimeType}');
        }
        
        // ApiService wraps: { success: true, data: { success: true, data: [...] } }
        // أو قد يكون: { success: true, data: [...] }
        dynamic productsData;
        
        if (backendData is List) {
          // إذا كان List مباشرة، استخدمه
          productsData = backendData;
          if (EnvDev.enableLogging) {
            print('✅ Backend data is already a List with ${productsData.length} items');
          }
        } else if (backendData is Map) {
          // إذا كان Map، استخرج 'data' منه
          if (backendData['data'] != null) {
            productsData = backendData['data'];
            if (EnvDev.enableLogging) {
              print('✅ Extracted data from Map: ${productsData.runtimeType}');
            }
          } else {
            // إذا لم يكن هناك 'data'، استخدم الـ Map نفسه (غير متوقع)
            productsData = backendData;
            if (EnvDev.enableLogging) {
              print('⚠️ No data key in Map, using Map itself');
            }
          }
        } else {
          productsData = backendData;
        }
        
        // التحقق من أن productsData هو List
        if (productsData is List) {
          final productsList = productsData.map((p) {
            if (p is Map<String, dynamic>) {
              return p;
            } else if (p is Map) {
              return Map<String, dynamic>.from(p);
            } else {
              return <String, dynamic>{};
            }
          }).toList();
          
          setState(() {
            _products = productsList;
            _isLoadingProducts = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_products.length} products');
            if (_products.isNotEmpty) {
              print('📦 First product ID: ${_products[0]['id']}');
              print('📦 First product Name: ${_products[0]['name']}');
            } else {
              print('⚠️ Products list is empty');
            }
          }
        } else {
          if (EnvDev.enableLogging) {
            print('❌ Products data is not a List. Type: ${productsData.runtimeType}');
            print('❌ Products data: $productsData');
          }
          setState(() {
            _products = [];
            _isLoadingProducts = false;
          });
        }
      } else {
        if (EnvDev.enableLogging) {
          print('❌ Failed to load products: ${response['error']}');
        }
        setState(() {
          _products = [];
          _isLoadingProducts = false;
        });
      }
    } catch (e, stackTrace) {
      if (EnvDev.enableLogging) {
        debugPrint('❌ Failed to load products: $e');
        debugPrint('❌ Stack trace: $stackTrace');
      }
      setState(() {
        _products = [];
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _openStoreUrl() async {
    if (EnvDev.enableLogging) {
      print('🔗 Opening store URL...');
      print('📦 Store data: $_storeData');
    }
    
    // Get store URL from store data
    String? storeUrl;
    if (_storeData != null) {
      // Try multiple possible keys
      final storeUrlValue = _storeData!['storeUrl'];
      final websiteUrlValue = _storeData!['websiteUrl'];
      final storeUrlSnake = _storeData!['store_url'];
      final websiteUrlSnake = _storeData!['website_url'];
      
      storeUrl = (storeUrlValue?.toString().trim()) ?? 
                 (websiteUrlValue?.toString().trim()) ??
                 (storeUrlSnake?.toString().trim()) ??
                 (websiteUrlSnake?.toString().trim());
      
      if (EnvDev.enableLogging) {
        print('🔗 Found storeUrl: $storeUrl');
        print('🔗 storeUrl key: $storeUrlValue');
        print('🔗 websiteUrl key: $websiteUrlValue');
      }
    } else {
      if (EnvDev.enableLogging) {
        print('❌ Store data is null');
      }
    }
    
    if (storeUrl == null || storeUrl.isEmpty) {
      if (EnvDev.enableLogging) {
        print('❌ No store URL available');
      }
      // Show error message if no URL available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noStoreUrlAvailable),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    // Ensure URL has protocol
    if (!storeUrl.startsWith('http://') && !storeUrl.startsWith('https://')) {
      storeUrl = 'https://$storeUrl';
    }
    
    if (EnvDev.enableLogging) {
      print('🔗 Final URL: $storeUrl');
    }
    
    try {
      final uri = Uri.parse(storeUrl);
      if (EnvDev.enableLogging) {
        print('🔗 Parsed URI: $uri');
      }
      
      if (await canLaunchUrl(uri)) {
        if (EnvDev.enableLogging) {
          print('✅ Launching URL: $uri');
        }
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (EnvDev.enableLogging) {
          print('❌ Cannot launch URL: $storeUrl');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cannotOpenUrl),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      if (EnvDev.enableLogging) {
        debugPrint('❌ Error launching URL: $e');
        debugPrint('❌ Stack trace: $stackTrace');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorOpeningUrl}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Getters with fallback to widget parameters
  String get storeName {
    if (_storeData != null) {
      final isRTL = Directionality.of(context) == TextDirection.rtl;
      return isRTL && _storeData!['nameAr'] != null
          ? _storeData!['nameAr'] as String
          : _storeData!['name'] as String;
    }
    return widget.storeName ?? 'Store';
  }

  String get logoImage {
    if (_storeData != null && _storeData!['logoUrl'] != null) {
      return _storeData!['logoUrl'] as String;
    }
    return widget.logoImage ?? 'assets/images/zara.jpg';
  }

  String get bannerImage {
    // Use logo as banner if no banner available
    return widget.bannerImage ?? logoImage;
  }

  double get rating {
    if (_storeData != null && _storeData!['rating'] != null) {
      final ratingValue = _storeData!['rating'];
      if (ratingValue is String) {
        return double.tryParse(ratingValue) ?? 0.0;
      } else if (ratingValue is num) {
        return ratingValue.toDouble();
      }
    }
    return widget.rating ?? 4.5;
  }

  int get reviewsCount {
    if (_storeData != null && _storeData!['reviewsCount'] != null) {
      return _storeData!['reviewsCount'] as int;
    }
    return widget.reviewsCount ?? 0;
  }

  String get description {
    if (_storeData != null) {
      final isRTL = Directionality.of(context) == TextDirection.rtl;
      if (isRTL && _storeData!['descriptionAr'] != null) {
        return _storeData!['descriptionAr'] as String;
      }
      if (_storeData!['description'] != null) {
        return _storeData!['description'] as String;
      }
    }
    return widget.description ?? '';
  }

  static const _text = Color(0xFF121826);
  static const _sub = Color(0xFF6B7280);
  static const _chip = Color(0xFFF1F5F9);
  static const _surface = Color(0xFFF7F8FA);
  static const _stroke = Color(0xFFE6EAF0);

  String _formatCount(int n, AppLocalizations l10n) {
    if (n >= 1000000) return l10n.millionReviews((n/1000000).toStringAsFixed(1));
    if (n >= 1000) return l10n.thousandReviews((n/1000).toStringAsFixed(0));
    return '($n) ${l10n.reviews}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Show loading indicator if store data is loading
    if (_isLoadingStore && widget.storeId != null) {
      return Scaffold(
        backgroundColor: _surface,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ===== الهيدر =====
              SliverAppBar(
                elevation: 0,
                pinned: true,
                expandedHeight: 300,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: _glassIconButton(
                    context,
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: _glassIconButton(
                      context,
                      icon: Icons.ios_share_rounded,
                      onTap: () {}, // زر مشاركة
                      tooltip: l10n.share,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ImageHelper.buildImage(
                        imageUrl: bannerImage,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.store, size: 64, color: Color(0xFF6B7280)),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black38],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: 20,
                        end: 20,
                        bottom: 18,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // لوجو دائري
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                                                                        color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: ImageHelper.buildImage(
                                  imageUrl: logoImage,
                                  fit: BoxFit.cover,
                                  errorWidget: Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Icon(Icons.store, size: 32, color: Color(0xFF6B7280)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== محتوى الصفحة =====
              SliverToBoxAdapter(
                child: _curvedTopContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _ratingChip(rating, _formatCount(reviewsCount, l10n)),
                          const SizedBox(width: 8),
                          _onlineOnlyChip(l10n),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        description,
                        style: const TextStyle(color: _sub, fontSize: 14, height: 1.6),
                      ),

                      // Products Section
                      const SizedBox(height: 26),
                      _sectionTitle(l10n.products),
                      const SizedBox(height: 12),
                      _isLoadingProducts
                          ? const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ))
                          : _products.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Center(
                                    child: Text(
                                      l10n.emptyProducts,
                                      style: const TextStyle(color: _sub),
                                    ),
                                  ),
                                )
                              : _ProductsGrid(products: _products, l10n: l10n),

                      // Offers Section (if store has deal)
                      if (_storeData?['hasDeal'] == true) ...[
                        const SizedBox(height: 26),
                        _sectionTitle(l10n.offers),
                        const SizedBox(height: 12),
                        _offerCard(isRTL, l10n),
                      ],

                      const SizedBox(height: 28),
                      _sectionTitle('${rating.toStringAsFixed(1)} ${_formatCount(reviewsCount, l10n)}'),
                      const SizedBox(height: 14),
                      _ratingBars(l10n),

                      const SizedBox(height: 22),
                      _reviewBubble(
                        l10n: l10n,
                        name: l10n.dalal,
                        date: l10n.august2025,
                        text: l10n.dalalReview,
                      ),
                      const SizedBox(height: 12),
                      _reviewBubble(
                        l10n: l10n,
                        name: l10n.mai,
                        date: l10n.may2025,
                        text: l10n.maiReview,
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // زر أسود ثابت
          PositionedDirectional(
            start: 16,
            end: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: _primaryCTA(
              label: l10n.visitEcommerceStore,
              onTap: () => _openStoreUrl(),
            ),
          ),
        ],
      ),
    );
  }

  // ==== Widgets مساعدة ====

  Widget _curvedTopContainer({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: child,
    );
  }

  Widget _glassIconButton(BuildContext context,
      {required IconData icon, required VoidCallback onTap, String? tooltip}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Material(
          color: Colors.white.withValues(alpha: 0.25),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Tooltip(
                message: tooltip ?? '',
                child: Icon(icon, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingChip(double rating, String countText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _chip,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFF9800), size: 18),
          const SizedBox(width: 6),
          Text(
            '${rating.toStringAsFixed(1)}  $countText',
            style: const TextStyle(fontWeight: FontWeight.w700, color: _text),
          ),
        ],
      ),
    );
  }

  Widget _onlineOnlyChip(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(0xFFBDE9CE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_rounded, color: Color(0xFF10B981), size: 18),
          const SizedBox(width: 6),
          Text(l10n.onlineOnly, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F5132))),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: _text,
      ),
    );
  }

  Widget _offerCard(bool isRTL, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _stroke),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/banner1.jpg',
              width: 140,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 44),
                  child: Column(
                    crossAxisAlignment:
                        isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(l10n.shein,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, color: _text)),
                      const SizedBox(height: 8),
                      Text('${l10n.upTo} %90',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: _text)),
                      const SizedBox(height: 2),
                      Text(l10n.enjoyBestOffers,
                          style: const TextStyle(color: _sub)),
                    ],
                  ),
                ),
                PositionedDirectional(
                  end: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: ImageHelper.buildImage(
                        imageUrl: logoImage,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBars(AppLocalizations l10n) {
    final good = 0.78, ok = 0.46, bad = 0.18;
    return Column(
      children: [
        _barItem(l10n.excellent, good, const Color(0xFF111827)),
        const SizedBox(height: 8),
        _barItem(l10n.good, ok, const Color(0xFF374151)),
        const SizedBox(height: 8),
        _barItem(l10n.poor, bad, const Color(0xFF9CA3AF)),
      ],
    );
  }

  Widget _barItem(String title, double ratio, Color fill) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Stack(
              children: [
                Container(height: 8, color: _stroke),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(height: 8, color: fill),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: _sub, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _reviewBubble({
    required AppLocalizations l10n,
    required String name,
    required String date,
    required String text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _stroke),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l10n.excellentReview,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: _text)),
              const Spacer(),
              Text('$name · $date',
                  style: const TextStyle(color: _sub, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: _text, height: 1.6)),
        ],
      ),
    );
  }

  Widget _primaryCTA({required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Products Horizontal List Widget
class _ProductsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final AppLocalizations l10n;

  const _ProductsGrid({required this.products, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return SizedBox(
      height: 280, // ارتفاع ثابت للقائمة الأفقية
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          final product = products[index];
          final productName = isRTL && product['nameAr'] != null && product['nameAr'].toString().isNotEmpty
              ? product['nameAr'].toString()
              : (product['name']?.toString() ?? 'Product');
          
          // Handle price - can be string or number
          double price = 0.0;
          if (product['price'] != null) {
            if (product['price'] is String) {
              price = double.tryParse(product['price'] as String) ?? 0.0;
            } else if (product['price'] is num) {
              price = (product['price'] as num).toDouble();
            }
          }
          
          // Handle images
          final imagesList = product['images'] as List<dynamic>?;
          final imageUrl = product['imageUrl']?.toString() ??
              (imagesList != null && imagesList.isNotEmpty
                  ? imagesList[0]?.toString()
                  : null);
          
          // Handle product URL
          final productUrlValue = product['productUrl'];
          final productUrlSnake = product['product_url'];
          final productUrl = (productUrlValue?.toString().trim()) ??
                            (productUrlSnake?.toString().trim());

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _ProductCard(
              name: productName,
              price: price,
              imageUrl: imageUrl,
              productId: product['id'] as int,
              productUrl: productUrl,
            ),
          );
        },
      ),
    );
  }
}

// Product Card Widget
class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final String? imageUrl;
  final int productId;
  final String? productUrl;

  const _ProductCard({
    required this.name,
    required this.price,
    this.imageUrl,
    required this.productId,
    this.productUrl,
  });
  
  Future<void> _openProductUrl() async {
    if (productUrl == null || productUrl!.isEmpty) {
      if (EnvDev.enableLogging) {
        print('❌ No product URL available for product $productId');
      }
      return;
    }
    
    // Ensure URL has protocol
    String url = productUrl!;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    if (EnvDev.enableLogging) {
      print('🔗 Opening product URL: $url');
    }
    
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
        debugPrint('❌ Error launching product URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _openProductUrl,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 170, // عرض محسّن للبطاقة
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة المنتج مع overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      height: 190, // ارتفاع محسّن
                      width: double.infinity,
                      child: imageUrl != null && imageUrl!.startsWith('http')
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFF1F5F9),
                                        const Color(0xFFE7EDF3),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A66A)),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFF1F5F9),
                                      const Color(0xFFE7EDF3),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 56,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            )
                          : imageUrl != null
                              ? Image.asset(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFFF1F5F9),
                                          const Color(0xFFE7EDF3),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 56,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFF1F5F9),
                                        const Color(0xFFE7EDF3),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 56,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                    ),
                  ),
                  // Gradient overlay في الأسفل للصورة
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // معلومات المنتج
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF121826),
                        height: 1.4,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // السعر
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'JD',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: const Color(0xFF121826).withValues(alpha: 0.7),
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          price.toStringAsFixed(2),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Color(0xFF121826),
                            height: 1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
