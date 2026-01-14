import '../../../auth/data/models/user_model.dart';
import 'order_item_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final double total;
  final String status;
  final String paymentMethod;
  final String? paidAt;
  final String? createdAt;
  final List<OrderItemModel> items;
  final UserModel? user;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.paidAt,
    this.createdAt,
    this.items = const [],
    this.user,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic value) => value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0;
    final itemsJson = (json['items'] as List?) ?? [];

    return OrderModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] as int : int.tryParse(json['user_id'].toString()) ?? 0,
      total: parseNum(json['total']),
      status: json['status']?.toString() ?? 'paid',
      paymentMethod: json['payment_method']?.toString() ?? 'simulated',
      paidAt: json['paid_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      items: itemsJson
          .map((i) => OrderItemModel.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList(growable: false),
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
    );
  }
}
