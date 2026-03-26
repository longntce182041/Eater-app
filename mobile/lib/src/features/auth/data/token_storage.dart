import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kAccessTokenExpiry = 'access_token_expiry';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
    final expiry = _extractExpiry(accessToken);
    if (expiry != null) {
      await _storage.write(
          key: _kAccessTokenExpiry, value: expiry.toString());
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  /// Returns the Unix timestamp (seconds) at which the access token expires,
  /// or null if not stored.
  Future<int?> getAccessTokenExpiry() async {
    final value = await _storage.read(key: _kAccessTokenExpiry);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kAccessTokenExpiry);
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
