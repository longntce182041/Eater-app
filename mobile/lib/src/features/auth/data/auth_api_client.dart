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
      '$baseUrl/auth/register',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response<dynamic>> login({
    required String email,
    required String password,
  }) {
    return _dio.post(
      '$baseUrl/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response<dynamic>> verifyEmail({required String token}) {
    return _dio.post('$baseUrl/auth/verify-email', data: {'token': token});
  }

  Future<Response<dynamic>> requestPasswordReset({required String email}) {
    return _dio.post(
      '$baseUrl/auth/request-password-reset',
      data: {'email': email},
    );
  }

  Future<Response<dynamic>> resetPassword({
    required String otp,
    required String newPassword,
  }) {
    return _dio.post(
      '$baseUrl/auth/reset-password',
      data: {'otp': otp, 'newPassword': newPassword},
    );
  }

  Future<Response<dynamic>> refresh({required String refreshToken}) {
    return _dio.post(
      '$baseUrl/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
  }

  Future<Response<dynamic>> logout({required String refreshToken}) {
    return _dio.post(
      '$baseUrl/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }
}
