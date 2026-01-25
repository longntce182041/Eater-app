import 'package:dio/dio.dart';

import '../auth_api_client.dart';
import '../models/auth_tokens_model.dart';
import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;
  final AuthApiClient api;

  AuthRemoteDataSource(this.dio, this.api);

  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    final res = await api.login(email: email, password: password);
    final data = res.data['data'] ?? res.data;
    return AuthTokensModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<AuthTokensModel> register({
    required String email,
    required String password,
  }) async {
    final res = await api.register(email: email, password: password);
    final data = res.data['data'] ?? res.data;
    return AuthTokensModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> resetPassword(String email) async {
    await api.requestPasswordReset(email: email);
  }

  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    final res = await api.refresh(refreshToken: refreshToken);
    final data = res.data['data'] ?? res.data;
    return AuthTokensModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<AuthUserModel> getCurrentUser() async {
    // Placeholder: implement when profile endpoint and auth header wiring are ready.
    throw UnimplementedError('getCurrentUser not implemented');
  }
}
