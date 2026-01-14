import '../../../coffees/data/models/coffee_model.dart';

class OrderItemModel {
  final int id;
  final CoffeeModel? coffee;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItemModel({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.coffee,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic value) => value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0;

    return OrderItemModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      coffee: json['coffee'] is Map<String, dynamic>
          ? CoffeeModel.fromJson(Map<String, dynamic>.from(json['coffee'] as Map))
          : null,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: parseNum(json['unit_price']),
      subtotal: parseNum(json['subtotal']),
    );
  }
}
