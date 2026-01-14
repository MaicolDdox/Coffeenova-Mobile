import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/http_error_handler.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<(String token, UserModel user)> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token']?.toString() ?? '';
      final user = UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map));
      return (token, user);
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'Error al iniciar sesión');
    }
  }

  Future<(String token, UserModel user)> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token']?.toString() ?? '';
      final user = UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map));
      return (token, user);
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'No se pudo registrar');
    }
  }

  Future<UserModel> me() async {
    try {
      final res = await _dio.get('/me');
      final data = res.data;
      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        return UserModel.fromJson(Map<String, dynamic>.from(data['data'] as Map));
      }
      return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw mapDioError(e, defaultMessage: 'Sesión inválida');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      final failure = mapDioError(e);
      // Silencioso para evitar bloquear UX
      if (failure.statusCode != null && failure.statusCode! >= 500) {
        throw Failure(message: failure.message, statusCode: failure.statusCode);
      }
    }
  }
}
