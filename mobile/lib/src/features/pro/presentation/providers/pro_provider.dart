import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pro_api_client.dart';

class ProState {
  final ProStatusModel? status;
  final List<ProPlanModel> plans;
  final String selectedPlanType;
  final bool isLoadingStatus;
  final bool isLoadingPlans;
  final bool isCreatingCheckout;
  final String? checkoutUrl;
  final String? error;

  const ProState({
    this.status,
    this.plans = const [],
    this.selectedPlanType = 'monthly',
    this.isLoadingStatus = false,
    this.isLoadingPlans = false,
    this.isCreatingCheckout = false,
    this.checkoutUrl,
    this.error,
  });

  ProState copyWith({
    ProStatusModel? status,
    List<ProPlanModel>? plans,
    String? selectedPlanType,
    bool? isLoadingStatus,
    bool? isLoadingPlans,
    bool? isCreatingCheckout,
    String? checkoutUrl,
    String? error,
    bool clearError = false,
  }) {
    return ProState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      selectedPlanType: selectedPlanType ?? this.selectedPlanType,
      isLoadingStatus: isLoadingStatus ?? this.isLoadingStatus,
      isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
      isCreatingCheckout: isCreatingCheckout ?? this.isCreatingCheckout,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProNotifier extends StateNotifier<ProState> {
  final ProApiClient _api;

  ProNotifier(this._api) : super(const ProState()) {
    loadPlans();
    loadStatus();
  }

  Future<void> loadPlans() async {
    state = state.copyWith(isLoadingPlans: true, clearError: true);
    try {
      final plans = await _api.getPlans();
      final selectedPlanType = plans
              .any((p) => p.planType == state.selectedPlanType)
          ? state.selectedPlanType
          : (plans.isNotEmpty ? plans.first.planType : state.selectedPlanType);

      state = state.copyWith(
        plans: plans,
        selectedPlanType: selectedPlanType,
        isLoadingPlans: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoadingPlans: false,
        error: _messageFromDioError(e),
      );
    } catch (e) {
      state = state.copyWith(isLoadingPlans: false, error: e.toString());
    }
  }

  void selectPlanType(String planType) {
    state = state.copyWith(selectedPlanType: planType);
  }

  Future<void> loadStatus() async {
    state = state.copyWith(isLoadingStatus: true, clearError: true);
    try {
      final status = await _api.getStatus();
      state = state.copyWith(status: status, isLoadingStatus: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoadingStatus: false,
        error: _messageFromDioError(e),
      );
    } catch (e) {
      state = state.copyWith(isLoadingStatus: false, error: e.toString());
    }
  }

  Future<String?> createCheckout({int? amount}) async {
    state = state.copyWith(isCreatingCheckout: true, clearError: true);
    try {
      final checkout = await _api.createCheckout(
        planType: state.selectedPlanType,
        amount: amount,
      );
      state = state.copyWith(
        isCreatingCheckout: false,
        checkoutUrl: checkout.checkoutUrl,
      );
      return checkout.checkoutUrl;
    } on DioException catch (e) {
      state = state.copyWith(
        isCreatingCheckout: false,
        error: _messageFromDioError(e),
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isCreatingCheckout: false,
        error: e.toString(),
      );
      return null;
    }
  }

  String _messageFromDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? 'Request failed';
  }
}

final proNotifierProvider = StateNotifierProvider<ProNotifier, ProState>((ref) {
  final api = ref.watch(proApiClientProvider);
  return ProNotifier(api);
});
