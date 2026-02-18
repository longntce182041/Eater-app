import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/token_storage.dart';
import '../../shared/providers/auth_token_provider.dart';

class AuthNotifier extends ChangeNotifier {
  final TokenStorage _tokenStorage;
  final Ref _ref;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  AuthNotifier(this._tokenStorage, this._ref) {
    _init();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    _isAuthenticated = accessToken != null && accessToken.isNotEmpty;

    // Load tokens into authTokenProvider for Dio interceptor
    if (accessToken != null && refreshToken != null) {
      _ref.read(authTokenProvider.notifier).state = AuthTokenProvider(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    _isInitialized = true;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _init();
  }
}

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier(TokenStorage(), ref);
});
