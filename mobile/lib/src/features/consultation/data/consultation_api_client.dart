import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/dio_provider.dart';
import 'consultation_models.dart';

class ConsultationApiClient {
  final Dio _dio;
  final String _baseUrl;

  ConsultationApiClient(this._dio, this._baseUrl);

  /// GET /api/consultations/my
  Future<List<ConsultationSummary>> getMyConsultations({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/api/consultations/my',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      },
    );
    final data = response.data['data'];
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => ConsultationSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/consultations/nutritionists
  Future<List<NutritionistInfo>> getNutritionists() async {
    final response =
        await _dio.get('$_baseUrl/api/consultations/nutritionists');
    final items = response.data['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => NutritionistInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/consultations
  Future<ConsultationSummary> createConsultation(
      CreateConsultationDto dto) async {
    final response = await _dio.post(
      '$_baseUrl/api/consultations',
      data: dto.toJson(),
    );
    return ConsultationSummary.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// GET /api/consultations/:id
  Future<ConsultationDetail> getDetail(String id) async {
    final response = await _dio.get('$_baseUrl/api/consultations/$id');
    return ConsultationDetail.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// PATCH /api/consultations/:id/status
  Future<void> closeConsultation(String id) async {
    await _dio.patch(
      '$_baseUrl/api/consultations/$id/status',
      data: {'status': 'closed'},
    );
  }
}

final consultationApiClientProvider = Provider<ConsultationApiClient>((ref) {
  return ConsultationApiClient(
    ref.watch(dioProvider),
    ref.watch(appConfigProvider).apiBaseUrl,
  );
});
