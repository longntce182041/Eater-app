import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../bootstrap.dart';
import '../../../../shared/providers/app_config_provider.dart'
    as config_provider;
import '../../../../shared/providers/dio_provider.dart' as dio_provider;
import '../../data/reminder_api_client.dart';
import '../../data/reminder_local_service.dart';
import '../../domain/reminder_model.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

final _notificationPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return flutterLocalNotificationsPlugin;
});

final reminderApiClientProvider = Provider<ReminderApiClient>((ref) {
  final dio = ref.watch(dio_provider.dioProvider);
  final config = ref.watch(config_provider.appConfigProvider);
  return ReminderApiClient(dio, config.apiBaseUrl);
});

final reminderLocalServiceProvider = Provider<ReminderLocalService>((ref) {
  final plugin = ref.watch(_notificationPluginProvider);
  return ReminderLocalService(plugin);
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ReminderState {
  final List<ReminderModel> reminders;
  final bool isLoading;
  final String? error;

  const ReminderState({
    this.reminders = defaultReminders,
    this.isLoading = false,
    this.error,
  });

  ReminderState copyWith({
    List<ReminderModel>? reminders,
    bool? isLoading,
    String? error,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Returns the reminder for a meal type, or a default if not yet configured.
  ReminderModel forMealType(String mealType) => reminders.firstWhere(
        (r) => r.mealType == mealType,
        orElse: () =>
            defaultReminders.firstWhere((r) => r.mealType == mealType),
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ReminderApiClient _api;
  final ReminderLocalService _local;

  ReminderNotifier(this._api, this._local) : super(const ReminderState()) {
    _load();
  }

  /// Load reminders from API. Falls back to defaults on error.
  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reminders = await _api.getAll();

      // Merge: keep full default list but overlay saved values
      final merged = _mergeWithDefaults(reminders);
      state = state.copyWith(reminders: merged, isLoading: false);

      // Re-schedule all enabled reminders on app launch
      for (final r in merged.where((r) => r.enabled)) {
        await _local.scheduleReminder(r);
      }
    } catch (e) {
      debugPrint('⏰ Reminders: Load failed — $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      // Keep defaults on error — no crash
    }
  }

  /// Refresh reminders from API.
  Future<void> refresh() => _load();

  /// Save (create/update) a reminder — optimistic UI update.
  Future<void> saveReminder(ReminderModel reminder) async {
    final prev = List<ReminderModel>.from(state.reminders);
    _replaceInState(reminder);

    try {
      final saved = await _api.upsert(reminder);
      _replaceInState(saved);
      await _local.scheduleReminder(saved);
    } catch (e) {
      debugPrint('⏰ Reminders: Save failed — $e');
      state = state.copyWith(reminders: prev, error: e.toString());
    }
  }

  /// Toggle a reminder's enabled state — optimistic UI update.
  /// Always uses upsert so it works for both new (default) and existing reminders.
  Future<void> toggleEnabled(String mealType) async {
    final existing = state.forMealType(mealType);
    final prev = List<ReminderModel>.from(state.reminders);
    final toggled = existing.copyWith(enabled: !existing.enabled);
    _replaceInState(toggled);

    try {
      // Always upsert — handles both "first save" and "update" cases
      final saved = await _api.upsert(toggled);
      _replaceInState(saved);
      await _local.scheduleReminder(saved);
      debugPrint('⏰ Reminders: $mealType → enabled=${saved.enabled}, scheduled=${saved.enabled && !kIsWeb}');
    } catch (e) {
      debugPrint('⏰ Reminders: Toggle failed — $e');
      state = state.copyWith(reminders: prev, error: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _replaceInState(ReminderModel updated) {
    final list = state.reminders.map((r) {
      return r.mealType == updated.mealType ? updated : r;
    }).toList();
    state = state.copyWith(reminders: list, error: null);
  }

  /// Merge API results with the canonical order of defaultReminders.
  List<ReminderModel> _mergeWithDefaults(List<ReminderModel> fromApi) {
    return defaultReminders.map((def) {
      return fromApi.firstWhere(
        (r) => r.mealType == def.mealType,
        orElse: () => def,
      );
    }).toList();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  final api = ref.watch(reminderApiClientProvider);
  final local = ref.watch(reminderLocalServiceProvider);
  return ReminderNotifier(api, local);
});
