import 'dart:ui';
import '../../../../utils/image_helper.dart';
import 'package:flutter/material.dart';
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
  
  // Promo notification from database
  Map<String, dynamic>? _promoNotification;
  bool _isLoadingPromo = true;
  bool _showPromoBanner = true;
  late PageController _bannerPageController;
  late PageController _storesPageController;
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
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
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
      'color': const Color(0xFF10B981),
    },
    {
      'id': 2,
      'titleAr': 'الملابس',
      'titleEn': 'Fashion',
      'subtitleAr': 'أزياء وإكسسوارات',
      'subtitleEn': 'Clothing & Accessories',
      'icon': Icons.style,
      'image': 'assets/images/butti.jpg',
      'color': const Color(0xFF34D399),
    },
    {
      'id': 3,
      'titleAr': 'الرياضة',
      'titleEn': 'Sports',
      'subtitleAr': 'معدات رياضية',
      'subtitleEn': 'Sports Equipment',
      'icon': Icons.sports_soccer,
      'image': 'assets/images/sport.jpg',
      'color': const Color(0xFF6EE7B7),
    },
    {
      'id': 4,
      'titleAr': 'الكتب',
      'titleEn': 'Books',
      'subtitleAr': 'كتب ومجلات',
      'subtitleEn': 'Books & Magazines',
      'icon': Icons.book,
      'image': 'assets/images/book.jpg',
      'color': const Color(0xFF059669),
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
      'color': const Color(0xFF10B981),
    },
    {
      'nameAr': 'ه&M',
      'nameEn': 'H&M',
      'image': 'assets/images/butti.jpg',
      'icon': Icons.style,
      'categoryAr': 'أزياء',
      'categoryEn': 'Fashion',
      'rating': 4.6,
      'color': const Color(0xFF34D399),
    },
    {
      'nameAr': 'نايك',
      'nameEn': 'Nike',
      'image': 'assets/images/sport.jpg',
      'icon': Icons.sports_soccer,
      'categoryAr': 'رياضة',
      'categoryEn': 'Sports',
      'rating': 4.9,
      'color': const Color(0xFF6EE7B7),
    },
    {
      'nameAr': 'أديداس',
      'nameEn': 'Adidas',
      'image': 'assets/images/sport.jpg',
      'icon': Icons.sports_soccer,
      'categoryAr': 'رياضة',
      'categoryEn': 'Sports',
      'rating': 4.7,
      'color': const Color(0xFF059669),
    },
    {
      'nameAr': 'أبل',
      'nameEn': 'Apple',
      'image': 'assets/images/phone.jpg',
      'icon': Icons.phone_iphone,
      'categoryAr': 'إلكترونيات',
      'categoryEn': 'Electronics',
      'rating': 4.9,
      'color': const Color(0xFF10B981),
    },
    {
      'nameAr': 'سامسونج',
      'nameEn': 'Samsung',
      'image': 'assets/images/phone.jpg',
      'icon': Icons.phone_android,
      'categoryAr': 'إلكترونيات',
      'categoryEn': 'Electronics',
      'rating': 4.5,
      'color': const Color(0xFF34D399),
    },
    {
      'nameAr': 'أمازون',
      'nameEn': 'Amazon',
      'image': 'assets/images/book.jpg',
      'icon': Icons.shopping_cart,
      'categoryAr': 'تسوق',
      'categoryEn': 'Shopping',
      'rating': 4.8,
      'color': const Color(0xFF6EE7B7),
    },
    {
      'nameAr': 'إيكيا',
      'nameEn': 'IKEA',
      'image': 'assets/images/book.jpg',
      'icon': Icons.home,
      'categoryAr': 'منزل',
      'categoryEn': 'Home',
      'rating': 4.4,
      'color': const Color(0xFF059669),
    },
    {
      'nameAr': 'ستاربكس',
      'nameEn': 'Starbucks',
      'image': 'assets/images/phone.jpg',
      'icon': Icons.coffee,
      'categoryAr': 'مشروبات',
      'categoryEn': 'Beverages',
      'rating': 4.6,
      'color': const Color(0xFF10B981),
    },
    {
      'nameAr': 'ماكدونالدز',
      'nameEn': 'McDonald\'s',
      'image': 'assets/images/phone.jpg',
      'icon': Icons.restaurant,
      'categoryAr': 'طعام',
      'categoryEn': 'Food',
      'rating': 4.3,
      'color': const Color(0xFF34D399),
    },
    {
      'nameAr': 'ديزني',
      'nameEn': 'Disney',
      'image': 'assets/images/sport.jpg',
      'icon': Icons.movie,
      'categoryAr': 'ترفيه',
      'categoryEn': 'Entertainment',
      'rating': 4.9,
      'color': const Color(0xFF6EE7B7),
    },
    {
      'nameAr': 'نتفلكس',
      'nameEn': 'Netflix',
      'image': 'assets/images/sport.jpg',
      'icon': Icons.tv,
      'categoryAr': 'ترفيه',
      'categoryEn': 'Entertainment',
      'rating': 4.7,
      'color': const Color(0xFF059669),
    },
    {
      'nameAr': 'سبوتيفاي',
      'nameEn': 'Spotify',
      'image': 'assets/images/book.jpg',
      'icon': Icons.music_note,
      'categoryAr': 'موسيقى',
      'categoryEn': 'Music',
      'rating': 4.8,
      'color': const Color(0xFF10B981),
    },
    {
      'nameAr': 'يوتيوب',
      'nameEn': 'YouTube',
      'image': 'assets/images/book.jpg',
      'icon': Icons.play_circle,
      'categoryAr': 'فيديو',
      'categoryEn': 'Video',
      'rating': 4.9,
      'color': const Color(0xFF34D399),
    },
    {
      'nameAr': 'فيسبوك',
      'nameEn': 'Facebook',
      'image': 'assets/images/zara.jpg',
      'icon': Icons.facebook,
      'categoryAr': 'تواصل',
      'categoryEn': 'Social',
      'rating': 4.5,
      'color': const Color(0xFF6EE7B7),
    },
    {
      'nameAr': 'تويتر',
      'nameEn': 'Twitter',
      'image': 'assets/images/butti.jpg',
      'icon': Icons.flutter_dash,
      'categoryAr': 'تواصل',
      'categoryEn': 'Social',
      'rating': 4.4,
      'color': const Color(0xFF059669),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
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
            const Color(0xFF10B981),
            const Color(0xFF34D399),
            const Color(0xFF6EE7B7),
            const Color(0xFF059669),
            const Color(0xFF10B981),
            const Color(0xFF34D399),
            const Color(0xFF6EE7B7),
            const Color(0xFF059669),
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
            const Color(0xFF10B981),
            const Color(0xFF34D399),
            const Color(0xFF6EE7B7),
            const Color(0xFF059669),
            const Color(0xFF10B981),
            const Color(0xFF34D399),
            const Color(0xFF6EE7B7),
            const Color(0xFF059669),
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
            Color storeColor = const Color(0xFF10B981);
            if (discount.contains('20') || discount.contains('25')) {
              badgeColor = const Color(0xFF6EE7B7);
              storeColor = const Color(0xFF6EE7B7);
            } else if (discount.contains('15')) {
              badgeColor = const Color(0xFFA7F3D0);
              storeColor = const Color(0xFF34D399);
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
    switch (_currentNavIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const ShoppingPage();
      case 2:
        return const PaymentsPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
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
          physics: const AlwaysScrollableScrollPhysics(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.searchProducts),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 0,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.4),
                          Colors.white.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.searchPlaceholder,
                          style: GoogleFonts.mada(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.searchSubtitle,
                          style: GoogleFonts.mada(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
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

  Widget _buildPendingPayments() {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.pendingPayments,
                style: AppTextStyles.changaH5,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to payments page
                  Navigator.of(context).pushNamed('/payments');
                },
                child: Text(
                  l10n.viewAllPayments,
                  style: GoogleFonts.mada(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoadingPendingPayments
              ? const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _pendingPayments.isEmpty
                  ? SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          l10n.noPaymentsFound,
                          style: GoogleFonts.mada(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: isRTL,
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
    final l10n = AppLocalizations.of(context)!;
    
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
    String daysLeftText = '';
    if (dueDateStr != null) {
      try {
        final dueDate = DateTime.parse(dueDateStr);
        final now = DateTime.now();
        final difference = dueDate.difference(now).inDays;
        
        if (difference < 0) {
          daysLeftText = isRTL ? 'متأخر' : 'Overdue';
        } else if (difference == 0) {
          daysLeftText = isRTL ? 'اليوم' : 'Today';
        } else if (difference == 1) {
          daysLeftText = isRTL ? 'غداً' : 'Tomorrow';
        } else {
          daysLeftText = isRTL ? '$difference أيام' : '$difference days';
        }
      } catch (e) {
        daysLeftText = isRTL ? 'تاريخ غير صحيح' : 'Invalid date';
      }
    }
    
    final installmentNumber = payment['installmentNumber'] as int? ?? 1;
    final installmentsCount = payment['installmentsCount'] as int? ?? 1;
    final installmentText = isRTL 
        ? 'القسط $installmentNumber من $installmentsCount'
        : 'Payment $installmentNumber of $installmentsCount';
    
    return GestureDetector(
      onTap: () {
        // Navigate to payments page instead of showing modal
        Navigator.of(context).pushNamed('/payments');
      },
      child: Container(
        width: 320,
        height: 80,
        margin: EdgeInsets.only(right: isRTL ? 16 : 0, left: isRTL ? 0 : 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
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
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Left Side - Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.5),
                            Colors.white.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.store_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Middle Section - Amount and Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Amount
                          Text(
                            amountText,
                            style: AppTextStyles.changaH5,
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Due date and store name
                          Text(
                            isRTL 
                              ? '$daysLeftText · $storeName · $installmentText'
                              : '$daysLeftText · $storeName · $installmentText',
                            style: GoogleFonts.mada(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Right Side - Arrow
                    Icon(
                      Icons.chevron_right,
                      color: const Color(0xFF1E293B),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBanner() {
    final l10n = AppLocalizations.of(context)!;
    
    // Use database banners if available, otherwise use fallback
    final bannersToShow = _banners.isNotEmpty ? _banners : _fallbackBannerImages.map((img) => {'imageUrl': img}).toList();
    final bannersCount = bannersToShow.length;
    
    if (_isLoadingBanners && _banners.isEmpty) {
      // Show loading placeholder
      return Container(
        margin: const EdgeInsets.only(top: 24),
        height: 180,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (bannersCount == 0) {
      // No banners available
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 24),
      height: 180,
      child: Stack(
        children: [
          // Image Carousel
          GestureDetector(
            onTap: () {
              if (_banners.isNotEmpty && _currentBannerIndex < _banners.length) {
                _handleBannerTap(_banners[_currentBannerIndex]);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.specialOffer),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: PageView.builder(
              controller: _bannerPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemCount: bannersCount,
              itemBuilder: (context, index) {
                final banner = bannersToShow[index];
                final imageUrl = banner['imageUrl'] ?? '';
                final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
                
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: isNetworkImage
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF10B981),
                                      Color(0xFF34D399),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackBanner(index);
                            },
                          )
                        : Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackBanner(index);
                            },
                          ),
                  ),
                );
              },
            ),
          ),
          
          // Page Indicator
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannersCount,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFallbackBanner(int index) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF34D399),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 50,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 6),
            Text(
              'صورة ${index + 1}',
              style: GoogleFonts.changa(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCards() {
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
      child: Row(
        children: [
          // All Stores Card
          Expanded(
            child: _buildStoreCard(
              title: isRTL ? 'جميع المتاجر' : 'All Stores',
              subtitle: isRTL ? 'اكتشف المتاجر الجديدة' : 'Discover new stores',
              icon: Icons.store,
              color: const Color(0xFF10B981),
              onTap: () {
                AppRouter.navigateToAllStores(context);
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Deals Card
          Expanded(
            child: _buildStoreCard(
              title: isRTL ? 'العروض' : 'Deals',
              subtitle: isRTL ? 'أفضل العروض والخصومات' : 'Best offers & discounts',
              icon: Icons.local_offer,
              color: const Color(0xFF34D399),
              onTap: () {
                AppRouter.navigateToOffers(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with enhanced design
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.5),
                            Colors.white.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Title with enhanced typography
                    Text(
                      title,
                      style: AppTextStyles.changaH6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Subtitle with improved styling
                    Text(
                      subtitle,
                      style: GoogleFonts.mada(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Subtle indicator
                    Container(
                      width: 20,
                      height: 2,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopStoresSection() {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isArabic;
    
    // Show only database stores - no fallback
    if (_isLoadingStores) {
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
    // if (_topStores.isEmpty) {
    //   if (EnvDev.enableLogging) {
    //     print('⚠️ No stores to display. _topStores is empty.');
    //   }
    //   return const SizedBox.shrink();
    // }
    
    // if (EnvDev.enableLogging) {
    // //  print('✅ Displaying ${_topStores.length} stores in Top Stores section');
    // }
    
    return Container(
      margin: const EdgeInsets.only(top: 32, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _storesPageController,
              reverse: isRTL,
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
          // const SizedBox(height: 6),
          // Page Indicators
          Column(
            children: [
              // Text(
              //   'الصفحة ${_currentStoresPage + 1} من ${(_topStores.length / 8).ceil()}',
              //   style: GoogleFonts.mada(
              //     fontSize: 12,
              //     color: const Color(0xFF64748B),
              //   ),
              // ),
              // const SizedBox(height: 8),
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
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      margin: const EdgeInsets.only(top: 24, left: 20, right: 20),
      child: SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          reverse: isRTL,
          itemCount: categoriesToShow.length,
          itemBuilder: (context, index) {
            final category = categoriesToShow[index];
            return _buildCategoryCard(category, isRTL);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, bool isRTL) {
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
        width: 120,
        height: 160,
        margin: EdgeInsets.only(right: isRTL ? 12 : 0, left: isRTL ? 0 : 12),
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
                      child: ImageHelper.buildImage(
                        imageUrl: category['image'],
                        fit: BoxFit.cover,
                        errorWidget: Container(
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
                        ),
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
      margin: const EdgeInsets.only(top: 32, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.bestOffers,
                style: AppTextStyles.changaH4,
              ),
              TextButton(
                onPressed: () {
                  AppRouter.navigateToOffers(context);
                },
                child: Text(
                  l10n.viewAllOffers,
                  style: GoogleFonts.mada(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingOffers
              ? const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _bestOffers.isEmpty
                  ? SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          l10n.noOffersFound,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: isRTL,
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
    const double cardWidth = 360;
    const double cardHeight = 280;
    const double radius = 24;
    
    // Handle image - can be network or asset
    final imageUrl = offer['image']?.toString() ?? '';
    final isNetworkImage = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    
    // Handle store URL
    final storeUrlValue = offer['storeUrl'];
    final storeUrl = (storeUrlValue?.toString().trim()) ?? '';
    
    Future<void> _openStoreUrl() async {
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

    return GestureDetector(
      onTap: _openStoreUrl,
      child: Container(
        margin: EdgeInsets.only(right: isRTL ? 16 : 0, left: isRTL ? 0 : 16),
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
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
                    // الجزء العلوي (الصورة + الشارة + نص الخصم)
                    SizedBox(
                    height: 200, // جزء الصورة بالضبط (16:9 تقريبًا لهذا العرض)
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: isNetworkImage
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              const Color(0xFF10B981),
                                              const Color(0xFF34D399),
                                              const Color(0xFF6EE7B7),
                                            ],
                                          ),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              const Color(0xFF10B981),
                                              const Color(0xFF34D399),
                                              const Color(0xFF6EE7B7),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    imageUrl.isNotEmpty ? imageUrl : 'assets/images/photo.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              const Color(0xFF10B981),
                                              const Color(0xFF34D399),
                                              const Color(0xFF6EE7B7),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        // الشارة
                        Positioned(
                          top: 12,
                          right: isRTL ? 12 : null,
                          left: isRTL ? null : 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isRTL ? offer['descriptionAr'] : offer['descriptionEn'],
                              style: const TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        // نص الخصم
                        Positioned(
                          right: isRTL ? 16 : null,
                          left: isRTL ? null : 16,
                          bottom: 12,
                          child: Text(
                            '${offer['discount']} خصم',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                    // فاصل بسيط لضمان نفس الإحساس بالهوامش
                    const SizedBox(height: 8),

                    // القسم السفلي (لوجو + اسم المتجر + زر)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                      children: [
                        // شعار المتجر
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.5),
                                Colors.white.withValues(alpha: 0.3),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                                color: Colors.black.withValues(alpha: 0.1),
                              ),
                            ],
                          ),
                          child: _buildStoreLogoImage(
                            offer['logo']?.toString() ?? '', 
                            offer['storeColor'] as Color? ?? const Color(0xFF10B981), 
                            isRTL ? (offer['storeNameAr']?.toString() ?? '') : (offer['storeNameEn']?.toString() ?? ''),
                          ),
                        ),
                        
                        const SizedBox(width: 12),

                        // اسم المتجر
                        Text(
                          isRTL ? offer['storeNameAr'] : offer['storeNameEn'],
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const Spacer(),

                        // زر المتجر
                        ElevatedButton(
                          onPressed: _openStoreUrl,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(l10n.visitStore),
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
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
      backgroundColor = const Color(0xFF10B981);
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
                                backgroundColor: const Color(0xFF16A34A),
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
                          onApplePay: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم الدفع بنجاح عبر Apple Pay'),
                                backgroundColor: const Color(0xFF16A34A),
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
    final l10n = AppLocalizations.of(context)!;
    
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 0,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(Icons.home, 0, l10n.home),
                _buildNavIcon(Icons.shopping_bag_outlined, 1, l10n.shopping),
                _buildNavIcon(Icons.payment, 2, l10n.payments),
                _buildNavIcon(Icons.person, 3, l10n.profile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, String label) {
    bool isActive = index == _currentNavIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.6),
                  Colors.white.withValues(alpha: 0.4),
                ],
              ) : null,
              border: isActive ? Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1,
              ) : null,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isActive ? AppColors.primary : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.mada(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.primary : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}



