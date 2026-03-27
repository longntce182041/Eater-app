import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/cooking_api.dart';
import '../../domain/cooking_models.dart';
import '../../../../shared/providers/dio_provider.dart';

// Provider for CookingAPI
final cookingApiProvider = Provider<CookingAPI>((ref) {
  final dio = ref.watch(dioProvider); // from shared providers
  return CookingAPI(dio);
});

// ============ COOKING SESSION MANAGEMENT ============

/// State for cooking mode
class CookingModeState {
  final CookingModeData? data;
  final bool isLoading;
  final String? error;
  final int elapsedSeconds; // Track elapsed time
  final bool isTimerRunning;

  CookingModeState({
    this.data,
    this.isLoading = false,
    this.error,
    this.elapsedSeconds = 0,
    this.isTimerRunning = false,
  });

  CookingModeState copyWith({
    CookingModeData? data,
    bool? isLoading,
    String? error,
    int? elapsedSeconds,
    bool? isTimerRunning,
  }) {
    return CookingModeState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
    );
  }
}

/// Notifier for managing cooking session
class CookingModeNotifier extends StateNotifier<CookingModeState> {
  final CookingAPI _api;
  String? _currentRecipeId;
  String? _currentSessionId;

  CookingModeNotifier(this._api) : super(CookingModeState());

  /// Start a new cooking session
  Future<void> startCooking({
    required String recipeId,
    int servings = 1,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.startCookingSession(
        recipeId: recipeId,
        servings: servings,
      );
      _currentRecipeId = recipeId;
      _currentSessionId = data.session.id;
      state = state.copyWith(
        data: data,
        isLoading: false,
        isTimerRunning: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh cooking session data from server
  Future<void> refreshSession() async {
    if (_currentRecipeId == null || _currentSessionId == null) return;

    try {
      final data = await _api.getCookingSession(
        recipeId: _currentRecipeId!,
        sessionId: _currentSessionId!,
      );
      state = state.copyWith(data: data, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Complete a cooking step
  Future<void> completeStep({
    required int stepNumber,
    String? notes,
  }) async {
    if (_currentRecipeId == null || _currentSessionId == null) return;

    try {
      await _api.completeStep(
        recipeId: _currentRecipeId!,
        sessionId: _currentSessionId!,
        stepNumber: stepNumber,
        notes: notes,
      );

      // Refresh session immediately
      await refreshSession();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Skip to next step
  Future<void> skipToNextStep() async {
    final currentIndex = state.data?.session.currentStepIndex ?? 0;
    final nextStepIndex = currentIndex + 1;

    if (nextStepIndex < (state.data?.totalSteps ?? 0)) {
      // Just mark current step as complete to advance
      await completeStep(stepNumber: currentIndex + 1);
    }
  }

  /// Pause cooking session
  Future<void> pauseCooking() async {
    if (_currentRecipeId == null || _currentSessionId == null) return;

    try {
      await _api.pauseCookingSession(
        recipeId: _currentRecipeId!,
        sessionId: _currentSessionId!,
      );
      state = state.copyWith(
        data: state.data?.copyWith(
          session: state.data!.session.copyWith(status: 'paused'),
        ),
        isTimerRunning: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Resume cooking session
  Future<void> resumeCooking() async {
    if (_currentRecipeId == null || _currentSessionId == null) return;

    try {
      await _api.resumeCookingSession(
        recipeId: _currentRecipeId!,
        sessionId: _currentSessionId!,
      );
      state = state.copyWith(
        data: state.data?.copyWith(
          session: state.data!.session.copyWith(status: 'active'),
        ),
        isTimerRunning: true,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Complete cooking session
  Future<void> finishCooking({String? notes}) async {
    if (_currentRecipeId == null || _currentSessionId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.completeCookingSession(
        recipeId: _currentRecipeId!,
        sessionId: _currentSessionId!,
        notes: notes,
      );
      state = state.copyWith(
        data: state.data?.copyWith(
          session: state.data!.session.copyWith(status: 'completed'),
        ),
        isLoading: false,
        isTimerRunning: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update elapsed time (called by timer)
  void updateElapsedTime() {
    state = state.copyWith(
      elapsedSeconds: state.elapsedSeconds + 1,
    );
  }

  /// Reset cooking state
  void reset() {
    state = CookingModeState();
    _currentRecipeId = null;
    _currentSessionId = null;
  }
}

/// Main provider for cooking mode
final cookingModeProvider =
    StateNotifierProvider<CookingModeNotifier, CookingModeState>((ref) {
  final api = ref.watch(cookingApiProvider);
  return CookingModeNotifier(api);
});

// ============ STEP-SPECIFIC PROVIDERS ============

/// Get current cooking step
final currentCookingStepProvider = Provider<RecipeStep?>((ref) {
  final state = ref.watch(cookingModeProvider);
  return state.data?.currentStep;
});

/// Get progress percentage
final cookingProgressProvider = Provider<double>((ref) {
  final state = ref.watch(cookingModeProvider);
  return state.data?.progressPercentage ?? 0;
});

/// Get formatted elapsed time
final formattedElapsedTimeProvider = Provider<String>((ref) {
  final state = ref.watch(cookingModeProvider);
  final seconds = state.elapsedSeconds;

  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
});

/// Get time remaining for current step
final stepTimeRemainingProvider = Provider<int>((ref) {
  final step = ref.watch(currentCookingStepProvider);
  return step?.estimatedTime ?? 300; // default 5 min
});

/// Provider to fetch recipe steps
final recipeStepsProvider =
    FutureProvider.family<List<RecipeStep>, String>((ref, recipeId) async {
  final api = ref.watch(cookingApiProvider);
  return api.getRecipeSteps(recipeId: recipeId);
});

// ============ STEP TRACKING ============

/// Provider for tracking step notes
final stepNotesProvider = StateProvider<Map<int, String>>((ref) => {});

/// Add note to a step
final addStepNoteProvider = Provider((ref) {
  return (int stepNumber, String note) {
    final notes = ref.read(stepNotesProvider);
    ref.read(stepNotesProvider.notifier).state = {
      ...notes,
      stepNumber: note,
    };
  };
});

/// Get note for a step
final getStepNoteProvider = Provider.family<String?, int>((ref, stepNumber) {
  final notes = ref.watch(stepNotesProvider);
  return notes[stepNumber];
});

// ============ TIMER PROVIDERS ============

/// Provider for step timer state
class StepTimerState {
  final int remainingSeconds;
  final bool isRunning;
  final bool isCompleted;

  StepTimerState({
    required this.remainingSeconds,
    this.isRunning = false,
    this.isCompleted = false,
  });

  StepTimerState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    bool? isCompleted,
  }) {
    return StepTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  String get displayTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Notifier for managing step-specific timers
class StepTimerNotifier extends StateNotifier<StepTimerState> {
  final int estimatedSeconds;

  StepTimerNotifier(this.estimatedSeconds)
      : super(StepTimerState(remainingSeconds: estimatedSeconds));

  void startTimer() {
    state = state.copyWith(isRunning: true);
  }

  void pauseTimer() {
    state = state.copyWith(isRunning: false);
  }

  void tick() {
    if (!state.isRunning) return;

    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else {
      state = state.copyWith(isRunning: false, isCompleted: true);
      // Could trigger notification here
    }
  }

  void reset() {
    state = StepTimerState(remainingSeconds: estimatedSeconds);
  }
}

/// Family provider for step timers
final stepTimerProvider =
    StateNotifierProvider.family<StepTimerNotifier, StepTimerState, int>(
        (ref, estimatedSeconds) {
  return StepTimerNotifier(estimatedSeconds);
});
