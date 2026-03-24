import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/dio_provider.dart';
import 'chat_models.dart';

class ChatApiClient {
  final Dio _dio;
  final String _baseUrl;

  ChatApiClient(this._dio, this._baseUrl);

  /// GET /api/chat/:nutritionistId/messages
  Future<List<ChatMessage>> getHistory(
    String nutritionistId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/api/chat/$nutritionistId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final items = data['messages'] as List<dynamic>? ?? [];
    return items
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/chat/nutritionists
  Future<List<NutritionistInfo>> getNutritionists() async {
    final response = await _dio.get('$_baseUrl/api/chat/nutritionists');
    final items = response.data['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => NutritionistInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final chatApiClientProvider = Provider<ChatApiClient>((ref) {
  return ChatApiClient(
    ref.watch(dioProvider),
    ref.watch(appConfigProvider).apiBaseUrl,
  );
});
