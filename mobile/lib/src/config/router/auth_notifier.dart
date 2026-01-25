import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/token_storage.dart';

class AuthNotifier extends ChangeNotifier {
  final TokenStorage _tokenStorage;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  AuthNotifier(this._tokenStorage) {
    _init();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    final token = await _tokenStorage.getAccessToken();
    _isAuthenticated = token != null && token.isNotEmpty;
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
  return AuthNotifier(TokenStorage());
});
