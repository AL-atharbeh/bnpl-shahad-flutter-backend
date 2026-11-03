import 'package:flutter/foundation.dart';

import '../products/product.dart';

class CartLine {
  CartLine(this.product, this.quantity);
  final Product product;
  int quantity;

  double get total => product.price * quantity;
}

enum DiscountType { fixed, percent }

/// The counter's working order: items, a manual discount and the plan.
class PosCart extends ChangeNotifier {
  final List<CartLine> _lines = [];
  List<CartLine> get lines => List.unmodifiable(_lines);

  double discount = 0;
  DiscountType discountType = DiscountType.fixed;

  /// The portal sends every in-store order as four installments.
  final int installments = 4;

  bool get isEmpty => _lines.isEmpty;
  int get itemCount => _lines.fold(0, (sum, l) => sum + l.quantity);
  int quantityOf(Product p) => _lines
      .where((l) => l.product.id == p.id)
      .fold(0, (s, l) => s + l.quantity);

  double get subtotal => _lines.fold(0, (sum, l) => sum + l.total);
  double get discountAmount {
    final raw = discountType == DiscountType.percent
        ? subtotal * discount / 100
        : discount;
    return raw.clamp(0, subtotal).toDouble();
  }

  double get total =>
      (subtotal - discountAmount).clamp(0, double.infinity).toDouble();
  double get installmentAmount => total / installments;

  void add(Product product) {
    final line = _lines.where((l) => l.product.id == product.id).firstOrNull;
    if (line != null) {
      line.quantity++;
    } else {
      _lines.add(CartLine(product, 1));
    }
    notifyListeners();
  }

  void changeQuantity(Product product, int delta) {
    final line = _lines.where((l) => l.product.id == product.id).firstOrNull;
    if (line == null) return;
    line.quantity += delta;
    if (line.quantity <= 0) _lines.remove(line);
    notifyListeners();
  }

  void remove(Product product) {
    _lines.removeWhere((l) => l.product.id == product.id);
    notifyListeners();
  }

  void setDiscount(double value, DiscountType type) {
    discount = value < 0 ? 0 : value;
    discountType = type;
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    discount = 0;
    discountType = DiscountType.fixed;
    notifyListeners();
  }

  /// The body the portal posts to /sessions/create.
  Map<String, dynamic> toSessionPayload({
    required int storeId,
    required bool arabic,
    String? customerPhone,
  }) {
    return {
      'store_id': storeId,
      'store_order_id': 'POS_${DateTime.now().millisecondsSinceEpoch}',
      'total_amount': double.parse(total.toStringAsFixed(2)),
      'customer_phone': ?customerPhone,
      'installments_count': installments,
      'items': [
        for (final l in _lines)
          {
            'product_id': l.product.id,
            'name': l.product.displayName(arabic),
            'quantity': l.quantity,
            'price': double.parse(l.product.price.toStringAsFixed(2)),
          },
      ],
      'metadata': {
        'discount_applied': discount,
        'discount_type': discountType.name,
        'discount_amount': discountAmount,
        'subtotal': subtotal,
      },
    };
  }
}
