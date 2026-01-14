import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/http_error_handler.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../orders/data/models/order_item_model.dart';
import '../../../orders/data/models/order_model.dart';
import '../models/cart_model.dart';

class CheckoutResult {
  final OrderModel order;
  final List<OrderItemModel> items;
  final UserModel? user;
  final String? message;

  CheckoutResult({
    required this.order,
    required this.items,
    this.user,
    this.message,
  });
}

class CartService {
  final Dio _dio;
  CartService(this._dio);

  CartModel _parseCart(dynamic data) {
    final raw = data is Map<String, dynamic>
        ? (data['cart'] ?? data['data'] ?? data)
        : data;
    return CartModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<CartModel> fetchCart() async {
    try {
      final res = await _dio.get('/cart');
      return _parseCart(res.data);
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo cargar el carrito');
    }
  }

  Future<CartModel> addItem({required int coffeeId, int quantity = 1}) async {
    try {
      final res = await _dio.post('/cart/items', data: {
        'coffee_id': coffeeId,
        'quantity': quantity,
      });
      return _parseCart(res.data);
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo agregar al carrito');
    }
  }

  Future<CartModel> updateItem({required int itemId, required int quantity}) async {
    try {
      final res = await _dio.put('/cart/items/$itemId', data: {'quantity': quantity});
      return _parseCart(res.data);
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo actualizar el item');
    }
  }

  Future<CartModel> removeItem(int itemId) async {
    try {
      final res = await _dio.delete('/cart/items/$itemId');
      return _parseCart(res.data);
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo eliminar el item');
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/cart');
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo limpiar el carrito');
    }
  }

  Future<CheckoutResult> checkout() async {
    try {
      final res = await _dio.post('/cart/checkout');
      final data = res.data as Map<String, dynamic>;
      final payload = data['data'] as Map<String, dynamic>? ?? {};
      final orderRaw = payload['order'] ?? payload;
      final itemsRaw = (payload['items'] as List?) ?? [];

      return CheckoutResult(
        order: OrderModel.fromJson(Map<String, dynamic>.from(orderRaw as Map)),
        items: itemsRaw
            .map((i) => OrderItemModel.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList(growable: false),
        user: payload['user'] is Map<String, dynamic>
            ? UserModel.fromJson(Map<String, dynamic>.from(payload['user'] as Map))
            : null,
        message: data['message']?.toString(),
      );
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo finalizar la compra');
    } catch (e) {
      throw Failure(message: 'No se pudo finalizar la compra: $e');
    }
  }
}
