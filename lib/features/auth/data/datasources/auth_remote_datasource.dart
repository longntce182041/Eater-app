import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<void> logout();
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
