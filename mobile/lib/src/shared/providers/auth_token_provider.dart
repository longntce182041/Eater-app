import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthTokenProvider {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;

  const AuthTokenProvider({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
  });

  /// Decode JWT token and extract userId
  /// Supports id, sub, and userId field names
  static String? _extractUserIdFromToken(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      final decoded = Jwt.parseJwt(token);
      return (decoded['id'] ?? decoded['sub'] ?? decoded['userId']) as String?;
    } catch (e) {
      return null;
    }
  }

  /// Create new instance with properly decoded userId
  factory AuthTokenProvider.fromTokens({
    required String? accessToken,
    required String? refreshToken,
  }) {
    return AuthTokenProvider(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: _extractUserIdFromToken(accessToken),
    );
  }
}

final authTokenProvider = StateProvider<AuthTokenProvider>((ref) {
  // Initially empty; populated after login from secure storage or API.
  return const AuthTokenProvider(
    accessToken: null,
    refreshToken: null,
    userId: null,
  );
});
