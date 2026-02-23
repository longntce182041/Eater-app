import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../home/domain/profile_models.dart';

// Data model for dietary references
class DietaryRefData {
  final String? dietTypeId;
  final List<String> allergies;
  final List<String> dislikesIngredients;
  final String? activityLevel;
  final String? cookingSkillLevel;
  final int? availableCookingTime;
  final int? dailyCalorieTarget;

  DietaryRefData({
    this.dietTypeId,
    this.allergies = const [],
    this.dislikesIngredients = const [],
    this.activityLevel,
    this.cookingSkillLevel,
    this.availableCookingTime,
    this.dailyCalorieTarget,
  });

  DietaryRefData copyWith({
    String? dietTypeId,
    List<String>? allergies,
    List<String>? dislikesIngredients,
    String? activityLevel,
    String? cookingSkillLevel,
    int? availableCookingTime,
    int? dailyCalorieTarget,
  }) {
    return DietaryRefData(
      dietTypeId: dietTypeId ?? this.dietTypeId,
      allergies: allergies ?? this.allergies,
      dislikesIngredients: dislikesIngredients ?? this.dislikesIngredients,
      activityLevel: activityLevel ?? this.activityLevel,
      cookingSkillLevel: cookingSkillLevel ?? this.cookingSkillLevel,
      availableCookingTime: availableCookingTime ?? this.availableCookingTime,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diet_typeId': dietTypeId,
      'allergies': allergies,
      'dislikesIngredients': dislikesIngredients,
      'activityLevel': activityLevel,
      'cookingSkillLevel': cookingSkillLevel,
      'available_cooking_time': availableCookingTime,
      'daily_calorie_target': dailyCalorieTarget,
    };
  }
}

// Provider to fetch diet types from backend
final dietTypesProvider = FutureProvider<List<DietTypeModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/api/health/diet-types');
  final List list = res.data is List ? res.data : (res.data['data'] ?? []);
  return list
      .map((e) => DietTypeModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});

// State class
class DietaryRefState {
  final DietaryRefData data;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitted;

  DietaryRefState({
    required this.data,
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitted = false,
  });

  DietaryRefState copyWith({
    DietaryRefData? data,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitted,
  }) {
    return DietaryRefState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

// StateNotifier
class DietaryRefNotifier extends StateNotifier<DietaryRefState> {
  final Dio _dio;

  DietaryRefNotifier(this._dio)
    : super(DietaryRefState(data: DietaryRefData()));

  void setDietType(String dietTypeId) {
    state = state.copyWith(
      data: state.data.copyWith(dietTypeId: dietTypeId),
      errorMessage: null,
    );
  }

  void setAllergies(List<String> allergies) {
    state = state.copyWith(
      data: state.data.copyWith(allergies: allergies),
      errorMessage: null,
    );
  }

  void setDislikesIngredients(List<String> dislikes) {
    state = state.copyWith(
      data: state.data.copyWith(dislikesIngredients: dislikes),
      errorMessage: null,
    );
  }

  void setActivityLevel(String level) {
    state = state.copyWith(
      data: state.data.copyWith(activityLevel: level),
      errorMessage: null,
    );
  }

  void setCookingSkillLevel(String level) {
    state = state.copyWith(
      data: state.data.copyWith(cookingSkillLevel: level),
      errorMessage: null,
    );
  }

  void setAvailableCookingTime(int time) {
    state = state.copyWith(
      data: state.data.copyWith(availableCookingTime: time),
      errorMessage: null,
    );
  }

  void setDailyCalorieTarget(int calories) {
    state = state.copyWith(
      data: state.data.copyWith(dailyCalorieTarget: calories),
      errorMessage: null,
    );
  }

  Future<bool> submitDietaryReferences() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      debugPrint('Submitting dietary references: ${state.data.toJson()}');

      final response = await _dio.post(
        '/api/health/dietary-references',
        data: state.data.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(isLoading: false, isSubmitted: true);
        debugPrint('Dietary references submitted: ${response.data}');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to submit dietary references',
        );
        return false;
      }
    } on DioException catch (e) {
      final String fallback = 'Network error occurred';
      String? message;
      final data = e.response?.data;
      if (data is Map) {
        final m = data['message'];
        if (m is String) {
          message = m;
        }
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: message ?? e.message ?? fallback,
      );
      debugPrint('Error submitting dietary refs: ${e.message}');
      debugPrint('Error response: ${e.response?.data}');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
      debugPrint('Unexpected error: $e');
      return false;
    }
  }

  void reset() {
    state = DietaryRefState(data: DietaryRefData());
  }
}

// Provider
final dietaryRefProvider =
    StateNotifierProvider<DietaryRefNotifier, DietaryRefState>((ref) {
      final dio = ref.watch(dioProvider);
      return DietaryRefNotifier(dio);
    });
