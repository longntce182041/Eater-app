import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/cooking_api.dart';
import '../../domain/cooking_models.dart';
import '../../../../shared/providers/dio_provider.dart';

/// 🎯 INTERACTIVE COOKING PROVIDERS
///
/// Riverpod state management for cooking features:
/// - cookingApiProvider: Provides CookingAPI instance
/// - cookingModeProvider: Main state notifier for active cooking session
/// - currentCookingStepProvider: Derives current step from session
/// - cookingProgressProvider: Calculates progress percentage
/// - stepTimerProvider: Manages individual step timers
/// - stepNotesProvider: Tracks user notes per step
/// - formattedElapsedTimeProvider: Formats elapsed time for display
///
/// Architecture:
/// - Single source of truth: cookingModeProvider (StateNotifier)
/// - Derived providers: currentCookingStepProvider, cookingProgressProvider
/// - UI watches providers and rebuilds on changes
///
/// State Flow:
/// 1. User taps "Start Cooking" → startCooking() called
/// 2. CookingModeNotifier fetches session via API
/// 3. State updated with CookingModeData
/// 4. UI rebuilds showing current step
/// 5. User marks step complete → completeStep() called
/// 6. Session refreshed from server
/// 7. currentStepIndex incremented
/// 8. UI rebuilds showing next step

/// 🔌 API Client Provider
///
/// Initializes CookingAPI with authenticated Dio client
/// Watches dioProvider - rebuilds if authentication changes
final cookingApiProvider = Provider<CookingAPI>((ref) {
  final dio = ref.watch(dioProvider); // from shared providers
  return CookingAPI(dio);
});

// ============ COOKING SESSION MANAGEMENT ============

/// 📊 Cooking Mode State
///
/// Holds all state for the active cooking session:
/// - data: The complete cooking data (session + recipe + steps)
/// - isLoading: Currently fetching from backend
/// - error: Last error message (for error UI)
/// - elapsedSeconds: Total time elapsed since session start
/// - isTimerRunning: Whether the timer is currently counting
///
/// Lifecycle:
/// - Initial: All nulls, isLoading=false (no session yet)
/// - Starting: isLoading=true (fetching from API)
/// - Active: data loaded, isTimerRunning=true
/// - Paused: data present, isTimerRunning=false
/// - Completed: status="completed", isTimerRunning=false
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

  /// 📋 Create modified copy of state
  ///
  /// Used to update state after API calls or timer ticks:
  /// ```dart
  /// state = state.copyWith(
  ///   isLoading: false,
  ///   data: newData,
  ///   error: null,
  /// );
  /// ```
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

/// 📍 Cooking Mode State Notifier
///
/// Manages all cooking session operations:
/// - startCooking(): Begin cooking a recipe
/// - completeStep(): Mark step as done, advance to next
/// - pauseCooking(): Pause the session
/// - resumeCooking(): Resume after pause
/// - finishCooking(): Complete entire cooking session
/// - updateElapsedTime(): Called by timer every second
/// - reset(): Clear all state
///
/// Internal tracking:
/// - _currentRecipeId: Used to make API calls
/// - _currentSessionId: Session ID for backend requests
///
/// Error Handling:
/// - Exceptions from API calls are caught
/// - State.error set for UI error display
/// - isLoading controlled to prevent duplicate requests
class CookingModeNotifier extends StateNotifier<CookingModeState> {
  final CookingAPI _api;
  String? _currentRecipeId;
  String? _currentSessionId;

  CookingModeNotifier(this._api) : super(CookingModeState());

  /// 🚀 Start a New Cooking Session
  ///
  /// Steps:
  /// 1. Set isLoading=true
  /// 2. Call API to start session
  /// 3. Store recipe/session IDs for future calls
  /// 4. Update state with returned CookingModeData
  /// 5. Start timer (isTimerRunning=true)
  ///
  /// Usage:
  /// ```dart
  /// await ref.read(cookingModeProvider.notifier).startCooking(
  ///   recipeId: 'recipe_123',
  ///   servings: 4,
  /// );
  /// ```
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

  /// 🔄 Refresh Session Data from Server
  ///
  /// Called after step completion to sync with server
  /// Updates state with latest session data (timing, progress)
  ///
  /// Guards:
  /// - Returns early if _currentRecipeId or _currentSessionId null
  /// - Doesn't touch isLoading (background operation)
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

  /// ✅ Mark Current Step as Completed
  ///
/// Steps:
  /// 1. Validate we have a session
  /// 2. Call API to mark step complete
  /// 3. Refresh session from server (gets updated progress)
  /// 4. UI automatically shows next step via currentStep getter
  ///
  /// Usage:
  /// ```dart
  /// await ref.read(cookingModeProvider.notifier).completeStep(
  ///   stepNumber: 1,
  ///   notes: "Took longer than expected",
  /// );
  /// ```
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

  /// ⏭️ Skip to Next Step
  ///
  /// Convenience method to advance without marking current step complete
  /// Used by "Skip" or "Next" button
  Future<void> skipToNextStep() async {
    final currentIndex = state.data?.session.currentStepIndex ?? 0;
    final nextStepIndex = currentIndex + 1;

    if (nextStepIndex < (state.data?.totalSteps ?? 0)) {
      // Just mark current step as complete to advance
      await completeStep(stepNumber: currentIndex + 1);
    }
  }

  /// ⏸️ Pause Cooking Session
  ///
  /// Changes session status to "paused"
  /// Stops timer locally
  /// Can be resumed later
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

  /// ▶️ Resume Cooking Session
  ///
  /// Changes status from "paused" to "active"
  /// Restarts timer
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

  /// 🎉 Complete Cooking Session
  ///
  /// Called when user finishes last step
  ///
  /// Steps:
  /// 1. Set isLoading=true (prevent user interaction)
  /// 2. Call API to finish session
  /// 3. Update status to "completed"
  /// 4. Stop timer
  ///
  /// Effects:
  /// - Session marked complete on server
  /// - May trigger meal logging (backend dependent)
  /// - Session no longer editable
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

  /// ⏱️ Update Elapsed Time (Called by Timer)
  ///
  /// Called every second by timer widget
  /// Increments elapsedSeconds counter
  /// Used for display only (server tracks actual time)
  void updateElapsedTime() {
    state = state.copyWith(
      elapsedSeconds: state.elapsedSeconds + 1,
    );
  }

  /// 🔄 Reset Cooking State
  ///
  /// Called when:
  /// - User closes cooking screen
  /// - Starting new cooking session
  /// - User exits app
  ///
  /// Clears all cooking data and resets to initial state
  void reset() {
    state = CookingModeState();
    _currentRecipeId = null;
    _currentSessionId = null;
  }
}

/// 📌 Main Cooking Mode Provider
///
/// Central state management for cooking feature
/// Watched by CookingModeScreen and related widgets
///
/// Usage:
/// ```dart
/// final state = ref.watch(cookingModeProvider);
/// final notifier = ref.read(cookingModeProvider.notifier);
/// ```
final cookingModeProvider =
    StateNotifierProvider<CookingModeNotifier, CookingModeState>((ref) {
  final api = ref.watch(cookingApiProvider);
  return CookingModeNotifier(api);
});

// ============ STEP-SPECIFIC PROVIDERS ============

/// 🎯 Current Cooking Step
///
/// Derives current RecipeStep from session state
/// Automatically updates when session.currentStepIndex changes
///
/// Usage in UI:
/// ```dart
/// final step = ref.watch(currentCookingStepProvider);
/// Text(step?.instruction ?? 'No step');
/// ```
final currentCookingStepProvider = Provider<RecipeStep?>((ref) {
  final state = ref.watch(cookingModeProvider);
  return state.data?.currentStep;
});

/// 📊 Cooking Progress Percentage
///
/// Calculates progress as: completedSteps / totalSteps * 100
/// Used for progress bar display
///
/// Returns: 0.0 to 100.0
final cookingProgressProvider = Provider<double>((ref) {
  final state = ref.watch(cookingModeProvider);
  return state.data?.progressPercentage ?? 0;
});

/// ⏱️ Formatted Elapsed Time Display
///
/// Converts elapsedSeconds to HH:MM:SS format
/// Examples:
/// - 125 seconds → "02:05"
/// - 3661 seconds → "1:01:01"
///
/// Used for display in UI (e.g., "Total cooking time: 2:35")
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

/// ⏲️ Time Remaining for Current Step
///
/// Returns estimated time for current step (in seconds)
/// Defaults to 5 minutes (300 seconds) if step has no estimate
///
/// Used to populate step timer
final stepTimeRemainingProvider = Provider<int>((ref) {
  final step = ref.watch(currentCookingStepProvider);
  return step?.estimatedTime ?? 300; // default 5 min
});

/// 📋 Recipe Steps Provider
///
/// Family provider: can fetch steps for any recipe
/// Ingredients are scaled based on servings parameter
///
/// Usage:
/// ```dart
/// final steps = ref.watch(recipeStepsProvider('recipe_123'));
///
/// steps.when(
///   loading: () => CircularProgressIndicator(),
///   error: (err, _) => Text('Error: $err'),
///   data: (stepsList) => ListView(children: stepsList.map(...)),
/// );
/// ```
final recipeStepsProvider =
    FutureProvider.family<List<RecipeStep>, String>((ref, recipeId) async {
  final api = ref.watch(cookingApiProvider);
  return api.getRecipeSteps(recipeId: recipeId);
});

// ============ STEP TRACKING ============

/// 📝 Step Notes Storage
///
/// StateProvider that stores user notes for each step
/// Maps stepNumber → note text
///
/// Usage:
/// ```dart
/// final notes = ref.watch(stepNotesProvider);
/// final noteForStep2 = notes[2] ?? '';
/// ```
final stepNotesProvider = StateProvider<Map<int, String>>((ref) => {});

/// 🖊️ Add Note to Step
///
/// Provider that adds/updates note for a specific step
///
/// Usage:
/// ```dart
/// ref.read(addStepNoteProvider)(2, "Need more heat here");
/// ```
final addStepNoteProvider = Provider((ref) {
  return (int stepNumber, String note) {
    final notes = ref.read(stepNotesProvider);
    ref.read(stepNotesProvider.notifier).state = {
      ...notes,
      stepNumber: note,
    };
  };
});

/// 🔍 Get Note for Specific Step
///
/// Family provider: returns note for given step number
/// Returns null if no note exists
///
/// Usage:
/// ```dart
/// final note = ref.watch(getStepNoteProvider(2));
/// if (note != null) Text(note);
/// ```
final getStepNoteProvider = Provider.family<String?, int>((ref, stepNumber) {
  final notes = ref.watch(stepNotesProvider);
  return notes[stepNumber];
});

// ============ TIMER PROVIDERS ============

/// ⏱️ Step Timer State
///
/// Holds state for a single step's timer:
/// - remainingSeconds: How many seconds left
/// - isRunning: Timer actively counting down
/// - isCompleted: Timer finished (remainingSeconds == 0)
///
/// Lifecycle:
/// - Initial: remainingSeconds = estimatedSeconds, isRunning = false
/// - Running: remainingSeconds decreases, isRunning = true
/// - Completed: remainingSeconds = 0, isRunning = false, isCompleted = true
///
/// Note: Can be reset to restart timer
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

  /// 🎨 Format remaining time as MM:SS string
  ///
  /// Examples:
  /// - 125 seconds → "02:05"
  /// - 30 seconds → "00:30"
  /// - 5 seconds → "00:05"
  String get displayTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// ⏲️ Step Timer State Notifier
///
/// Manages timer for individual cooking steps:
/// - startTimer(): Begin countdown
/// - pauseTimer(): Pause countdown (keeps remaining time)
/// - tick(): Decrement by 1 second (called by UI timer)
/// - reset(): Restart timer to original time
///
/// Initialization:
/// - Takes estimatedSeconds from RecipeStep
/// - Sets remainingSeconds to estimated time
/// - Can trigger notification when complete
///
/// Usage:
/// ```dart
/// final timerState = ref.watch(stepTimerProvider(300)); // 5 min step
/// timerState.displayTime // "05:00"
/// ```
class StepTimerNotifier extends StateNotifier<StepTimerState> {
  final int estimatedSeconds;

  StepTimerNotifier(this.estimatedSeconds)
      : super(StepTimerState(remainingSeconds: estimatedSeconds));

  /// ▶️ Start Timer Countdown
  void startTimer() {
    state = state.copyWith(isRunning: true);
  }

  /// ⏸️ Pause Timer
  void pauseTimer() {
    state = state.copyWith(isRunning: false);
  }

  /// ⏱️ Decrement Timer (Called Each Second)
  ///
  /// Only decrements if timer is running
  /// Stops at 0 and marks as completed
  void tick() {
    if (!state.isRunning) return;

    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else {
      state = state.copyWith(isRunning: false, isCompleted: true);
      // Could trigger notification here
    }
  }

  /// 🔄 Reset Timer to Original Time
  void reset() {
    state = StepTimerState(remainingSeconds: estimatedSeconds);
  }
}

/// 📌 Family Provider for Step Timers
///
/// Create a separate timer for each step
/// Based on estimated time from RecipeStep
///
/// Usage:
/// ```dart
/// final timer = ref.watch(stepTimerProvider(300)); // 5 min timer
/// Text(timer.displayTime);
/// ref.read(stepTimerProvider(300).notifier).startTimer();
/// ```
final stepTimerProvider =
    StateNotifierProvider.family<StepTimerNotifier, StepTimerState, int>(
        (ref, estimatedSeconds) {
  return StepTimerNotifier(estimatedSeconds);
});
