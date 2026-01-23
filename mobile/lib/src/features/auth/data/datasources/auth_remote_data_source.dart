import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_tokens_model.dart';
import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    // TODO: call dio.post(ApiEndpoints.login, data: {...})
    throw UnimplementedError();
  }

  Future<AuthTokensModel> register({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  Future<void> resetPassword(String email) async {
    throw UnimplementedError();
  }

  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    throw UnimplementedError();
  }

  Future<AuthUserModel> getCurrentUser() async {
    throw UnimplementedError();
  }
}