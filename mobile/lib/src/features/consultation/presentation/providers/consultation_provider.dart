import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/consultation_api_client.dart';
import '../../data/consultation_models.dart';

// ── List state ────────────────────────────────────────────────────

class ConsultationListState {
  final bool isLoading;
  final List<ConsultationSummary> items;
  final String? error;
  final String? activeStatusFilter;

  const ConsultationListState({
    this.isLoading = false,
    this.items = const [],
    this.error,
    this.activeStatusFilter,
  });

  ConsultationListState copyWith({
    bool? isLoading,
    List<ConsultationSummary>? items,
    String? error,
    String? activeStatusFilter,
    bool clearError = false,
  }) {
    return ConsultationListState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: clearError ? null : error ?? this.error,
      activeStatusFilter: activeStatusFilter ?? this.activeStatusFilter,
    );
  }
}

class ConsultationListNotifier extends StateNotifier<ConsultationListState> {
  final ConsultationApiClient _api;

  ConsultationListNotifier(this._api) : super(const ConsultationListState());

  Future<void> load({String? status}) async {
    state = state.copyWith(
        isLoading: true, clearError: true, activeStatusFilter: status);
    try {
      final items = await _api.getMyConsultations(status: status);
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void prependItem(ConsultationSummary item) {
    state = state.copyWith(items: [item, ...state.items]);
  }
}

final consultationListProvider =
    StateNotifierProvider<ConsultationListNotifier, ConsultationListState>(
        (ref) {
  return ConsultationListNotifier(ref.watch(consultationApiClientProvider));
});

// ── Detail state ──────────────────────────────────────────────────

class ConsultationDetailState {
  final bool isLoading;
  final ConsultationDetail? detail;
  final String? error;

  const ConsultationDetailState({
    this.isLoading = false,
    this.detail,
    this.error,
  });

  ConsultationDetailState copyWith({
    bool? isLoading,
    ConsultationDetail? detail,
    String? error,
    bool clearError = false,
  }) {
    return ConsultationDetailState(
      isLoading: isLoading ?? this.isLoading,
      detail: detail ?? this.detail,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ConsultationDetailNotifier
    extends StateNotifier<ConsultationDetailState> {
  final ConsultationApiClient _api;
  final String _id;

  ConsultationDetailNotifier(this._api, this._id)
      : super(const ConsultationDetailState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _api.getDetail(_id);
      state = state.copyWith(isLoading: false, detail: detail);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> close() async {
    try {
      await _api.closeConsultation(_id);
      // Reload to get updated status
      await load();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final consultationDetailProvider = StateNotifierProvider.family<
    ConsultationDetailNotifier, ConsultationDetailState, String>((ref, id) {
  return ConsultationDetailNotifier(
      ref.watch(consultationApiClientProvider), id);
});

// ── Nutritionists list ────────────────────────────────────────────

final nutritionistsProvider = FutureProvider<List<NutritionistInfo>>((ref) {
  return ref.watch(consultationApiClientProvider).getNutritionists();
});
