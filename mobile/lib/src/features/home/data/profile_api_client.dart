import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/dio_provider.dart';
import '../domain/profile_models.dart';

final profileApiClientProvider = Provider<ProfileApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return ProfileApiClient(dio, config.apiBaseUrl);
});

class ProfileApiClient {
  final Dio _dio;
  final String baseUrl;

  ProfileApiClient(this._dio, this.baseUrl);

  Future<ProfileCombinedData> getProfile() async {
    final url = '$baseUrl/api/profile/view';
    final res = await _dio.get(url);
    return ProfileCombinedData.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ProfileCombinedData> updateProfile(Map<String, dynamic> body) async {
    debugPrint('updateProfile request body: $body');
    debugPrint(
      'updateProfile body types: ${body.entries.map((e) => '${e.key}: ${e.value.runtimeType}').join(", ")}',
    );
    try {
      final url = '$baseUrl/api/profile/update';
      final res = await _dio.put(url, data: body);
      debugPrint('updateProfile response: ${res.data}');
      return ProfileCombinedData.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('updateProfile error response: ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<DietTypeModel>> getDietTypes() async {
    final url = '$baseUrl/api/health/diet-types';
    final res = await _dio.get(url);
    final list = res.data as List<dynamic>;
    return list
        .map((item) => DietTypeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<HealthMetricsModel> analyzeUserProfile(String userId) async {
    debugPrint('Calling analyzeUserProfile API with userId: $userId');
    try {
      final res = await _dio.post(
        '/api/ai/user-profile/analyze',
        data: {'userId': userId},
      );
      debugPrint('analyzeUserProfile response: ${res.data}');
      final data = res.data as Map<String, dynamic>;
      // Response format: {success: true, data: {metrics: {...}, analysis: {...}}}
      final metricsData = data['data'] as Map<String, dynamic>;
      return HealthMetricsModel.fromJson(
        metricsData['metrics'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('analyzeUserProfile error: ${e.response?.data}');
      rethrow;
    }
  }
}
