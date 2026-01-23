import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  Dio get instance => _dio;

  static Dio createBaseDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: '', // set in provider using AppConfig
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        contentType: Headers.jsonContentType,
      ),
    );
    return dio;
  }
}