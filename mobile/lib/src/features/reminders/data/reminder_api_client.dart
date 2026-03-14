import 'package:dio/dio.dart';

import '../domain/reminder_model.dart';

class ReminderApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  ReminderApiException({required this.message, this.statusCode, this.code});

  @override
  String toString() => message;
}

/// API client for mealtime reminder CRUD operations.
/// Communicates with backend: /api/reminders
class ReminderApiClient {
  final Dio _dio;
  final String baseUrl;

  ReminderApiClient(this._dio, this.baseUrl);

  String get _base => '$baseUrl/api/reminders';

  ReminderModel _parse(Map<String, dynamic> data) =>
      ReminderModel.fromJson(data);

  void _throwFromDio(DioException e) {
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? (data['message'] as String? ?? e.message ?? 'Request failed')
        : (e.message ?? 'Request failed');
    final code = data is Map<String, dynamic> ? data['code'] as String? : null;
    throw ReminderApiException(
      message: message,
      statusCode: e.response?.statusCode,
      code: code,
    );
  }

  /// GET /api/reminders
  /// Returns all reminders for the authenticated user.
  Future<List<ReminderModel>> getAll() async {
    try {
      final response = await _dio.get(_base);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((e) => _parse(e as Map<String, dynamic>)).toList();
      }
      throw ReminderApiException(message: 'Failed to fetch reminders');
    } on DioException catch (e) {
      _throwFromDio(e);
      rethrow;
    }
  }

  /// PUT /api/reminders/:mealType
  /// Create or update a reminder.
  Future<ReminderModel> upsert(ReminderModel reminder) async {
    try {
      final url = '$_base/${reminder.mealType}';
      final response = await _dio.put(url, data: reminder.toJson());
      if (response.statusCode == 200 && response.data['success'] == true) {
        return _parse(response.data['data'] as Map<String, dynamic>);
      }
      throw ReminderApiException(message: 'Failed to save reminder');
    } on DioException catch (e) {
      _throwFromDio(e);
      rethrow;
    }
  }

  /// PATCH /api/reminders/:mealType/toggle
  /// Toggle a reminder on/off.
  Future<ReminderModel> toggle(String mealType) async {
    try {
      final url = '$_base/$mealType/toggle';
      final response = await _dio.patch(url);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return _parse(response.data['data'] as Map<String, dynamic>);
      }
      throw ReminderApiException(message: 'Failed to toggle reminder');
    } on DioException catch (e) {
      _throwFromDio(e);
      rethrow;
    }
  }

  /// DELETE /api/reminders/:mealType
  Future<void> delete(String mealType) async {
    try {
      final url = '$_base/$mealType';
      final response = await _dio.delete(url);
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ReminderApiException(message: 'Failed to delete reminder');
      }
    } on DioException catch (e) {
      _throwFromDio(e);
      rethrow;
    }
  }
}
