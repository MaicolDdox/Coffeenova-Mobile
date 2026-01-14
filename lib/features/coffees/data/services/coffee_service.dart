import 'package:dio/dio.dart';

import '../../../../core/utils/http_error_handler.dart';
import '../models/coffee_model.dart';

class CoffeeService {
  final Dio _dio;
  CoffeeService(this._dio);

  Future<List<CoffeeModel>> fetchCoffees({String? brand, String? priceOrder}) async {
    try {
      final res = await _dio.get('/coffees', queryParameters: {
        if (brand != null && brand.isNotEmpty) 'brand': brand,
        if (priceOrder != null && priceOrder.isNotEmpty) 'price_order': priceOrder,
      });
      final data = res.data;
      final list = (data is Map<String, dynamic> ? data['data'] : data) as List?;
      return (list ?? [])
          .map((item) => CoffeeModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo cargar el catálogo');
    }
  }

  Future<CoffeeModel> fetchCoffee(int id) async {
    try {
      final res = await _dio.get('/coffees/$id');
      final data = res.data;
      final raw = data is Map<String, dynamic> && data['data'] is Map<String, dynamic> ? data['data'] : data;
      return CoffeeModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo cargar el café');
    }
  }

  Future<CoffeeModel> createCoffee(dynamic payload) async {
    try {
      final res = await _dio.post('/coffees', data: payload);
      final raw = res.data is Map<String, dynamic> && res.data['data'] != null ? res.data['data'] : res.data;
      return CoffeeModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo crear el café');
    }
  }

  Future<CoffeeModel> updateCoffee(int id, dynamic payload) async {
    try {
      final res = await _dio.put('/coffees/$id', data: payload);
      final raw = res.data is Map<String, dynamic> && res.data['data'] != null ? res.data['data'] : res.data;
      return CoffeeModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo actualizar el café');
    }
  }

  Future<void> deleteCoffee(int id) async {
    try {
      await _dio.delete('/coffees/$id');
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo desactivar el café');
    }
  }
}
