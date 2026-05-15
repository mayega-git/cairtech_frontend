import 'package:dio/dio.dart';

import '../api/dio_client.dart';
import 'current_user.dart';
import 'token_storage.dart';

/// Repository d'authentification — façade autour des endpoints /auth + /users.
class AuthRepository {
  final DioClient client;
  final TokenStorage storage;

  AuthRepository({required this.client, required this.storage});

  Dio get _dio => client.dio;

  Future<CurrentUser> login({required String email, required String password}) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final body = res.data as Map<String, dynamic>;
    final accessToken = body['accessToken'] as String;
    final refreshToken = body['refreshToken'] as String;
    await storage.save(accessToken: accessToken, refreshToken: refreshToken);
    return CurrentUser.fromJwt(accessToken);
  }

  Future<void> logout() async {
    final refresh = await storage.readRefresh();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _dio.post('/auth/logout', data: {'refreshToken': refresh});
      } catch (_) {
        // best-effort
      }
    }
    await storage.clear();
  }

  Future<CurrentUser?> restoreSession() async {
    final access = await storage.readAccess();
    if (access == null || access.isEmpty) return null;
    try {
      return CurrentUser.fromJwt(access);
    } catch (_) {
      await storage.clear();
      return null;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstNames,
    String? nextNames,
    String? phone,
    String? gender,
    String? dateOfBirth,
    required String requestedType, // STUDENT / PROFESSIONAL / VISITOR
    String? bibleClubId,
    String? levelId,
    String? profession,
    String? pictureFileId,
    String? locale = 'fr',
  }) async {
    final res = await _dio.post('/users', data: {
      'email': email,
      'password': password,
      'firstNames': firstNames,
      if (nextNames != null) 'nextNames': nextNames,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      'requestedType': requestedType,
      if (bibleClubId != null) 'bibleClubId': bibleClubId,
      if (levelId != null) 'levelId': levelId,
      if (profession != null) 'profession': profession,
      if (pictureFileId != null) 'pictureFileId': pictureFileId,
      'locale': locale,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<void> activate(String token) async {
    await _dio.post('/users/activate', queryParameters: {'token': token});
  }

  Future<void> requestPasswordReset(String email) async {
    await _dio.post('/auth/reset-password', data: {'email': email});
  }

  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    await _dio.post('/auth/reset-password/confirm', data: {
      'token': token,
      'newPassword': newPassword,
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post('/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
