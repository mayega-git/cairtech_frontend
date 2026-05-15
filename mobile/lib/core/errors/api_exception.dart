/// Exception métier remontée depuis le backend (mappée depuis ApiErrorResponse).
///
/// Format backend: `{ "errorCode": "BBCMS_XXX", "message": "…", "details": {…} }`.
class ApiException implements Exception {
  final int? statusCode;
  final String? errorCode;
  final String message;
  final Map<String, dynamic>? details;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  factory ApiException.fromResponse(int? statusCode, dynamic data) {
    if (data is Map<String, dynamic>) {
      return ApiException(
        statusCode: statusCode,
        errorCode: data['errorCode'] as String?,
        message: (data['message'] as String?) ?? 'Erreur inconnue',
        details: data['details'] as Map<String, dynamic>?,
      );
    }
    return ApiException(
      statusCode: statusCode,
      message: data?.toString() ?? 'Erreur réseau',
    );
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isRateLimited => statusCode == 429;

  @override
  String toString() => 'ApiException($statusCode/$errorCode): $message';
}
