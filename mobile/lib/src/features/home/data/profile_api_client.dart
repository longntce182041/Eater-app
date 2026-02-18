import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/dio_provider.dart';
import '../domain/profile_models.dart';

final profileApiClientProvider = Provider<ProfileApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileApiClient(dio);
});

class ProfileApiClient {
  final Dio _dio;
  ProfileApiClient(this._dio);

  Future<ProfileCombinedData> getProfile() async {
    final res = await _dio.get('/api/profile/view');
    return ProfileCombinedData.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ProfileCombinedData> updateProfile(Map<String, dynamic> body) async {
    debugPrint('updateProfile request body: $body');
    debugPrint(
      'updateProfile body types: ${body.entries.map((e) => '${e.key}: ${e.value.runtimeType}').join(", ")}',
    );
    try {
      final res = await _dio.put('/api/profile/update', data: body);
      debugPrint('updateProfile response: ${res.data}');
      return ProfileCombinedData.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('updateProfile error response: ${e.response?.data}');
      rethrow;
    }
  }
}
