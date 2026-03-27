import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/meal_image_scan_api_client.dart';
import '../../domain/meal_image_scan_models.dart';

class MealImageScanState {
  final bool isLoading;
  final String? error;
  final MealImageScanResult? result;
  final String? imagePath;

  const MealImageScanState({
    this.isLoading = false,
    this.error,
    this.result,
    this.imagePath,
  });

  MealImageScanState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    MealImageScanResult? result,
    bool clearResult = false,
    String? imagePath,
    bool clearImage = false,
  }) {
    return MealImageScanState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      result: clearResult ? null : (result ?? this.result),
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
    );
  }
}

class MealImageScanNotifier extends StateNotifier<MealImageScanState> {
  final MealImageScanApiClient _apiClient;
  final ImagePicker _picker = ImagePicker();

  MealImageScanNotifier(this._apiClient) : super(const MealImageScanState());

  bool get supportsCameraSource {
    final platform = defaultTargetPlatform;
    return !kIsWeb &&
        (platform == TargetPlatform.android || platform == TargetPlatform.iOS);
  }

  Future<void> pickAndScan(ImageSource source) async {
    if (source == ImageSource.camera && !supportsCameraSource) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Camera is not supported on this platform. Please use Gallery instead.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 88,
      );

      if (picked == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final result = await _apiClient.scanMealImage(imagePath: picked.path);
      state = state.copyWith(
        isLoading: false,
        result: result,
        imagePath: picked.path,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFromDioException(e),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = const MealImageScanState();
  }

  String _messageFromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    if (e.message != null && e.message!.isNotEmpty) {
      return e.message!;
    }
    return 'Scan meal image failed';
  }
}

final mealImageScanProvider =
    StateNotifierProvider<MealImageScanNotifier, MealImageScanState>((ref) {
  final apiClient = ref.watch(mealImageScanApiClientProvider);
  return MealImageScanNotifier(apiClient);
});
