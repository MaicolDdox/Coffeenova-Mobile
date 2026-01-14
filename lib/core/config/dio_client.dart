import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'env.dart';
import 'token_provider.dart';

/// Cliente HTTP centralizado con inyección del token y manejo básico de errores.
final dioProvider = Provider<Dio>((ref) {
  // Rebuild cuando cambia el token para mantener el header fresco.
  ref.watch(authTokenProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authTokenProvider);
        if (token != null && token.isNotEmpty) {
          options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Borramos token en memoria; el AuthNotifier se encargará de limpiar sesión si corresponde.
          ref.read(authTokenProvider.notifier).state = null;
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
