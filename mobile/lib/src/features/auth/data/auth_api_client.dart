import 'package:dio/dio.dart';

class AuthApiClient {
  final Dio _dio;
  final String baseUrl;

  AuthApiClient({required Dio dio, required this.baseUrl}) : _dio = dio;

  Future<Response<dynamic>> register({
    required String email,
    required String password,
  }) {
    return _dio.post(
      '$baseUrl/auth/user/register',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response<dynamic>> login({
    required String email,
    required String password,
  }) {
    return _dio.post(
      '$baseUrl/auth/user/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response<dynamic>> verifyEmail({required String token}) {
    return _dio.post('$baseUrl/auth/verify-email', data: {'token': token});
  }

  Future<Response<dynamic>> requestPasswordReset({required String email}) {
    return _dio.post(
      '$baseUrl/auth/user/request-password-reset',
      data: {'email': email},
    );
  }

  Future<Response<dynamic>> resetPassword({
    required String otp,
    required String newPassword,
  }) {
    return _dio.post(
      '$baseUrl/auth/user/reset-password',
      data: {'otp': otp, 'newPassword': newPassword},
    );
  }

  Future<Response<dynamic>> refresh({required String refreshToken}) {
    return _dio.post(
      '$baseUrl/auth/user/refresh',
      data: {'refreshToken': refreshToken},
    );
  }

  Future<Response<dynamic>> logout({required String refreshToken}) {
    return _dio.post(
      '$baseUrl/auth/user/logout',
      data: {'refreshToken': refreshToken},
    );
  }
}
