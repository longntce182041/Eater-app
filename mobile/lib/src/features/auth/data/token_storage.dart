import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/storage_keys.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    final expiry = _extractExpiry(accessToken);
    if (expiry != null) {
      await _storage.write(
        key: StorageKeys.accessTokenExpiry,
        value: expiry.toString(),
      );
    }
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);
  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  /// Returns the Unix timestamp (seconds) at which the access token expires,
  /// or null if not stored.
  Future<int?> getAccessTokenExpiry() async {
    final value = await _storage.read(key: StorageKeys.accessTokenExpiry);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> clear() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.accessTokenExpiry);
  }

  /// Extracts the [exp] (Unix timestamp in seconds) from a JWT access token.
  ///
  /// Note: This only decodes the payload for local expiry tracking; it does
  /// **not** verify the token signature.  Signature validation is enforced by
  /// the backend on every API call.
  static int? _extractExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      return payload['exp'] as int?;
    } catch (_) {
      return null;
    }
  }
}
