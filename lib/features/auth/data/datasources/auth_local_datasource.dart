import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    // TODO: Implement secure storage
    throw UnimplementedError();
  }

  @override
  Future<String?> getAccessToken() async {
    // TODO: Implement secure storage
    throw UnimplementedError();
  }

  @override
  Future<String?> getRefreshToken() async {
    // TODO: Implement secure storage
    throw UnimplementedError();
  }

  @override
  Future<void> clearTokens() async {
    // TODO: Implement secure storage
    throw UnimplementedError();
  }

  @override
  Future<void> saveUserId(String userId) async {
    // TODO: Implement secure storage
    throw UnimplementedError();
  }

  @override
  Future<String?> getUserId() async {
    // TODO: Implement secure storage
    throw UnimplementedError();
  }
}
