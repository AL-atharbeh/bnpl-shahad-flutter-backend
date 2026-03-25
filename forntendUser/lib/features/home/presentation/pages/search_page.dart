import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../services/language_service.dart';
import '../../../../services/home_service.dart';
import '../../../../utils/image_helper.dart';
import '../../../../routing/app_router.dart';
import '../../../../config/env/env_dev.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final HomeService _homeService = HomeService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Focus the search bar when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _performSearch(query.trim());
      } else {
        setState(() {
          _stores = [];
          _products = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    
    try {
      // Perform searches in parallel
      final results = await Future.wait([
        _homeService.searchStores(query),
        _homeService.searchProducts(query),
      ]);

      final storesResult = results[0];
      final productsResult = results[1];

      if (EnvDev.enableLogging) {
        print('🔍 Store Search Success: ${storesResult['success']}');
        if (!storesResult['success']) print('❌ Store Search Error: ${storesResult['error']}');
        print('🔍 Product Search Success: ${productsResult['success']}');
        if (!productsResult['success']) print('❌ Product Search Error: ${productsResult['error']}');
      }

      setState(() {
        if (storesResult['success']) {
          final data = storesResult['data'];
          _stores = (data is List) ? data.cast<Map<String, dynamic>>() : (data['data'] as List? ?? []).cast<Map<String, dynamic>>();
        }
        
        if (productsResult['success']) {
          final data = productsResult['data'];
          _products = (data is List) ? data.cast<Map<String, dynamic>>() : (data['data'] as List? ?? []).cast<Map<String, dynamic>>();
        }
      });
    } catch (e) {
      if (EnvDev.enableLogging) {
        print('❌ Search error (catch): $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool get _isRTL => Directionality.of(context) == TextDirection.rtl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isRTL ? Icons.arrow_forward : Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.searchProductOrBrand,
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A66A)))
          : (_stores.isEmpty && _products.isEmpty && _searchController.text.isNotEmpty)
              ? _buildEmptyResults(l10n)
              : _buildResults(l10n),
    );
  }

  Widget _buildEmptyResults(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            l10n.emptyProducts, 
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(AppLocalizations l10n) {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(
              l10n.searchPlaceholder, 
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        if (_stores.isNotEmpty) ...[
          _buildSectionHeader(l10n.stores),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _stores.length,
              itemBuilder: (context, index) => _buildStoreItem(_stores[index]),
            ),
          ),
          const SizedBox(height: 30),
        ],
        if (_products.isNotEmpty) ...[
          _buildSectionHeader(l10n.products),
          const SizedBox(height: 12),
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) => _buildProductItem(_products[index], l10n),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.changa(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildStoreItem(Map<String, dynamic> store) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final isArabic = languageService.isArabic;
    final name = isArabic ? (store['nameAr'] ?? store['name'] ?? '') : (store['name'] ?? '');
    
    return GestureDetector(
      onTap: () {
        AppRouter.navigateToStoreDetails(
          context,
          storeId: store['id'],
          storeName: name,
          storeLogo: store['logoUrl'],
          storeBanner: store['logoUrl'],
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipOval(
                child: ImageHelper.buildImage(
                  imageUrl: store['logoUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorWidget: const Icon(Icons.store, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, AppLocalizations l10n) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final isArabic = languageService.isArabic;
    final name = isArabic && product['nameAr'] != null && product['nameAr'].toString().isNotEmpty
        ? product['nameAr'].toString()
        : (product['name']?.toString() ?? 'Product');
        
    double price = 0.0;
    if (product['price'] != null) {
      if (product['price'] is String) price = double.tryParse(product['price'] as String) ?? 0.0;
      else if (product['price'] is num) price = (product['price'] as num).toDouble();
    }
    
    final imagesList = product['images'] as List<dynamic>?;
    final imageUrl = product['imageUrl']?.toString() ??
        (imagesList != null && imagesList.isNotEmpty ? imagesList[0]?.toString() : null);

    return GestureDetector(
      onTap: () {
        AppRouter.navigateToProductDetails(
          context,
          productId: product['id'],
          title: name,
          priceText: price.toStringAsFixed(2),
          images: imageUrl != null ? [imageUrl] : [],
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: ImageHelper.buildImage(
                  imageUrl: imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorWidget: const Icon(Icons.image_outlined, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'JD ${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF00A66A), fontSize: 16),
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
