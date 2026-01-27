import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../config/env/env_loader.dart';
import '../../../../shared/providers/dio_provider.dart';

// Model for profile setup data
class ProfileSetupData {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final int? age;
  final String? gender;
  final int? height; // in cm
  final double? weight; // in kg
  final String? weightGoal; // 'lose', 'maintain', 'gain'

  ProfileSetupData({
    required this.userId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.weightGoal,
  });

  ProfileSetupData copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    int? age,
    String? gender,
    int? height,
    double? weight,
    String? weightGoal,
    List<String>? dietaryPreferences,
    List<String>? allergies,
  }) {
    return ProfileSetupData(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      weightGoal: weightGoal ?? this.weightGoal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // userId is extracted from JWT token by backend, don't send it
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'healthGoals': weightGoal,
    };
  }
}

// State class
class ProfileSetupState {
  final ProfileSetupData data;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitted;

  ProfileSetupState({
    required this.data,
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitted = false,
  });

  ProfileSetupState copyWith({
    ProfileSetupData? data,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitted,
  }) {
    return ProfileSetupState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

// StateNotifier
class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  final Dio _dio;
  final String _userId;

  ProfileSetupNotifier(this._dio, this._userId)
    : super(ProfileSetupState(data: ProfileSetupData(userId: _userId)));

  void setFirstName(String firstName) {
    state = state.copyWith(
      data: state.data.copyWith(firstName: firstName),
      errorMessage: null,
    );
  }

  void setLastName(String lastName) {
    state = state.copyWith(
      data: state.data.copyWith(lastName: lastName),
      errorMessage: null,
    );
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(
      data: state.data.copyWith(phoneNumber: phoneNumber),
      errorMessage: null,
    );
  }

  void setAge(int age) {
    state = state.copyWith(
      data: state.data.copyWith(age: age),
      errorMessage: null,
    );
  }

  void setGender(String gender) {
    state = state.copyWith(
      data: state.data.copyWith(gender: gender),
      errorMessage: null,
    );
  }

  void setHeight(int height) {
    state = state.copyWith(
      data: state.data.copyWith(height: height),
      errorMessage: null,
    );
  }

  void setWeight(double weight) {
    state = state.copyWith(
      data: state.data.copyWith(weight: weight),
      errorMessage: null,
    );
  }

  void setWeightGoal(String goal) {
    state = state.copyWith(
      data: state.data.copyWith(weightGoal: goal),
      errorMessage: null,
    );
  }

  void setDietaryPreferences(List<String> preferences) {
    state = state.copyWith(
      data: state.data.copyWith(dietaryPreferences: preferences),
      errorMessage: null,
    );
  }

  void setAllergies(List<String> allergies) {
    state = state.copyWith(
      data: state.data.copyWith(allergies: allergies),
      errorMessage: null,
    );
  }

  Future<bool> submitProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final config = EnvLoader.load();
      debugPrint(
        'Submitting profile to ${config.apiBaseUrl}/api/health/user-profile',
      );
      debugPrint('Profile data: ${state.data.toJson()}');

      final response = await _dio.post(
        '/api/health/user-profile',
        data: state.data.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(isLoading: false, isSubmitted: true);
        debugPrint('Profile submitted successfully: ${response.data}');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to submit profile',
        );
        return false;
      }
    } on DioException catch (e) {
      final String fallback = 'Network error occurred';
      // Safely extract message from response data if available
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
      debugPrint('Error submitting profile: ${e.message}');
      debugPrint('Error response status: ${e.response?.statusCode}');
      debugPrint('Error response data: ${e.response?.data}');
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
    // Preserve userId and clear other fields
    state = ProfileSetupState(data: ProfileSetupData(userId: _userId));
  }
}

// Provider
final profileSetupProvider =
    StateNotifierProvider.family<
      ProfileSetupNotifier,
      ProfileSetupState,
      String
    >((ref, userId) {
      // Use the shared Dio provider that includes authentication
      final dio = ref.watch(dioProvider);
      return ProfileSetupNotifier(dio, userId);
    });
