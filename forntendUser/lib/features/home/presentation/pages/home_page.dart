import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../../../../utils/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../services/language_service.dart';
import '../../../../services/banner_service.dart';
import '../../../../services/category_service.dart';
import '../../../../services/store_service.dart';
import '../../../../services/deal_service.dart';
import '../../../../services/promo_notification_service.dart';
import '../../../../services/payment_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/featured_brand_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routing/app_router.dart';
import '../../../../config/env/env_dev.dart';
import '../../../shopping/presentation/pages/shopping_page.dart';
import '../../../payments/presentation/pages/payments_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../payments/presentation/widgets/extend_due_date_sheet.dart';
import '../../../payments/presentation/widgets/payment_method_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  final BannerService _bannerService = BannerService();
  final CategoryService _categoryService = CategoryService();
  final StoreService _storeService = StoreService();
  final DealService _dealService = DealService();
  final PromoNotificationService _promoNotificationService = PromoNotificationService();
  final PaymentService _paymentService = PaymentService();
  final FeaturedBrandService _featuredBrandService = FeaturedBrandService();
  
  List<Map<String, dynamic>> _featuredBrands = [];
  bool _isLoadingFeaturedBrands = true;
  
  // Promo notification from database
  Map<String, dynamic>? _promoNotification;
  bool _isLoadingPromo = true;
  bool _showPromoBanner = true;
  late PageController _bannerPageController;
  late PageController _storesPageController;
  final GlobalKey _navBarKey = GlobalKey();
  double _dragProgress = 0.0;
  bool _isDragging = false;
  late AnimationController _bannerAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentBannerIndex = 0;
  int _currentStoresPage = 0;
  int _currentNavIndex = 0;
  
  // Banners from database
  List<Map<String, dynamic>> _banners = [];
  bool _isLoadingBanners = true;
  
  // Categories from database
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;
  
  // Top Stores from database
  List<Map<String, dynamic>> _topStores = [];
  bool _isLoadingStores = true;
  
  // Best Offers from database
  List<Map<String, dynamic>> _bestOffers = [];
  bool _isLoadingOffers = true;

  // Pending Payments from database
  List<Map<String, dynamic>> _pendingPayments = [];
  bool _isLoadingPendingPayments = true;







  // Legacy fallback banners (will be replaced by database banners)
  final List<String> _fallbackBannerImages = [
    'assets/images/banner1.jpeg',
  ];

  // Legacy fallback categories (will be replaced by database categories)
  final List<Map<String, dynamic>> _fallbackCategories = [
    {
      'id': 1,
      'titleAr': 'الإلكترونيات',
      'titleEn': 'Electronics',
      'subtitleAr': 'أجهزة ذكية',
      'subtitleEn': 'Smart Devices',
      'icon': Icons.devices,
      'image': 'assets/images/phone.jpg',
      'color': AppColors.primary,
    },
    {
      'id': 2,
      'titleAr': 'الملابس',
      'titleEn': 'Fashion',
      'subtitleAr': 'أزياء وإكسسوارات',
      'subtitleEn': 'Clothing & Accessories',
      'icon': Icons.checkroom, // Better icon for fashion
      'image': 'assets/images/zara.jpg', // Better generic image for fashion
      'color': AppColors.primary,
    },
    {
      'id': 3,
      'titleAr': 'الرياضة',
      'titleEn': 'Sports',
      'subtitleAr': 'معدات رياضية',
      'subtitleEn': 'Sports Equipment',
      'icon': Icons.sports_soccer,
      'image': 'assets/images/sport.jpg',
      'color': AppColors.primary,
    },
    {
      'id': 4,
      'titleAr': 'الكتب',
      'titleEn': 'Books',
      'subtitleAr': 'كتب ومجلات',
      'subtitleEn': 'Books & Magazines',
      'icon': Icons.book,
      'image': 'assets/images/book.jpg',
      'color': AppColors.primary,
    },
  ];

  // Best Offers from database (replaced static data)

  // Legacy fallback stores (will be replaced by database stores)
  final List<Map<String, dynamic>> _fallbackStores = [
    {
      'nameAr': 'زارا',
      'nameEn': 'Zara',
      'image': 'assets/images/zara.jpg',
      'icon': Icons.style,
      'categoryAr': 'أزياء',
      'categoryEn': 'Fashion',
      'rating': 4.8,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'ه&M',
      'nameEn': 'H&M',
      'image': 'assets/images/butti.jpg',
      'icon': Icons.style,
      'categoryAr': 'أزياء',
      'categoryEn': 'Fashion',
      'rating': 4.6,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'نايك',
      'nameEn': 'Nike',
      'image': 'assets/images/sport.jpg',
      'icon': Icons.sports_soccer,
      'categoryAr': 'رياضة',
      'categoryEn': 'Sports',
      'rating': 4.9,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'أديداس',
      'nameEn': 'Adidas',
      'image': 'assets/images/sport.jpg',
      'icon': Icons.sports_soccer,
      'categoryAr': 'رياضة',
      'categoryEn': 'Sports',
      'rating': 4.7,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'أبل',
      'nameEn': 'Apple',
      'image': 'assets/images/phone.jpg',
      'icon': Icons.phone_iphone,
      'categoryAr': 'إلكترونيات',
      'categoryEn': 'Electronics',
      'rating': 4.9,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'سامسونج',
      'nameEn': 'Samsung',
      'image': 'assets/images/phone.jpg',
      'icon': Icons.phone_android,
      'categoryAr': 'إلكترونيات',
      'categoryEn': 'Electronics',
      'rating': 4.5,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'أمازون',
      'nameEn': 'Amazon',
      'image': 'assets/images/book.jpg',
      'icon': Icons.shopping_cart,
      'categoryAr': 'تسوق',
      'categoryEn': 'Shopping',
      'rating': 4.8,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'إيكيا',
      'nameEn': 'IKEA',
      'image': 'assets/images/book.jpg',
      'icon': Icons.home,
      'categoryAr': 'منزل',
      'categoryEn': 'Home',
      'rating': 4.4,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'ستاربكس',
      'nameEn': 'Starbucks',
      'image': 'assets/images/phone.jpg',
      'icon': Icons.coffee,
      'categoryAr': 'مشروبات',
      'categoryEn': 'Beverages',
      'rating': 4.6,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'ماكدونالدز',
      'nameEn': 'McDonald\'s',
      'image': 'assets/images/phone.jpg',
      'icon': Icons.restaurant,
      'categoryAr': 'طعام',
      'categoryEn': 'Food',
      'rating': 4.3,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'ديزني',
      'nameEn': 'Disney',
      'image': 'assets/images/sport.jpg',
      'icon': Icons.movie,
      'categoryAr': 'ترفيه',
      'categoryEn': 'Entertainment',
      'rating': 4.9,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'نتفلكس',
      'nameEn': 'Netflix',
      'image': 'assets/images/sport.jpg',
      'icon': Icons.tv,
      'categoryAr': 'ترفيه',
      'categoryEn': 'Entertainment',
      'rating': 4.7,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'سبوتيفاي',
      'nameEn': 'Spotify',
      'image': 'assets/images/book.jpg',
      'icon': Icons.music_note,
      'categoryAr': 'موسيقى',
      'categoryEn': 'Music',
      'rating': 4.8,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'يوتيوب',
      'nameEn': 'YouTube',
      'image': 'assets/images/book.jpg',
      'icon': Icons.play_circle,
      'categoryAr': 'فيديو',
      'categoryEn': 'Video',
      'rating': 4.9,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'فيسبوك',
      'nameEn': 'Facebook',
      'image': 'assets/images/zara.jpg',
      'icon': Icons.facebook,
      'categoryAr': 'تواصل',
      'categoryEn': 'Social',
      'rating': 4.5,
      'color': AppColors.primary,
    },
    {
      'nameAr': 'تويتر',
      'nameEn': 'Twitter',
      'image': 'assets/images/butti.jpg',
      'icon': Icons.flutter_dash,
      'categoryAr': 'تواصل',
      'categoryEn': 'Social',
      'rating': 4.4,
      'color': AppColors.primary,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dragProgress = _currentNavIndex.toDouble();
    
    _bannerPageController = PageController();
    _storesPageController = PageController();
    _bannerAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _startAnimations();
    _startBannerAnimation();
    
    // Load data from database
    _loadBanners();
    _loadFeaturedBrands();
    _loadCategories();
    _loadTopStores();
    _loadBestOffers();
    _loadPromoNotification();
    _loadPendingPayments();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadBanners();
      _loadFeaturedBrands();
      _loadCategories();
      _loadTopStores();
      _loadBestOffers();
      _loadPendingPayments();
    }
  }
  
  
  Future<void> _loadBanners() async {
    setState(() => _isLoadingBanners = true);
    
    try {
      final response = await _bannerService.getAllBanners();
      
      if (response['success']) {
        final backendData = response['data'];
        final bannersData = backendData is List ? backendData : (backendData['data'] ?? backendData);
        
        if (bannersData is List) {
          setState(() {
            _banners = bannersData.map((banner) => {
              'id': banner['id'],
              'title': banner['titleAr'] ?? banner['title'] ?? '',
              'titleEn': banner['title'] ?? '',
              'imageUrl': banner['imageUrl'] ?? '',
              'linkUrl': banner['linkUrl'],
              'linkType': banner['linkType'] ?? 'none',
              'linkId': banner['linkId'],
              'description': banner['descriptionAr'] ?? banner['description'] ?? '',
              'descriptionEn': banner['description'] ?? '',
            }).toList();
            _isLoadingBanners = false;
          });
          
          // Update banner animation if we have banners
          if (_banners.isNotEmpty && _bannerPageController.hasClients) {
            _currentBannerIndex = 0;
            _bannerPageController.jumpToPage(0);
          }
          
          if (EnvDev.enableLogging) {
            print('🎯 Loaded ${_banners.length} banners from database');
          }
        } else {
          setState(() => _isLoadingBanners = false);
        }
      } else {
        setState(() => _isLoadingBanners = false);
        if (EnvDev.enableLogging) {
          print('❌ Failed to load banners: ${response['error']}');
        }
      }
    } catch (e) {
      setState(() => _isLoadingBanners = false);
      if (EnvDev.enableLogging) {
        print('❌ Error loading banners: $e');
      }
    }
  }
  
  Future<void> _loadFeaturedBrands() async {
    setState(() => _isLoadingFeaturedBrands = true);
    
    try {
      final response = await _featuredBrandService.getActiveFeaturedBrands();
      
      if (response['success']) {
        final backendData = response['data'];
        final brandsData = backendData is List ? backendData : (backendData['data'] ?? backendData);
        
        if (brandsData is List) {
          setState(() {
            _featuredBrands = brandsData.map((brand) => {
              'id': brand['id'],
              'storeId': brand['storeId'],
              'imageUrl': brand['imageUrl'] ?? '',
              'storeName': brand['storeName'] ?? brand['store']?['name'] ?? '',
              'storeNameAr': brand['storeNameAr'] ?? brand['store']?['nameAr'] ?? brand['store']?['name'] ?? '',
              'logoUrl': brand['logoUrl'] ?? brand['store']?['logoUrl'] ?? '',
              'rating': brand['store']?['rating'] != null 
                  ? (brand['store']?['rating'] is String 
                      ? double.tryParse(brand['store']?['rating']) ?? 0.0 
                      : (brand['store']?['rating'] as num).toDouble())
                  : 0.0,
              'categoryAr': brand['store']?['categoryRelation']?['nameAr'] ?? brand['store']?['category'] ?? '',
              'categoryEn': brand['store']?['categoryRelation']?['name'] ?? brand['store']?['category'] ?? '',
            }).toList();
            _isLoadingFeaturedBrands = false;
          });
          
          if (EnvDev.enableLogging) {
            print('🎯 Loaded ${_featuredBrands.length} featured brands from database');
          }
        } else {
          setState(() => _isLoadingFeaturedBrands = false);
        }
      } else {
        setState(() => _isLoadingFeaturedBrands = false);
        if (EnvDev.enableLogging) {
          print('❌ Failed to load featured brands: ${response['error']}');
        }
      }
    } catch (e) {
      setState(() => _isLoadingFeaturedBrands = false);
      if (EnvDev.enableLogging) {
        print('❌ Error loading featured brands: $e');
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    
    try {
      final response = await _categoryService.getAllCategories();
      
      if (response['success']) {
        final backendData = response['data'];
        final categoriesData = backendData is List ? backendData : (backendData['data'] ?? backendData);
        
        if (categoriesData is List) {
          // Map icon names to Flutter icons
          final iconMap = {
            'devices': Icons.devices,
            'style': Icons.style,
            'sports_soccer': Icons.sports_soccer,
            'sports': Icons.sports_soccer,
            'book': Icons.book,
            'home': Icons.home,
            'shopping_bag': Icons.shopping_bag,
            'restaurant': Icons.restaurant,
            'fitness_center': Icons.fitness_center,
            'spa': Icons.spa,
            'directions_car': Icons.directions_car,
            'drive_eta': Icons.directions_car,
            'face': Icons.face,
            'favorite': Icons.favorite,
            'toys': Icons.toys,
          };
          
          // Default colors for categories
          final defaultColors = [
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
          ];
          
          setState(() {
            _categories = categoriesData.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final iconName = category['icon'] ?? '';
              final icon = iconMap[iconName] ?? Icons.category;
              final color = defaultColors[index % defaultColors.length];
              
              return {
                'id': category['id'],
                'titleAr': category['nameAr'] ?? category['name'] ?? '',
                'titleEn': category['name'] ?? '',
                'subtitleAr': category['descriptionAr'] ?? category['description'] ?? '',
                'subtitleEn': category['description'] ?? '',
                'icon': icon,
                'image': category['imageUrl'] ?? _fallbackCategories[index % _fallbackCategories.length]['image'],
                'color': color,
                'storesCount': category['storesCount'] ?? 0,
              };
            }).toList();
            _isLoadingCategories = false;
          });
          
          if (EnvDev.enableLogging) {
            print('🎯 Loaded ${_categories.length} categories from database');
          }
        } else {
          setState(() => _isLoadingCategories = false);
        }
      } else {
        setState(() => _isLoadingCategories = false);
        if (EnvDev.enableLogging) {
          print('❌ Failed to load categories: ${response['error']}');
        }
      }
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      if (EnvDev.enableLogging) {
        print('❌ Error loading categories: $e');
      }
    }
  }
  
  Future<void> _loadTopStores() async {
    setState(() => _isLoadingStores = true);
    
    try {
      // Get only stores with top_store = 1
      final response = await _storeService.getAllStores(topStore: true);
      
      if (response['success']) {
        final backendData = response['data'];
        
        // Parse data - EXACT same logic as _loadBanners and _loadCategories
        // Backend returns: {success: true, data: [...]}
        // ApiService wraps it: {success: true, data: {success: true, data: [...]}}
        // So backendData = {success: true, data: [...]}
        // We need: backendData['data'] to get the actual array
        dynamic storesData;
        if (backendData is List) {
          storesData = backendData;
        } else if (backendData is Map) {
          // Check if it's a wrapped response
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
        
        if (EnvDev.enableLogging) {
          print('📦 Backend response data: $backendData');
          print('   Type: ${backendData.runtimeType}');
          if (backendData is Map) {
            print('   Keys: ${backendData.keys}');
            if (backendData['data'] != null) {
              print('   data type: ${backendData['data'].runtimeType}');
              if (backendData['data'] is List) {
                print('   data length: ${(backendData['data'] as List).length}');
              }
            }
          }
          print('📦 Stores data after parsing: $storesData');
          print('   Type: ${storesData.runtimeType}');
          print('   Is List: ${storesData is List}');
          if (storesData is List) {
            print('   Count: ${storesData.length}');
            if (storesData.isNotEmpty) {
              print('   First store ID: ${storesData[0]['id']}');
            }
          }
        }
        
        if (storesData is List && storesData.isNotEmpty) {
          // Map category names to icons
          final categoryIconMap = {
            'Fashion & Clothing': Icons.style,
            'الأزياء والملابس': Icons.style,
            'Electronics': Icons.devices,
            'الإلكترونيات': Icons.devices,
            'Sports & Outdoors': Icons.sports_soccer,
            'الرياضة والهواء الطلق': Icons.sports_soccer,
            'Books & Education': Icons.book,
            'الكتب والتعليم': Icons.book,
            'Home & Furniture': Icons.home,
            'المنزل والأثاث': Icons.home,
            'Beauty & Cosmetics': Icons.face,
            'الجمال ومستحضرات التجميل': Icons.face,
            'Food & Beverages': Icons.restaurant,
            'الطعام والمشروبات': Icons.restaurant,
            'Health & Wellness': Icons.favorite,
            'الصحة والعافية': Icons.favorite,
            'Toys & Games': Icons.toys,
            'الألعاب والألعاب': Icons.toys,
            'Automotive': Icons.directions_car,
            'السيارات': Icons.directions_car,
          };
          
          // Default colors for stores
          final defaultColors = [
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
          ];
          
          final mappedStores = storesData.asMap().entries.map((entry) {
            final index = entry.key;
            final store = entry.value;
            
            try {
              // Get category info
              final category = store['categoryRelation'] ?? {};
              final categoryName = category['name'] ?? category['nameAr'] ?? store['category'] ?? '';
              final categoryNameAr = category['nameAr'] ?? category['name'] ?? '';
              
              // Get icon from category
              final icon = categoryIconMap[categoryName] ?? 
                          categoryIconMap[categoryNameAr] ?? 
                          Icons.store;
              
              final color = defaultColors[index % defaultColors.length];
              
              // Get logo URL from database only
              final logoUrl = store['logoUrl'] ?? '';
              final image = logoUrl.isNotEmpty && (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'))
                  ? logoUrl
                  : (logoUrl.isNotEmpty ? logoUrl : 'assets/images/zara.jpg'); // Default fallback image only
              
              return {
                'id': store['id'],
                'nameAr': store['nameAr'] ?? store['name'] ?? '',
                'nameEn': store['name'] ?? '',
                'image': image,
                'icon': icon,
                'categoryAr': categoryNameAr.isNotEmpty ? categoryNameAr : (categoryName.isNotEmpty ? categoryName : 'عام'),
                'categoryEn': categoryName.isNotEmpty ? categoryName : 'General',
                'rating': store['rating'] != null 
                    ? (store['rating'] is String 
                        ? double.tryParse(store['rating']) ?? 0.0 
                        : (store['rating'] as num).toDouble())
                    : 0.0,
                'color': color,
                'hasDeal': store['hasDeal'] ?? false,
                'productsCount': store['productsCount'] ?? 0,
              };
            } catch (e) {
              if (EnvDev.enableLogging) {
                print('❌ Error mapping store at index $index: $e');
                print('   Store data: $store');
              }
              return null;
            }
          }).where((store) => store != null).cast<Map<String, dynamic>>().toList();
          
          setState(() {
            _topStores = mappedStores;
            _isLoadingStores = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Successfully mapped ${_topStores.length} stores');
          }
          
          // Reset page controller if stores changed
          if (_storesPageController.hasClients && _topStores.isNotEmpty) {
            _currentStoresPage = 0;
            _storesPageController.jumpToPage(0);
          }
          
          if (EnvDev.enableLogging) {
            print('🎯 Loaded ${_topStores.length} stores from database');
          }
        } else {
          setState(() {
            _topStores = [];
            _isLoadingStores = false;
          });
          if (EnvDev.enableLogging) {
            print('⚠️ Stores data is not a list: $storesData');
          }
        }
      } else {
        setState(() {
          _topStores = [];
          _isLoadingStores = false;
        });
        if (EnvDev.enableLogging) {
          print('❌ Failed to load stores: ${response['error']}');
          print('   Full response: $response');
        }
      }
    } catch (e) {
      setState(() {
        _topStores = [];
        _isLoadingStores = false;
      });
      if (EnvDev.enableLogging) {
        print('❌ Error loading stores: $e');
        print('   Stack trace: ${StackTrace.current}');
      }
    }
  }
  
  Future<void> _loadBestOffers() async {
    setState(() => _isLoadingOffers = true);
    
    try {
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
          final languageService = Provider.of<LanguageService>(context, listen: false);
          final isArabic = languageService.isArabic;
          
          final mappedOffers = dealsData.map<Map<String, dynamic>>((deal) {
            final store = deal['store'] ?? {};
            final category = store['categoryRelation'] ?? {};
            
            final storeName = store['name'] ?? '';
            final storeNameAr = store['nameAr'] ?? storeName;
            final storeLogo = store['logoUrl'] ?? 'assets/images/zara.jpg';
            
            final discountValue = deal['discountValue'] ?? deal['discountLabel'] ?? '';
            final discountLabel = deal['discountLabel'] ?? '';
            final discount = discountValue.isNotEmpty 
                ? discountValue 
                : (discountLabel.isNotEmpty ? discountLabel : '10%');
            
            final description = isArabic 
                ? (deal['descriptionAr'] ?? deal['description'] ?? 'على أصناف مختارة')
                : (deal['description'] ?? deal['descriptionAr'] ?? 'ON SELECTED ITEMS');
            
            final imageUrl = deal['imageUrl'] ?? storeLogo;
            
            // Generate badge color based on discount
            Color badgeColor = const Color(0xFFD1FAE5);
            Color storeColor = AppColors.primary;
            if (discount.contains('20') || discount.contains('25')) {
              badgeColor = AppColors.primary;
              storeColor = AppColors.primary;
            } else if (discount.contains('15')) {
              badgeColor = const Color(0xFFA7F3D0);
              storeColor = AppColors.primary;
            }
            
            return {
              'storeNameAr': storeNameAr,
              'storeNameEn': storeName,
              'descriptionAr': isArabic ? description : '',
              'descriptionEn': !isArabic ? description : '',
              'discount': discount,
              'image': imageUrl,
              'logo': storeLogo,
              'badgeColor': badgeColor,
              'storeColor': storeColor,
              'storeUrl': deal['storeUrl'] ?? store['storeUrl'] ?? store['websiteUrl'],
            };
          }).toList();
          
          setState(() {
            _bestOffers = mappedOffers;
            _isLoadingOffers = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_bestOffers.length} offers from database');
          }
        } else {
          setState(() {
            _bestOffers = [];
            _isLoadingOffers = false;
          });
          if (EnvDev.enableLogging) {
            print('⚠️ Offers data is not a list: $dealsData');
          }
        }
      } else {
        setState(() {
          _bestOffers = [];
          _isLoadingOffers = false;
        });
        if (EnvDev.enableLogging) {
          print('❌ Failed to load offers: ${response['error']}');
        }
      }
    } catch (e) {
      setState(() {
        _bestOffers = [];
        _isLoadingOffers = false;
      });
      if (EnvDev.enableLogging) {
        print('❌ Error loading offers: $e');
      }
    }
  }
  
  Future<void> _handleBannerTap(Map<String, dynamic> banner) async {
    // Increment click count
    try {
      final bannerId = banner['id'];
      if (bannerId != null) {
        await _bannerService.incrementClickCount(bannerId);
      }
    } catch (e) {
      if (EnvDev.enableLogging) {
        print('❌ Error incrementing click count: $e');
      }
    }
    
    // Handle banner link
    final linkType = banner['linkType'] ?? 'none';
    final linkUrl = banner['linkUrl'];
    final linkId = banner['linkId'];
    
    if (linkType == 'external' && linkUrl != null) {
      // Open external URL
      final uri = Uri.parse(linkUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (linkType == 'product' && linkId != null) {
      // Navigate to product page
      // TODO: Implement product navigation when product service is ready
      if (EnvDev.enableLogging) {
        print('🔗 Navigate to product: $linkId');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('سيتم الانتقال إلى المنتج قريباً'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (linkType == 'store' && linkId != null) {
      // Navigate to store page
      // TODO: Implement store navigation when store service is ready
      if (EnvDev.enableLogging) {
        print('🔗 Navigate to store: $linkId');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('سيتم الانتقال إلى المتجر قريباً'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (linkType == 'category' && linkId != null) {
      // Navigate to category page
      // TODO: Implement category navigation when category page is ready
      if (EnvDev.enableLogging) {
        print('🔗 Navigate to category: $linkId');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('سيتم الانتقال إلى الفئة قريباً'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerPageController.dispose();
    _storesPageController.dispose();
    _bannerAnimationController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }
  
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideAnimationController.forward();
  }

  void _startBannerAnimation() {
    _bannerAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_bannerPageController.hasClients) {
          final bannersCount = _banners.isNotEmpty ? _banners.length : _fallbackBannerImages.length;
          if (bannersCount > 0) {
            _currentBannerIndex = (_currentBannerIndex + 1) % bannersCount;
            _bannerPageController.animateToPage(
              _currentBannerIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
        _bannerAnimationController.reset();
        _bannerAnimationController.forward();
      }
    });
    _bannerAnimationController.forward();
  }

  void _onNavDragUpdate(DragUpdateDetails details) {
    if (_navBarKey.currentContext == null) return;
    
    final RenderBox box = _navBarKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    final double width = box.size.width;
    
    // Use the reliable LanguageService from Provider
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final bool isArabic = languageService.isArabic;
    
    // Improved mapping: divide width into 4 equal segments
    double progress = (localOffset.dx / (width / 4)) - 0.5;
    progress = progress.clamp(0.0, 3.0);
    
    // If Arabic mode (RTL), index 0 is on the physical right.
    // dx=0 (left) should map to index 3, dx=width (right) should map to index 0.
    double logicalProgress = isArabic ? (3.0 - progress) : progress;
    
    int hoverIndex = logicalProgress.round();
    
    if (_isDragging && hoverIndex != _currentNavIndex) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _dragProgress = logicalProgress;
      _isDragging = true;
    });
  }

  void _onNavDragEnd() {
    int finalIndex = _dragProgress.round().clamp(0, 3);
    setState(() {
      _isDragging = false;
      _currentNavIndex = finalIndex;
      _dragProgress = finalIndex.toDouble();
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content based on selected tab
          _buildCurrentPage(),
          
          // Glassmorphism Bottom Navigation
          _buildGlassmorphismBottomNav(),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    return _getCurrentPageContent();
  }

  Widget _getCurrentPageContent() {
    return IndexedStack(
      index: _currentNavIndex,
      children: [
        _buildHomePage(),
        const ShoppingPage(),
        const PaymentsPage(),
        _buildProfilePage(),
      ],
    );
  }



  Widget _buildHomePage() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        displacement: 40,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              // Header Section
              // _buildHeader(),
              
           
              
              // Search Bar
              _buildSearchBar(),
              SizedBox(height: 5),
                 // Promotional Banner - Moved to top
              if (_showPromoBanner) _buildPromoBanner(),
              // Pending Payments Section
              _buildPendingPayments(),
              
              // Modern Banner Section
              _buildModernBanner(),
              
              // Store Cards Section
              _buildStoreCards(),
              
              // Featured Brands Section
              _buildFeaturedBrandsSection(),
              
              // Categories Section
              _buildCategoriesSection(),
              
              // Best Offers Section
              _buildBestOffersSection(),
              
              // Top Stores Section
              _buildTopStoresSection(),
              
              // Add bottom padding for floating navbar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadPromoNotification() async {
    setState(() => _isLoadingPromo = true);
    
    try {
      final response = await _promoNotificationService.getPromoNotifications();
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic notificationsData;
        
        if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            notificationsData = backendData['data'];
          } else if (backendData['data'] != null) {
            notificationsData = backendData['data'];
          } else {
            notificationsData = backendData;
          }
        } else if (backendData is List) {
          notificationsData = backendData;
        } else {
          notificationsData = backendData;
        }
        
        if (notificationsData is List && notificationsData.isNotEmpty) {
          // Get the first active promo notification
          final notification = notificationsData[0];
          setState(() {
            _promoNotification = notification is Map<String, dynamic>
                ? notification
                : Map<String, dynamic>.from(notification as Map);
            _isLoadingPromo = false;
            _showPromoBanner = true;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded promo notification: ${_promoNotification?['title']}');
          }
        } else {
          setState(() {
            _promoNotification = null;
            _isLoadingPromo = false;
            _showPromoBanner = false;
          });
        }
      } else {
        setState(() {
          _promoNotification = null;
          _isLoadingPromo = false;
          _showPromoBanner = false;
        });
      }
    } catch (e) {
      setState(() {
        _promoNotification = null;
        _isLoadingPromo = false;
        _showPromoBanner = false;
      });
      if (EnvDev.enableLogging) {
        print('❌ Error loading promo notification: $e');
      }
    }
  }

  Future<void> _loadPendingPayments() async {
    setState(() => _isLoadingPendingPayments = true);
    
    try {
      // Check if user is logged in
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      final token = await authService.getSavedToken();
      
      if (!isLoggedIn || token == null || token.isEmpty) {
        setState(() {
          _pendingPayments = [];
          _isLoadingPendingPayments = false;
        });
        return;
      }
      
      // Ensure token is set in ApiService
      authService.setAuthToken(token);
      
      final response = await _paymentService.getPendingPayments();
      
      if (response['success']) {
        final backendData = response['data'];
        dynamic paymentsData;
        
        if (backendData is Map) {
          if (backendData['success'] == true && backendData['data'] != null) {
            paymentsData = backendData['data'];
          } else if (backendData['data'] != null) {
            paymentsData = backendData['data'];
          } else {
            paymentsData = backendData;
          }
        } else if (backendData is List) {
          paymentsData = backendData;
        } else {
          paymentsData = backendData;
        }
        
        if (paymentsData is List) {
          // Limit to 3 payments for home page display
          final limitedPayments = paymentsData.take(3).toList();
          
          setState(() {
            _pendingPayments = limitedPayments.map((item) {
              if (item is Map<String, dynamic>) {
                return item;
              } else if (item is Map) {
                return Map<String, dynamic>.from(item);
              } else {
                return <String, dynamic>{};
              }
            }).toList().cast<Map<String, dynamic>>();
            _isLoadingPendingPayments = false;
          });
          
          if (EnvDev.enableLogging) {
            print('✅ Loaded ${_pendingPayments.length} pending payments for home page');
          }
        } else {
          setState(() {
            _pendingPayments = [];
            _isLoadingPendingPayments = false;
          });
        }
      } else {
        setState(() {
          _pendingPayments = [];
          _isLoadingPendingPayments = false;
        });
      }
    } catch (e) {
      setState(() {
        _pendingPayments = [];
        _isLoadingPendingPayments = false;
      });
      if (EnvDev.enableLogging) {
        print('❌ Error loading pending payments: $e');
      }
    }
  }

  Future<void> _handleRefresh() async {
    // إعادة تحميل البيانات من قاعدة البيانات
    await Future.wait([
      _loadBanners(),
      _loadFeaturedBrands(),
      _loadCategories(),
      _loadTopStores(),
      _loadBestOffers(),
      _loadPromoNotification(),
      _loadPendingPayments(),
    ]);
    
    // إعادة تعيين فهرس البانر
    if (_bannerPageController.hasClients) {
      _currentBannerIndex = 0;
      _bannerPageController.jumpToPage(0);
    }
    
    setState(() {
      _currentStoresPage = 0;
    });
    
    // إعادة تشغيل الرسوم المتحركة
    _bannerPageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    
    // إظهار رسالة نجاح
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.refreshComplete),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }



  Widget _buildProfilePage() {
    // عرض صفحة البروفايل مباشرة في نفس المكان
    return const ProfilePage();
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      child: Text(
        l10n.appName,
        style: AppTextStyles.changaH3,
      ),
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    return GestureDetector(
      onTap: () {
        if (kDebugMode) print('🔍 Home Search Bar Tapped');
        AppRouter.navigateToSearch(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.searchPlaceholder,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPayments() {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    // Hide section if no pending payments and not loading
    if (!_isLoadingPendingPayments && _pendingPayments.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.pendingPayments,
                  style: GoogleFonts.tajawal(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/payments'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.viewAllPayments,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _isLoadingPendingPayments
              ? SizedBox(
                  height: 110,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              : _pendingPayments.isEmpty
                  ? SizedBox(
                      height: 80,
                      child: Center(
                        child: Text(
                          l10n.noPaymentsFound,
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        reverse: false,
                        itemCount: _pendingPayments.length,
                        itemBuilder: (context, index) {
                          final payment = _pendingPayments[index];
                          return _buildPaymentCard(payment, isRTL);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment, bool isRTL) {
    // Extract data from payment (from database)
    final storeName = isRTL 
        ? (payment['storeNameAr']?.toString() ?? payment['merchantName']?.toString() ?? payment['storeName']?.toString() ?? payment['store']?['nameAr']?.toString() ?? payment['store']?['name']?.toString() ?? 'متجر')
        : (payment['storeName']?.toString() ?? payment['merchantName']?.toString() ?? payment['store']?['name']?.toString() ?? 'Store');
    
    final amountValue = payment['amount'];
    final amount = amountValue is num 
        ? amountValue.toDouble() 
        : (double.tryParse(amountValue.toString()) ?? 0.0);
    final amountText = 'JD ${amount.toStringAsFixed(3)}';
    
    // Calculate days left
    final dueDateStr = payment['dueDate']?.toString();
    int daysLeft = 30;
    String daysLeftText = '';
    bool isOverdue = false;
    if (dueDateStr != null) {
      try {
        final dueDate = DateTime.parse(dueDateStr);
        final now = DateTime.now();
        final difference = dueDate.difference(now).inDays;
        daysLeft = difference;
        isOverdue = difference < 0;
        
        if (difference < 0) {
          daysLeftText = isRTL ? 'متأخر' : 'Overdue';
        } else if (difference == 0) {
          daysLeftText = isRTL ? 'اليوم' : 'Today';
        } else if (difference == 1) {
          daysLeftText = isRTL ? 'غداً' : 'Tomorrow';
        } else {
          daysLeftText = isRTL ? '$difference يوم' : '$difference days';
        }
      } catch (e) {
        daysLeftText = isRTL ? 'تاريخ غير صحيح' : 'Invalid date';
      }
    }
    
    final installmentNumber = payment['installmentNumber'] as int? ?? 1;
    final installmentsCount = payment['installmentsCount'] as int? ?? 1;
    
    // Progress calculation
    final progress = installmentsCount > 0 ? installmentNumber / installmentsCount : 0.0;
    
    // Accent color based on urgency
    final accentColor = isOverdue 
        ? const Color(0xFFEF4444) 
        : (daysLeft <= 3 ? const Color(0xFFF59E0B) : AppColors.primary);
    
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/payments'),
      child: Container(
        width: 280,
        margin: const EdgeInsetsDirectional.only(end: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accentColor.withOpacity(0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Store name + Amount
            Row(
              children: [
                // Store icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                // Store name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      Text(
                        isRTL ? 'القسط $installmentNumber من $installmentsCount' : 'Payment $installmentNumber of $installmentsCount',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Text(
                  amountText,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Bottom: Progress bar + Days left
            Row(
              children: [
                // Progress bar
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(0.6),
                              accentColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Days left badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daysLeftText,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBanner() {
    final languageService = Provider.of<LanguageService>(context);
    final isArabic = languageService.isArabic;
    
    // Use database banners if available, otherwise use fallback
    List<Map<String, dynamic>> allBanners = _banners.isNotEmpty 
        ? _banners 
        : _fallbackBannerImages.map((img) => {'imageUrl': img}).toList();
    
    final bannersToShow = allBanners;
    final bannersCount = bannersToShow.length;
    
    if (_isLoadingBanners && _banners.isEmpty) {
      return _buildBannerShimmer();
    }
    
    if (bannersCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          // ── Main Carousel ──
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _bannerPageController,
              padEnds: true,
              onPageChanged: (index) {
                setState(() => _currentBannerIndex = index);
                // Reset auto-scroll timer on manual swipe
                _bannerAnimationController.reset();
                _bannerAnimationController.forward();
              },
              itemCount: bannersCount,
              itemBuilder: (context, index) {
                final banner = bannersToShow[index];
                return _buildBannerCard(banner, index, bannersCount);
              },
            ),
          ),
          
          const SizedBox(height: 14),
          
          // ── Indicator Row ──
          _buildBannerIndicator(bannersCount),
        ],
      ),
    );
  }
  
  /// A single banner card with glassmorphism overlay and parallax image
  Widget _buildBannerCard(Map<String, dynamic> banner, int index, int totalCount) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final isArabic = languageService.isArabic;
    final imageUrl = banner['imageUrl'] ?? '';
    final title = isArabic 
        ? (banner['title'] ?? banner['titleEn'] ?? '') 
        : (banner['titleEn'] ?? banner['title'] ?? '');
    final description = isArabic 
        ? (banner['description'] ?? banner['descriptionEn'] ?? '') 
        : (banner['descriptionEn'] ?? banner['description'] ?? '');
    
    return GestureDetector(
      onTap: () {
        if (_banners.isNotEmpty && index < _banners.length) {
          _handleBannerTap(_banners[index]);
        }
      },
      child: AnimatedBuilder(
        animation: _bannerPageController,
        builder: (context, child) {
          double pageOffset = 0;
          try {
            if (_bannerPageController.hasClients && 
                _bannerPageController.position.hasContentDimensions) {
              pageOffset = _bannerPageController.page! - index;
            }
          } catch (_) {}
          
          // Smooth scale: center = 1.0, sides = 0.92
          final scale = (1 - (pageOffset.abs() * 0.08)).clamp(0.92, 1.0);
          // Smooth opacity: center = 1.0, sides fade
          final opacity = (1 - (pageOffset.abs() * 0.4)).clamp(0.6, 1.0);
          
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Background Image ──
                ImageHelper.buildImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: _buildBannerPlaceholder(),
                  errorWidget: _buildFallbackBanner(index),
                ),
                
                // ── Cinematic Gradient Overlay ──
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.35, 0.65, 1.0],
                      colors: [
                        Colors.black.withOpacity(0.10),
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
                  ),
                ),
                
                // ── Side Gradient (left edge) ──
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                        end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                        stops: const [0.0, 0.4],
                        colors: [
                          Colors.black.withOpacity(0.20),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // ── Glassmorphism Info Chip (bottom-left) ──
                if (title.isNotEmpty || description.isNotEmpty)
                  Positioned(
                    bottom: 14,
                    left: isArabic ? null : 14,
                    right: isArabic ? 14 : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.55,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (title.isNotEmpty)
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.85),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // ── Page Counter Badge (top-right) ──
                Positioned(
                  top: 12,
                  right: isArabic ? null : 12,
                  left: isArabic ? 12 : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          '${index + 1} / $totalCount',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Animated indicator with gradient progress line and dots
  Widget _buildBannerIndicator(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = _currentBannerIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3.5),
            width: isActive ? 28 : 7,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: isActive
                  ? const LinearGradient(
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                      ],
                    )
                  : null,
              color: isActive ? null : Colors.grey.shade300,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
  
  /// Shimmer loading placeholder for banner
  Widget _buildBannerShimmer() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 200,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade100,
        ),
        child: Stack(
          children: [
            // Shimmer sweep
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: -1.0, end: 2.0),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, _) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.grey.shade200,
                            Colors.grey.shade100,
                            Colors.grey.shade200,
                          ],
                          stops: [
                            (value - 0.3).clamp(0.0, 1.0),
                            value.clamp(0.0, 1.0),
                            (value + 0.3).clamp(0.0, 1.0),
                          ],
                        ).createShader(bounds);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                  onEnd: () {},
                ),
              ),
            ),
            // Placeholder icon
            Center(
              child: Icon(
                Icons.panorama_rounded,
                size: 42,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Loading placeholder shown while images are loading
  Widget _buildBannerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.7),
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFallbackBanner(int index) {
    // Gradient mesh pattern fallback
    final gradients = [
      [const Color(0xFF065F46), const Color(0xFF10B981), const Color(0xFF34D399)],
      [const Color(0xFF064E3B), const Color(0xFF047857), const Color(0xFF10B981)],
      [const Color(0xFF065F46), const Color(0xFF059669), const Color(0xFF6EE7B7)],
    ];
    final colors = gradients[index % gradients.length];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    size: 32,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'عرض خاص',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCards() {
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(
        children: [
          // All Stores Button
          Expanded(
            child: _buildActionButton(
              title: isRTL ? 'جميع المتاجر' : 'All Stores',
              subtitle: isRTL ? 'اكتشف المتاجر' : 'Explore stores',
              icon: Icons.storefront_rounded,
              gradientColors: [const Color(0xFF065F46), const Color(0xFF10B981)],
              onTap: () => AppRouter.navigateToAllStores(context),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Deals Button
          Expanded(
            child: _buildActionButton(
              title: isRTL ? 'العروض' : 'Deals',
              subtitle: isRTL ? 'خصومات حصرية' : 'Exclusive offers',
              icon: Icons.local_offer_rounded,
              gradientColors: [const Color(0xFF047857), const Color(0xFF34D399)],
              onTap: () => AppRouter.navigateToOffers(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle decorative circle
            Positioned(
              top: -15,
              right: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStoresSection() {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    // Show only database stores - no fallback
    if (_isLoadingStores && _topStores.isEmpty) {
      // Show loading placeholder
      return Container(
        margin: const EdgeInsets.only(top: 32, left: 20, right: 20),
        height: 250,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Only show stores from database - if empty, hide the section
    if (_topStores.isEmpty) {
      if (EnvDev.enableLogging) {
        // print('⚠️ No stores to display. _topStores is empty.');
      }
      return const SizedBox.shrink();
    }
    
    if (EnvDev.enableLogging) {
    //  print('✅ Displaying ${_topStores.length} stores in Top Stores section');
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.topStores,
                      style: AppTextStyles.changaH4,
                    ),
                    Text(
                      l10n.totalStores(_topStores.length),
                      style: GoogleFonts.mada(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.viewAllStores),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: Text(
                    l10n.viewAllStores,
                    style: GoogleFonts.mada(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: _topStores.length <= 4 ? 130 : 250,
            child: PageView.builder(
              controller: _storesPageController,
              reverse: false,
              onPageChanged: (index) {
                setState(() {
                  _currentStoresPage = index;
                });
              },
              itemCount: (_topStores.length / 8).ceil(),
              itemBuilder: (context, pageIndex) {
                return Container(
                  width: MediaQuery.of(context).size.width - 40,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final storeIndex = pageIndex * 8 + index;
                      if (storeIndex < _topStores.length) {
                        final store = _topStores[storeIndex];
                        return _buildTopStoreCard(store, isRTL);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
          if (_topStores.length > 8) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                (_topStores.length / 8).ceil(),
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentStoresPage 
                        ? AppColors.primary
                        : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopStoreCard(Map<String, dynamic> store, bool isRTL) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () {
            AppRouter.navigateToStoreDetails(
              context,
              storeId: store['id'],
              storeName: isRTL ? store['nameAr'] : store['nameEn'],
              storeLogo: store['image'],
              storeBanner: store['image'], // Use logo as banner
              rating: store['rating'] ?? 0.0,
              reviewsCount: 0,
              description: isRTL ? store['categoryAr'] : store['categoryEn'],
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modern Icon Container with Enhanced Effects
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      store['color'].withValues(alpha: 0.1),
                      store['color'].withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: store['color'].withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: store['color'].withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: store['color'].withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: store['color'].withValues(alpha: 0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: store['color'].withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildStoreImage(store),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Store Name
              Text(
                isRTL ? store['nameAr'] : store['nameEn'],
                style: AppTextStyles.madaLabelLarge,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStoreImage(Map<String, dynamic> store) {
    final imageUrl = store['image'] ?? '';
    return ImageHelper.buildImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorWidget: _buildStoreImageFallback(store),
      placeholder: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              store['color'].withValues(alpha: 0.3),
              store['color'].withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: store['color'],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStoreImageFallback(Map<String, dynamic> store) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            store['color'].withValues(alpha: 0.9),
            store['color'].withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          store['icon'],
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeaturedBrandsSection() {
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;

    if (_isLoadingFeaturedBrands && _featuredBrands.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
        height: 180,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_featuredBrands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? 'علامات تجارية مميزة' : 'Featured Brands',
                  style: AppTextStyles.changaH4.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isRTL ? 'تسوق من أشهر العلامات التجارية' : 'Shop from popular brands',
                  style: GoogleFonts.mada(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _featuredBrands.length,
              itemBuilder: (context, index) {
                final brand = _featuredBrands[index];
                return GestureDetector(
                  onTap: () {
                    AppRouter.navigateToStoreDetails(
                      context,
                      storeId: brand['storeId'],
                      storeName: isRTL ? brand['storeNameAr'] : brand['storeName'],
                      storeLogo: brand['logoUrl'],
                      storeBanner: brand['logoUrl'],
                      rating: brand['rating'] ?? 0.0,
                      reviewsCount: 0,
                      description: isRTL ? brand['categoryAr'] : brand['categoryEn'],
                    );
                  },
                  child: Container(
                    width: 190,
                    margin: EdgeInsets.only(
                      left: isRTL ? 0 : 16,
                      right: isRTL ? 16 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ImageHelper.buildImage(
                              imageUrl: brand['imageUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.05),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.4, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 14,
                            right: isRTL ? 14 : null,
                            left: isRTL ? null : 14,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.95),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: ImageHelper.buildImage(
                                  imageUrl: brand['logoUrl'],
                                  fit: BoxFit.cover,
                                  errorWidget: Center(
                                    child: Text(
                                      brand['storeName'].isNotEmpty ? brand['storeName'][0].toUpperCase() : 'B',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 14,
                            right: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRTL ? brand['storeNameAr'] : brand['storeName'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      brand['rating'].toStringAsFixed(1),
                                      style: GoogleFonts.mada(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        isRTL ? brand['categoryAr'] : brand['categoryEn'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.mada(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.75),
                                        ),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    // Use database categories if available, otherwise use fallback
    final categoriesToShow = _categories.isNotEmpty ? _categories : _fallbackCategories;
    
    if (_isLoadingCategories && _categories.isEmpty) {
      // Show loading placeholder
      return Container(
        margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
        height: 160,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (categoriesToShow.isEmpty) {
      // No categories available
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRTL ? 'التصنيفات' : 'Categories',
                      style: AppTextStyles.changaH4,
                    ),
                    Text(
                      isRTL ? 'تصفح حسب النوع' : 'Browse by type',
                      style: GoogleFonts.mada(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              reverse: false,
              itemCount: categoriesToShow.length,
              itemBuilder: (context, index) {
                final category = categoriesToShow[index];
                return CategoryCard(category: category, isRTL: isRTL);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStoreLogoImage(String logoUrl, Color fallbackColor, String storeName) {
    final fallback = Container(
      decoration: BoxDecoration(
        color: fallbackColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          storeName.isNotEmpty ? storeName[0].toUpperCase() : 'S',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
    return ImageHelper.buildImage(
      imageUrl: logoUrl,
      fit: BoxFit.cover,
      errorWidget: fallback,
    );
  }

  Widget _buildBestOffersSection() {
    // Hide the entire section if it's done loading and there are no offers
    if (!_isLoadingOffers && _bestOffers.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    return Container(
      margin: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.bestOffers,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                GestureDetector(
                  onTap: () => AppRouter.navigateToOffers(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.viewAllOffers,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          (_isLoadingOffers && _bestOffers.isEmpty)
              ? SizedBox(
                  height: 220,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              : _bestOffers.isEmpty
                  ? SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          l10n.noOffersFound,
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        reverse: false,
                        itemCount: _bestOffers.length,
                        itemBuilder: (context, index) {
                          final offer = _bestOffers[index];
                          return _buildOfferCard(offer, isRTL);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, bool isRTL) {
    final l10n = AppLocalizations.of(context)!;
    
    // Handle image
    final imageUrl = offer['image']?.toString() ?? '';
    final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    
    // Handle store URL
    final storeUrlValue = offer['storeUrl'];
    final storeUrl = (storeUrlValue?.toString().trim()) ?? '';
    
    Future<void> openStoreUrl() async {
      if (storeUrl.isEmpty) {
        if (EnvDev.enableLogging) {
          print('❌ No store URL available for offer');
        }
        return;
      }
      
      String url = storeUrl;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        if (EnvDev.enableLogging) {
          debugPrint('❌ Error launching store URL: $e');
        }
      }
    }
    
    final storeName = isRTL 
        ? (offer['storeNameAr']?.toString() ?? '') 
        : (offer['storeNameEn']?.toString() ?? '');
    final descriptionText = isRTL 
        ? (offer['descriptionAr']?.toString() ?? '') 
        : (offer['descriptionEn']?.toString() ?? '');

    return GestureDetector(
      onTap: openStoreUrl,
      child: Container(
        width: 200,
        margin: const EdgeInsetsDirectional.only(end: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  // Image
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(17),
                        topRight: Radius.circular(17),
                      ),
                      child: Stack(
                        children: [
                          // Background Image with Blur (Cover Fit)
                          Positioned.fill(
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: ImageHelper.buildImage(
                                imageUrl: imageUrl.isNotEmpty ? imageUrl : 'assets/images/photo.jpg',
                                fit: BoxFit.cover,
                                errorWidget: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary.withOpacity(0.7), AppColors.primaryDark],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.local_offer_rounded,
                                    color: Colors.white.withOpacity(0.4),
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Foreground Image (Contain Fit) to display the image fully without cropping
                          Positioned.fill(
                            child: ImageHelper.buildImage(
                              imageUrl: imageUrl.isNotEmpty ? imageUrl : 'assets/images/photo.jpg',
                              fit: BoxFit.contain,
                              errorWidget: const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Discount badge
                  Positioned(
                    bottom: 8,
                    left: isRTL ? null : 10,
                    right: isRTL ? 10 : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        '${offer['discount']}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store info row
                    Row(
                      children: [
                        // Store logo
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: _buildStoreLogoImage(
                              offer['logo']?.toString() ?? '',
                              offer['storeColor'] as Color? ?? AppColors.primary,
                              storeName,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Description
                    if (descriptionText.isNotEmpty)
                      Text(
                        descriptionText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                          height: 1.3,
                        ),
                      ),
                    const Spacer(),
                    // Visit store link
                    Row(
                      children: [
                        Text(
                          l10n.visitStore,
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildPromoBanner() {
    final l10n = AppLocalizations.of(context)!;
    final languageService = LanguageService();
    final isRTL = languageService.isArabic;
    
    // If no promo notification, don't show banner
    if (_promoNotification == null) {
      return const SizedBox.shrink();
    }
    
    final title = isRTL 
        ? (_promoNotification!['titleAr']?.toString() ?? _promoNotification!['title']?.toString() ?? l10n.priceCompare)
        : (_promoNotification!['title']?.toString() ?? l10n.priceCompare);
    final subtitle = isRTL
        ? (_promoNotification!['subtitleAr']?.toString() ?? _promoNotification!['subtitle']?.toString() ?? l10n.comparePrice)
        : (_promoNotification!['subtitle']?.toString() ?? l10n.comparePrice);
    
    // Parse background color (default to green gradient)
    final bgColor = _promoNotification!['backgroundColor']?.toString() ?? '#10B981';
    final textColor = _promoNotification!['textColor']?.toString() ?? '#FFFFFF';
    
    Color backgroundColor;
    try {
      backgroundColor = Color(int.parse(bgColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      backgroundColor = AppColors.primary;
    }
    
    Color textColorParsed;
    try {
      textColorParsed = Color(int.parse(textColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      textColorParsed = Colors.white;
    }
    
    return GestureDetector(
      onTap: () async {
        // Handle promo notification click
        final linkType = _promoNotification!['linkType']?.toString() ?? 'none';
        final linkUrl = _promoNotification!['linkUrl']?.toString();
        final linkId = _promoNotification!['linkId'];
        final notificationId = _promoNotification!['id'];
        
        // Increment click count
        if (notificationId != null) {
          try {
            await _promoNotificationService.incrementClick(notificationId as int);
          } catch (e) {
            if (EnvDev.enableLogging) {
              print('❌ Error incrementing click count: $e');
            }
          }
        }
        
        // Handle navigation based on link type
        if (linkType == 'external' && linkUrl != null && linkUrl.isNotEmpty) {
          final uri = Uri.parse(linkUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } else if (linkType == 'category' && linkId != null) {
          // Navigate to category
          final categoryName = isRTL ? 'الفئة' : 'Category';
          AppRouter.navigateToCategoryBrowse(
            context,
            categoryName: categoryName,
            categoryId: linkId as int?,
          );
        } else if (linkType == 'store' && linkId != null) {
          // Navigate to store details
          AppRouter.navigateToStoreDetails(
            context,
            storeId: linkId as int?,
          );
        } else if (linkType == 'product' && linkId != null) {
          // Navigate to product details
          AppRouter.navigateToProductDetails(
            context,
            productId: linkId as int?,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              backgroundColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.changa(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColorParsed,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.mada(
                        fontSize: 12,
                        color: textColorParsed.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showPromoBanner = false;
                });
              },
              icon: Icon(
                Icons.close,
                color: textColorParsed,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showPaymentDetailsModal(BuildContext context, Map<String, dynamic> payment, bool isRTL) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      isRTL ? payment['title'] : payment['titleEn'],
                      style: GoogleFonts.changa(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Payment Summary
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: isRTL ? '${payment['dueDate']} ' : '${l10n.dueIn} ${payment['daysLeftEn']} ',
                            style: GoogleFonts.mada(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: isRTL ? '· الدفعة 4 من 4 · ${payment['amount']}' : '· Payment 4 of 4 · ${payment['amountEn']}',
                            style: GoogleFonts.mada(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Items
                    _buildActionItem(
                      icon: Icons.calendar_today,
                      title: l10n.extendDueDate,
                      subtitle: l10n.forUpTo,
                      onTap: () {
                        Navigator.pop(context);
                        
                        // Sample extend options - you can customize these based on your business logic
                        final options = [
                          ExtendOption(
                            days: 7,
                            feeLabel: 'JD 0.500',
                            targetDateLabel: 'مُمدّد إلى ${payment['dueDate']}',
                          ),
                          ExtendOption(
                            days: 14,
                            feeLabel: 'JD 0.950',
                            targetDateLabel: 'مُمدّد إلى ${payment['dueDate']}',
                            popular: true,
                          ),
                          ExtendOption(
                            days: 30,
                            feeLabel: 'JD 1.500',
                            targetDateLabel: 'مُمدّد إلى ${payment['dueDate']}',
                          ),
                        ];

                        ExtendDueDateSheet.show(
                          context,
                          merchantName: isRTL ? payment['title'] : payment['titleEn'],
                          originalAmountLabel: isRTL ? payment['amount'] : payment['amountEn'],
                          originalDueLabel: isRTL ? payment['dueDate'] : payment['dueDateEn'],
                          options: options,
                          onConfirm: (selectedOption) {
                            // Handle the extend confirmation
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم تمديد تاريخ الاستحقاق بنجاح'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildActionItem(
                      icon: Icons.credit_card,
                      title: l10n.payAmount(isRTL ? payment['amount'] : payment['amountEn']),
                      subtitle: '',
                      onTap: () {
                        Navigator.pop(context);
                        PaymentMethodSheet.show(
                          context,
                          amountLabel: isRTL ? payment['amount'] : payment['amountEn'],
                          amount: 0,
                          onApplePay: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم الدفع بنجاح عبر Apple Pay'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          onCardAdded: (card) {
                            print('تمت إضافة بطاقة جديدة: ${card.last4}');
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.financialGreen200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.financialGreen50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF64748B),
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.mada(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.mada(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildGlassmorphismBottomNav() {
    final languageService = Provider.of<LanguageService>(context);
    final bool isArabic = languageService.isArabic;
    
    return Positioned(
      left: 50, // Slightly wider margin for a more balanced layout
      right: 50,
      bottom: 30,
      child: GestureDetector(
        onHorizontalDragUpdate: _onNavDragUpdate,
        onHorizontalDragEnd: (_) => _onNavDragEnd(),
        onLongPressStart: (details) {
          HapticFeedback.heavyImpact();
          _onNavDragUpdate(DragUpdateDetails(globalPosition: details.globalPosition));
        },
        onLongPressMoveUpdate: (details) {
          _onNavDragUpdate(DragUpdateDetails(globalPosition: details.globalPosition));
        },
        onLongPressEnd: (_) => _onNavDragEnd(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              key: _navBarKey,
              height: 70, // Sleeker, more compact height
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82), // Beautiful frosted white background
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85), // Clean hairline border
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), // Extremely soft, calm shadow
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // World-Class Fluid Indicator - Refined Proportion
                  AnimatedAlign(
                    duration: Duration(milliseconds: _isDragging ? 80 : 500),
                    curve: _isDragging ? Curves.linear : Curves.easeOutBack,
                    alignment: Alignment(
                      (isArabic ? -1.0 : 1.0) * (_dragProgress - 1.5) * 0.61, 
                      0.0,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.15, // Slimmer pill
                      height: 56, // Increased from 48 to accommodate larger icons
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF10B981),
                            Color(0xFF059669),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Icons with Liquid Transition
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(Icons.grid_view_rounded, 0),
                      _buildNavIcon(Icons.shopping_bag_rounded, 1),
                      _buildNavIcon(Icons.account_balance_wallet_rounded, 2),
                      _buildNavIcon(Icons.person_rounded, 3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    // Distance from the current drag progress
    final double distance = (_dragProgress - index).abs();
    final double proximity = (1.0 - distance).clamp(0.0, 1.0);
    
    final double scale = 0.85 + (proximity * 0.2); // More subtle scale
    final Color iconColor = Color.lerp(
      const Color(0xFF64748B), // Soft slate grey for a calm, professional look
      Colors.white,
      Curves.easeIn.transform(proximity),
    )!;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _currentNavIndex = index;
            _dragProgress = index.toDouble();
          });
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Icon(
                  icon,
                  size: 30, // Increased from 24 for better visibility
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 5),
              // Subtler dot
              Container(
                width: 4 * proximity,
                height: 4 * proximity,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: proximity * 0.8), // Branded active green dot
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final Map<String, dynamic> category;
  final bool isRTL;

  const CategoryCard({super.key, required this.category, required this.isRTL});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  Uint8List? _imageBytes;
  bool _isBase64 = false;

  @override
  void initState() {
    super.initState();
    _initImage();
  }

  @override
  void didUpdateWidget(CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.category['image'] != oldWidget.category['image']) {
      _initImage();
    }
  }

  void _initImage() {
    final imageUrl = widget.category['image'] ?? '';
    if (ImageHelper.isBase64DataUrl(imageUrl)) {
      _isBase64 = true;
      _imageBytes = ImageHelper.decodeBase64DataUrl(imageUrl);
    } else {
      _isBase64 = false;
      _imageBytes = null;
    }
  }

  Widget _buildFallback() {
    final category = widget.category;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category['color'].withValues(alpha: 0.8),
            category['color'].withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Icon(
        category['icon'],
        color: Colors.white,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final isRTL = widget.isRTL;

    return GestureDetector(
      onTap: () {
        final categoryId = category['id'] as int?;
        final categoryName = isRTL ? category['titleAr'] : category['titleEn'];
        
        if (EnvDev.enableLogging) {
          print('🔍 Navigating to category: $categoryName (ID: $categoryId)');
        }
        
        AppRouter.navigateToCategoryBrowse(
          context,
          categoryName: categoryName,
          categoryId: categoryId,
        );
      },
      child: Container(
        key: ValueKey(category['id'] ?? category['titleEn']),
        width: 120,
        height: 160,
        margin: const EdgeInsetsDirectional.only(end: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 0,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Image Container inside the card with its own rounded corners
                  Container(
                    width: double.infinity,
                    height: 110,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _isBase64 && _imageBytes != null
                          ? Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildFallback(),
                            )
                          : ImageHelper.buildImage(
                              imageUrl: category['image'],
                              fit: BoxFit.cover,
                              errorWidget: _buildFallback(),
                            ),
                    ),
                  ),
                  
                  // Text Container
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            isRTL ? category['titleAr'] : category['titleEn'],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.changa(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          
                          const SizedBox(height: 1),
                          
                          // Subtitle
                          Text(
                            isRTL ? category['subtitleAr'] : category['subtitleEn'],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mada(
                              fontSize: 8,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



