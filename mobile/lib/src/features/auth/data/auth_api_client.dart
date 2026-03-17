import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthApiClient {
  final Dio _dio;
  final String baseUrl;

  AuthApiClient({required Dio dio, required this.baseUrl}) : _dio = dio;

  Future<Response<dynamic>> register({
    required String email,
    required String password,
  }) {
    final url = '$baseUrl/api/auth/user/register';
    debugPrint('🌐 API register: $url');
    return _dio.post(url, data: {'email': email, 'password': password});
  }

  Future<Response<dynamic>> login({
    required String email,
    required String password,
  }) {
    final url = '$baseUrl/api/auth/user/login';
    debugPrint('🌐 API login URL: $url');
    return _dio.post(url, data: {'email': email, 'password': password});
  }

  Future<Response<dynamic>> verifyEmail({required String token}) {
    final url = '$baseUrl/api/auth/verify-email';
    return _dio.post(url, data: {'token': token});
  }

  Future<Response<dynamic>> requestPasswordReset({required String email}) {
    final url = '$baseUrl/api/auth/user/request-password-reset';
    return _dio.post(url, data: {'email': email});
  }

  Future<Response<dynamic>> resetPassword({
    required String otp,
    required String newPassword,
  }) {
    final url = '$baseUrl/api/auth/user/reset-password';
    return _dio.post(url, data: {'otp': otp, 'newPassword': newPassword});
  }

  Future<Response<dynamic>> refresh({required String refreshToken}) {
    final url = '$baseUrl/api/auth/user/refresh';
    return _dio.post(url, data: {'refreshToken': refreshToken});
  }

  Future<Response<dynamic>> logout({required String refreshToken}) {
    final url = '$baseUrl/api/auth/user/logout';
    return _dio.post(url, data: {'refreshToken': refreshToken});
  }
}
