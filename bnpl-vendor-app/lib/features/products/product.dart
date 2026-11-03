import '../../core/utils/format.dart';

/// A store product. The store listing returns both the raw columns and
/// camelCase copies, so each field reads either.
class Product {
  Product({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    required this.discountPrice,
    required this.categoryId,
    required this.imageUrl,
    required this.stockQuantity,
    required this.salesCount,
    required this.totalRevenue,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final discount = pick(json, 'discountPrice', 'discount_price');
    final category = pick(json, 'categoryId', 'category_id');
    return Product(
      id: toInt(json['id']),
      name: json['name']?.toString() ?? '',
      nameAr: pick(json, 'nameAr', 'name_ar')?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionAr:
          pick(json, 'descriptionAr', 'description_ar')?.toString() ?? '',
      price: toDouble(json['price']),
      discountPrice: discount == null ? null : toDouble(discount),
      categoryId: category == null ? null : toInt(category),
      imageUrl: pick(json, 'imageUrl', 'image_url')?.toString(),
      stockQuantity: toInt(pick(json, 'stockQuantity', 'stock_quantity')),
      salesCount: toInt(json['salesCount']),
      totalRevenue: toDouble(json['totalRevenue']),
    );
  }

  final int id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final double? discountPrice;
  final int? categoryId;
  final String? imageUrl;
  final int stockQuantity;
  final int salesCount;
  final double totalRevenue;

  String displayName(bool arabic) =>
      arabic && nameAr.isNotEmpty ? nameAr : name;

  String displayDescription(bool arabic) =>
      arabic && descriptionAr.isNotEmpty ? descriptionAr : description;

  bool get hasDiscount =>
      discountPrice != null && discountPrice! > 0 && discountPrice! < price;

  /// Same thresholds as the portal: none left, ten or fewer, or plenty.
  StockLevel get stockLevel => stockQuantity <= 0
      ? StockLevel.out
      : (stockQuantity <= 10 ? StockLevel.low : StockLevel.inStock);

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) || nameAr.contains(query);
  }
}

enum StockLevel { inStock, low, out }
