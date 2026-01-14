import 'dart:io';

/// Configuración de entorno básica para el cliente HTTP.
///
/// Puedes sobreescribir `apiBaseUrl` con `--dart-define=API_BASE_URL=http://...`.
/// Se adapta según plataforma para desarrollo local:
/// - Android emulador: http://10.0.2.2:8000/api
/// - Windows/desktop: http://localhost:8000/api
class EnvConfig {
  static String get apiBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    final baseHost = Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000';
    return '$baseHost/api';
  }
}
