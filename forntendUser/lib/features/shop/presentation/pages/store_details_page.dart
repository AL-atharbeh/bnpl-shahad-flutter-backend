import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../utils/image_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/store_service.dart';
import '../../../../config/env/env_dev.dart';
import '../../../../core/theme/app_colors.dart';

// ==== Design System Tokens ====
const _text = Color(0xFF1E293B);
const _subStr = Color(0xFF64748B);
const _chipBg = Color(0xFFF8FAFC);
const _surfaceBg = Color(0xFFF8FAFC);
const _premiumNavy = Color(0xFF0F172A);
const _accentEmerald = AppColors.primary;
const _surface = Color(0xFFF7F8FA);
const _sub = Color(0xFF6B7280);
const _stroke = Color(0xFFE6EAF0);

class StoreDetailsPage extends StatefulWidget {
  final int? storeId;
  final String? storeName;
  final String? logoImage;
  final String? bannerImage;
  final int? categoryId;
  final double? rating;
  final int? reviewsCount;
  final String? description;

  const StoreDetailsPage({
    super.key,
    this.storeId,
    this.storeName,
    this.logoImage,
    this.bannerImage,
    this.categoryId,
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
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingStore = true;
  bool _isLoadingProducts = true;
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    if (widget.storeId != null) {
      _loadStoreData();
      _loadProducts();
      _loadReviews();
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

  Future<void> _loadReviews() async {
    if (widget.storeId == null) return;

    setState(() => _isLoadingReviews = true);

    try {
      final response = await _storeService.getStoreReviews(widget.storeId!);
      if (response['success'] == true) {
        dynamic backendData = response['data'];
        dynamic reviewsData;
        
        // Handle double wrapping: { success: true, data: { success: true, data: [...] } }
        if (backendData is List) {
          reviewsData = backendData;
        } else if (backendData is Map && backendData['data'] != null) {
          reviewsData = backendData['data'];
        } else {
          reviewsData = backendData;
        }

        if (reviewsData is List) {
          setState(() {
            _reviews = List<Map<String, dynamic>>.from(reviewsData);
            _isLoadingReviews = false;
          });
        } else {
          setState(() => _isLoadingReviews = false);
        }
      } else {
        setState(() => _isLoadingReviews = false);
      }
    } catch (e) {
      debugPrint('❌ Failed to load reviews: $e');
      setState(() => _isLoadingReviews = false);
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
    if (_storeData != null) {
      final img = _storeData!['logoUrl']?.toString() ?? 
                  _storeData!['logo_url']?.toString() ?? 
                  _storeData!['logo']?.toString();
      if (img != null && img.isNotEmpty) return img;
    }
    return widget.logoImage ?? 'assets/images/zara.jpg';
  }

  String get bannerImage {
    if (_storeData != null) {
      final img = _storeData!['bannerUrl']?.toString() ?? 
                  _storeData!['banner_url']?.toString() ?? 
                  _storeData!['coverUrl']?.toString() ??
                  _storeData!['cover_url']?.toString() ??
                  _storeData!['bannerImage']?.toString();
      if (img != null && img.isNotEmpty) return img;
    }
    
    // Check if we have a direct banner passed
    if (widget.bannerImage != null && widget.bannerImage!.isNotEmpty) {
      return widget.bannerImage!;
    }

    // Fallback to Category-specific banners
    final catId = widget.categoryId ?? (_storeData?['categoryId'] as int?) ?? (_storeData?['category_id'] as int?);
    if (catId != null) {
      switch (catId) {
        case 1: // Electronics
          return 'assets/images/banner1.jpeg'; 
        case 2: // Fashion
          return 'assets/images/clothes1.jpg';
        case 3: // Sports
          return 'assets/images/sport.jpg';
        case 4: // Books
          return 'assets/images/book.jpg';
      }
    }

    return logoImage;
  }

  double get rating {
    // If we have reviews loaded, calculate dynamic rating for maximum accuracy
    if (!_isLoadingReviews && _reviews.isNotEmpty) {
      final total = _reviews.fold<double>(0, (sum, rev) {
        final val = rev['rating'];
        double ratingVal = 5.0;
        if (val is num) {
          ratingVal = val.toDouble();
        } else if (val is String) {
          ratingVal = double.tryParse(val) ?? 5.0;
        }
        return sum + ratingVal;
      });
      return double.parse((total / _reviews.length).toStringAsFixed(1));
    }
    
    // Fallback to store data
    if (_storeData != null && _storeData!['rating'] != null) {
      final ratingValue = _storeData!['rating'];
      if (ratingValue is String) {
        return double.tryParse(ratingValue) ?? 0.0;
      } else if (ratingValue is num) {
        return ratingValue.toDouble();
      }
    }
    return widget.rating ?? 0.0;
  }

  int get reviewsCount {
    // If we have reviews loaded, use the actual count
    if (!_isLoadingReviews) {
      return _reviews.length;
    }
    
    // Fallback to store data if available
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ===== الهيدر العصري =====
              SliverAppBar(
                elevation: 0,
                pinned: true,
                expandedHeight: 320,
                stretch: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                leadingWidth: 60,
                leading: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: Center(
                    child: _glassIconButton(
                      context,
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: _glassIconButton(
                      context,
                      icon: Icons.ios_share_rounded,
                      onTap: () {},
                      tooltip: l10n.share,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // بانر المتجر
                      ImageHelper.buildImage(
                        imageUrl: bannerImage,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.storefront_rounded, size: 60, color: _subStr),
                        ),
                      ),
                      
                      // تظليل ناعم العلوي
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.35),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                            ],
                            stops: const [0.0, 0.25, 0.7, 1.0],
                          ),
                        ),
                      ),
                      
                      // لوجو طائر مع تفاصيل المتجر
                      PositionedDirectional(
                        start: 20,
                        end: 20,
                        bottom: 40,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return _headerFloatingCard(isRTL);
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== محتوى الصفحة =====
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _ratingChip(rating, _formatCount(reviewsCount, l10n)),
                                const SizedBox(width: 10),
                                _onlineOnlyChip(l10n),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _sectionTitle(l10n.aboutStore),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(
                                color: _subStr,
                                fontSize: 15,
                                height: 1.6,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Products Section
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _sectionTitle(l10n.products),
                      ),
                      const SizedBox(height: 16),
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
                      //_ratingBars(l10n), // Removed as requested

                      const SizedBox(height: 22),
                      _isLoadingReviews
                          ? const Center(child: CircularProgressIndicator())
                          : _reviews.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: Text(
                                      l10n.noReviewsYet ?? "لا توجد تقييمات بعد",
                                      style: const TextStyle(color: _sub),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 230, // Increased height for longer comments
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _reviews.length,
                                    itemBuilder: (context, i) {
                                      final rev = _reviews[i];
                                      return Container(
                                        width: MediaQuery.of(context).size.width * 0.85,
                                        margin: const EdgeInsets.only(right: 16),
                                        child: _reviewBubble(
                                          l10n: l10n,
                                          name: rev['authorName'] ?? 'Guest',
                                          date: rev['createdAt'] != null 
                                              ? rev['createdAt'].toString().split('T')[0]
                                              : '',
                                          text: (isRTL && rev['commentAr'] != null && rev['commentAr'].toString().isNotEmpty)
                                              ? rev['commentAr']
                                              : rev['comment'] ?? '',
                                          ratingValue: double.tryParse(rev['rating']?.toString() ?? '5.0') ?? 5.0,
                                        ),
                                      );
                                    },
                                  ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: child,
    );
  }

  // ==== Widgets المطورة ====

  Widget _headerFloatingCard(bool isRTL) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImageHelper.buildImage(
                imageUrl: logoImage,
                fit: BoxFit.cover,
                errorWidget: const Icon(Icons.store, color: _subStr),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _premiumNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                _locationIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationIndicator() {
        return Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 14, color: _accentEmerald),
            const SizedBox(width: 4),
            Text(
              'Online Store',
              style: TextStyle(
                fontSize: 13,
                color: _accentEmerald.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }

  Widget _glassIconButton(BuildContext context, {required IconData icon, required VoidCallback onTap, String? tooltip}) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Material(
              color: Colors.white.withOpacity(0.2),
              child: InkWell(
                onTap: onTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        );
      }

  Widget _ratingChip(double rating, String countText) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 6),
              Text(
                '${rating.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
              ),
              const SizedBox(width: 4),
              Text(
                countText,
                style: TextStyle(fontSize: 12, color: const Color(0xFF92400E).withOpacity(0.7), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }

  Widget _onlineOnlyChip(AppLocalizations l10n) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: _accentEmerald, size: 18),
              const SizedBox(width: 6),
              Text(
                l10n.onlineOnly,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF065F46), fontSize: 13),
              ),
            ],
          ),
        );
      }

  Widget _sectionTitle(String t) {
        return Text(
          t,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _premiumNavy,
            letterSpacing: -0.4,
          ),
        );
      }

  Widget _offerCard(bool isRTL, AppLocalizations l10n) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/banner1.jpg',
                  width: 130,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.shein,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: _subStr, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.upTo} %90',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _premiumNavy, letterSpacing: -1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.enjoyBestOffers,
                          style: const TextStyle(color: _subStr, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    PositionedDirectional(
                      end: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: _surfaceBg,
                          child: ClipOval(
                            child: ImageHelper.buildImage(
                              imageUrl: logoImage,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
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


  Widget _reviewBubble({required AppLocalizations l10n, required String name, required String date, required String text, double ratingValue = 5.0}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _stroke.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: _premiumNavy.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar Placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _premiumNavy.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: _premiumNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: _premiumNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        color: _subStr,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // Warm amber
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      ratingValue.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(
              color: _text,
              height: 1.6,
              fontSize: 15,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryCTA({required String label, required VoidCallback onTap}) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [_premiumNavy, Color(0xFF1E293B)]),
            boxShadow: [
              BoxShadow(
                color: _premiumNavy.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 0.2),
                ),
              ),
            ),
          ),
        );
  }
}

// ==== Products Horizontal List Widget ====
class _ProductsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final AppLocalizations l10n;

  const _ProductsGrid({
    super.key,
    required this.products,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          final product = products[index];
          final productName = (isRTL && product['nameAr'] != null && product['nameAr'].toString().isNotEmpty)
              ? product['nameAr'].toString()
              : (product['name']?.toString() ?? 'Product');

          double price = 0.0;
          if (product['price'] != null) {
            if (product['price'] is String) {
              price = double.tryParse(product['price'] as String) ?? 0.0;
            } else if (product['price'] is num) {
              price = (product['price'] as num).toDouble();
            }
          }

          final imagesList = product['images'] as List<dynamic>?;
          final imageUrl = product['imageUrl']?.toString() ??
              (imagesList != null && imagesList.isNotEmpty ? imagesList[0]?.toString() : null);

          final productUrlValue = product['productUrl'];
          final productUrlSnake = product['product_url'];
          final productUrl = (productUrlValue?.toString().trim()) ?? (productUrlSnake?.toString().trim());

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

// ==== Product Card Widget ====
class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final String? imageUrl;
  final int productId;
  final String? productUrl;

  const _ProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.productId,
    this.productUrl,
  });

  Future<void> _openProductUrl() async {
    if (productUrl == null || productUrl!.isEmpty) return;

    String url = productUrl!;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ Error launching product URL: $e');
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
          width: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: ImageHelper.buildImage(
                        imageUrl: imageUrl ?? '',
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                            ),
                          ),
                          child: const Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _text, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('JD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _subStr)),
                            const SizedBox(width: 2),
                            Text(
                              price.toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _premiumNavy, letterSpacing: -0.5),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: _premiumNavy, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
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
