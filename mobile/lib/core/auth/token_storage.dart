import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stockage sécurisé des tokens JWT.
///
/// - Mobile (Android/iOS) → `flutter_secure_storage` (Keystore / Keychain).
/// - Web                  → `shared_preferences` car secure_storage n'a pas de support web stable.
///
/// Cette abstraction masque la différence d'implémentation aux callers.
class TokenStorage {
  static const _kAccess = 'bbcms.auth.access_token';
  static const _kRefresh = 'bbcms.auth.refresh_token';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  bool get _useShared => kIsWeb;

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (_useShared) {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kAccess, accessToken);
      await p.setString(_kRefresh, refreshToken);
    } else {
      await _secure.write(key: _kAccess, value: accessToken);
      await _secure.write(key: _kRefresh, value: refreshToken);
    }
  }

  Future<String?> readAccess() async {
    if (_useShared) {
      final p = await SharedPreferences.getInstance();
      return p.getString(_kAccess);
    }
    return _secure.read(key: _kAccess);
  }

  Future<String?> readRefresh() async {
    if (_useShared) {
      final p = await SharedPreferences.getInstance();
      return p.getString(_kRefresh);
    }
    return _secure.read(key: _kRefresh);
  }

  Future<void> clear() async {
    if (_useShared) {
      final p = await SharedPreferences.getInstance();
      await p.remove(_kAccess);
      await p.remove(_kRefresh);
    } else {
      await _secure.delete(key: _kAccess);
      await _secure.delete(key: _kRefresh);
    }
  }
}
