import 'package:dio/dio.dart';

import '../../../../core/utils/http_error_handler.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio;
  OrderService(this._dio);

  Future<List<OrderModel>> fetchMyOrders() async {
    try {
      final res = await _dio.get('/orders');
      final list = (res.data is Map<String, dynamic> ? res.data['data'] : res.data) as List?;
      return (list ?? [])
          .map((i) => OrderModel.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudieron cargar tus órdenes');
    }
  }

  Future<OrderModel> fetchMyOrder(int id) async {
    try {
      final res = await _dio.get('/orders/$id');
      final raw = res.data is Map<String, dynamic> && res.data['data'] != null ? res.data['data'] : res.data;
      return OrderModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo cargar el detalle');
    }
  }

  Future<List<OrderModel>> fetchAdminOrders({String? status, int? userId}) async {
    try {
      final res = await _dio.get('/admin/orders', queryParameters: {
        if (status != null) 'status': status,
        if (userId != null) 'user_id': userId,
      });
      final list = (res.data is Map<String, dynamic> ? res.data['data'] : res.data) as List?;
      return (list ?? [])
          .map((i) => OrderModel.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudieron cargar las órdenes');
    }
  }

  Future<OrderModel> fetchAdminOrder(int id) async {
    try {
      final res = await _dio.get('/admin/orders/$id');
      final raw = res.data is Map<String, dynamic> && res.data['data'] != null ? res.data['data'] : res.data;
      return OrderModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo cargar el detalle');
    }
  }
}
