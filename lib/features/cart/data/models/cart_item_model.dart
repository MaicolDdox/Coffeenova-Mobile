import '../../../coffees/data/models/coffee_model.dart';

class CartItemModel {
  final int id;
  final CoffeeModel coffee;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const CartItemModel({
    required this.id,
    required this.coffee,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic value) => value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0;

    return CartItemModel(
      id: json['id'] as int,
      coffee: CoffeeModel.fromJson(Map<String, dynamic>.from(json['coffee'] as Map)),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: parseNum(json['unit_price']),
      totalPrice: parseNum(json['total_price']),
    );
  }
}
