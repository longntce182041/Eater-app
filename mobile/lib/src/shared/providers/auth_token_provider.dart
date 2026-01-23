import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthTokenProvider {
  final String? accessToken;
  final String? refreshToken;

  const AuthTokenProvider({
    required this.accessToken,
    required this.refreshToken,
  });
}

final authTokenProvider = StateProvider<AuthTokenProvider>((ref) {
  // Initially empty; populated after login from secure storage or API.
  return const AuthTokenProvider(accessToken: null, refreshToken: null);
});