import 'cart_item_model.dart';

class CartModel {
  final int id;
  final String status;
  final List<CartItemModel> items;
  final double totalCart;

  const CartModel({
    required this.id,
    required this.status,
    required this.items,
    required this.totalCart,
  });

  factory CartModel.empty() => const CartModel(id: 0, status: 'active', items: [], totalCart: 0);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic value) => value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0;

    final itemsJson = (json['items'] as List?) ?? [];
    return CartModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      status: json['status']?.toString() ?? 'active',
      items: itemsJson
          .map((i) => CartItemModel.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList(growable: false),
      totalCart: parseNum(json['total_cart'] ?? json['total']),
    );
  }
}
