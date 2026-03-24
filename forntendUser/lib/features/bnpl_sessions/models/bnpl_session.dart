class BnplSession {
  final String sessionId;
  final Store store;
  final double totalAmount;
  final String currency;
  final int installmentsCount;
  final List<SessionItem> items;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  BnplSession({
    required this.sessionId,
    required this.store,
    required this.totalAmount,
    required this.currency,
    required this.installmentsCount,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  factory BnplSession.fromJson(Map<String, dynamic> json) {
    return BnplSession(
      sessionId: json['session_id'] ?? '',
      store: Store.fromJson(json['store'] ?? {}),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'JOD',
      installmentsCount: json['installments_count'] ?? 4,
      items: (json['items'] as List?)
              ?.where((item) => item is Map<String, dynamic>)
              .map((item) => SessionItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }

  double get installmentAmount => totalAmount / installmentsCount;
}

class Store {
  final int id;
  final String name;
  final String nameAr;
  final String? logoUrl;

  Store({
    required this.id,
    required this.name,
    required this.nameAr,
    this.logoUrl,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      logoUrl: json['logoUrl'],
    );
  }
}

class SessionItem {
  final String name;
  final int quantity;
  final double price;
  final String? description;
  final String? image;

  SessionItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.description,
    this.image,
  });

  factory SessionItem.fromJson(Map<String, dynamic> json) {
    return SessionItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      image: json['image'],
    );
  }

  double get totalPrice => price * quantity;
}
