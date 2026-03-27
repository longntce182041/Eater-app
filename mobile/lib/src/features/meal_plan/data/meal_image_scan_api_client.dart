import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/dio_provider.dart';
import '../domain/meal_image_scan_models.dart';

final mealImageScanApiClientProvider = Provider<MealImageScanApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return MealImageScanApiClient(dio, config.apiBaseUrl);
});

class MealImageScanApiClient {
  final Dio _dio;
  final String _baseUrl;

  MealImageScanApiClient(this._dio, this._baseUrl);

  Future<MealImageScanResult> scanMealImage({required String imagePath}) async {
    final fileName = _extractFileName(imagePath);
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath, filename: fileName),
    });

    final response = await _dio.post(
      '$_baseUrl/api/ai/scan-meal',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    final payload = response.data as Map<String, dynamic>;
    if (payload.containsKey('success')) {
      if (payload['success'] != true) {
        throw Exception(payload['message'] ?? 'Failed to scan meal image');
      }

      final data = Map<String, dynamic>.from(
        (payload['data'] as Map?) ?? const {},
      );
      return MealImageScanResult.fromJson(data);
    }

    return MealImageScanResult.fromJson(payload);
  }

  String _extractFileName(String imagePath) {
    final normalized = imagePath.replaceAll('\\', '/');
    final idx = normalized.lastIndexOf('/');
    if (idx < 0) return 'meal-image.jpg';
    return normalized.substring(idx + 1);
  }
}
