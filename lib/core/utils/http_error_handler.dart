import 'package:dio/dio.dart';

import '../errors/failure.dart';

Failure mapDioError(DioException error, {String defaultMessage = 'Error inesperado'}) {
  final status = error.response?.statusCode;
  final data = error.response?.data;

  String message = defaultMessage;
  Map<String, dynamic>? errors;

  if (data is Map<String, dynamic>) {
    message = data['message']?.toString() ?? defaultMessage;
    if (data['errors'] is Map<String, dynamic>) {
      errors = Map<String, dynamic>.from(data['errors'] as Map);
    }
  } else if (error.message != null) {
    message = error.message!;
  }

  return Failure(message: message, errors: errors, statusCode: status);
}
