import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/token_storage.dart';
import '../errors/api_exception.dart';
import 'api_config.dart';

/// Client HTTP unique de l'app.
///
/// Pipeline d'interceptors :
///   1. AuthInterceptor      → injecte le Bearer access token
///   2. RefreshInterceptor   → sur 401, tente un /auth/refresh puis rejoue
///   3. ErrorInterceptor     → mappe les erreurs vers [ApiException]
///
/// La logique de refresh est protégée par un mutex local pour éviter les
/// rafales de calls /refresh en cas d'expirations concurrentes.
class DioClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  DioClient._(this.dio, this.tokenStorage);

  factory DioClient.create({required TokenStorage tokenStorage}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBase,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    final client = DioClient._(dio, tokenStorage);
    dio.interceptors.add(_AuthInterceptor(tokenStorage));
    dio.interceptors.add(_RefreshInterceptor(dio, tokenStorage));
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: false,
        responseBody: false,
        requestBody: false,
        error: true,
      ));
    }
    dio.interceptors.add(_ErrorInterceptor());
    return client;
  }
}

class _AuthInterceptor extends Interceptor {
  final TokenStorage storage;
  _AuthInterceptor(this.storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Endpoints publics : pas d'auth header.
    if (_isPublic(options.path)) {
      return handler.next(options);
    }
    final token = await storage.readAccess();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  static bool _isPublic(String path) {
    return path.startsWith('/auth/login') ||
        path.startsWith('/auth/refresh') ||
        path.startsWith('/auth/logout') ||
        path.startsWith('/users/activate') ||
        path == '/users' ||
        path.startsWith('/public/');
  }
}

class _RefreshInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage storage;
  Future<bool>? _ongoingRefresh;

  _RefreshInterceptor(this.dio, this.storage);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        req.path.startsWith('/auth/refresh') ||
        req.path.startsWith('/auth/login') ||
        req.extra['_retried'] == true) {
      return handler.next(err);
    }

    final refreshed = await _refresh();
    if (!refreshed) {
      await storage.clear();
      return handler.next(err);
    }

    final newToken = await storage.readAccess();
    req.headers['Authorization'] = 'Bearer $newToken';
    req.extra['_retried'] = true;
    try {
      final retryResponse = await dio.fetch(req);
      return handler.resolve(retryResponse);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  Future<bool> _refresh() {
    return _ongoingRefresh ??= _doRefresh().whenComplete(() {
      _ongoingRefresh = null;
    });
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await storage.readRefresh();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final res = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final body = res.data as Map<String, dynamic>;
      await storage.save(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiErr = ApiException.fromResponse(
      err.response?.statusCode,
      err.response?.data ?? err.message,
    );
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiErr,
      message: apiErr.message,
    ));
  }
}
