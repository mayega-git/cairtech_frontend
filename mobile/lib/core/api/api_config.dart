/// Configuration HTTP de l'application.
///
/// L'URL de base peut être surchargée à la compilation via :
///   `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080`
///
/// Valeurs par défaut adaptées aux différents environnements :
///   - Android emulator → http://10.0.2.2:8080 (auto-mapping localhost)
///   - iOS simulator    → http://localhost:8080
///   - Web (Chrome)     → http://localhost:8080
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String apiPrefix = '/api/v1/bbcms';

  static String get apiBase => '$baseUrl$apiPrefix';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
