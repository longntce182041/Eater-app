import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../data/grocery_local_storage.dart';
import '../../data/grocery_api.dart';
import '../../domain/grocery_models.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/providers/app_config_provider.dart'
    as config_provider;
import '../../../../shared/providers/dio_provider.dart' as dio_provider;

/// State for grocery list
class GroceryListState {
  final List<GroceryItem> items;
  final bool isLoading;
  final String? errorMessage;

  GroceryListState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GroceryListState copyWith({
    List<GroceryItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GroceryListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Get statistics
  GroceryStats get stats {
    final purchased = items.where((item) => item.isPurchased).length;
    return GroceryStats(
      totalItems: items.length,
      purchasedItems: purchased,
      pendingItems: items.length - purchased,
    );
  }

  /// Get items grouped by purchase status
  List<GroceryItem> get pendingItems =>
      items.where((item) => !item.isPurchased).toList();

  List<GroceryItem> get purchasedItems =>
      items.where((item) => item.isPurchased).toList();
}

/// Notifier for managing grocery list with API sync
class GroceryListNotifier extends StateNotifier<GroceryListState> {
  final GroceryLocalStorage _storage;
  final GroceryApi _api;
  final String _userId;

  GroceryListNotifier(this._storage, this._api, this._userId)
      : super(GroceryListState()) {
    _loadItems();
  }

  /// Load items from API with local fallback
  Future<void> _loadItems() async {
    // Skip loading for guest/unknown users
    if (_userId == 'guest' || _userId == 'unknown') {
      debugPrint('🛒 GroceryList: Skipping load for guest user');
      state = GroceryListState(items: [], isLoading: false);
      return;
    }

    debugPrint('🛒 GroceryList: Loading items for userId: $_userId');
    state = state.copyWith(isLoading: true);
    try {
      // Try to load from API first (remote source of truth)
      final items = await _api.getGroceryList();
      debugPrint('🛒 GroceryList: Loaded ${items.length} items from API');

      // Cache in local storage
      await _storage.saveItems(_userId, items);
      state = GroceryListState(items: items, isLoading: false);
    } catch (e) {
      debugPrint('🛒 GroceryList: API load failed: $e');
      // Fallback to local storage if API fails
      try {
        final items = await _storage.loadItems(_userId);
        debugPrint('🛒 GroceryList: Loaded ${items.length} items from cache');
        state = GroceryListState(
          items: items,
          isLoading: false,
          errorMessage: 'Offline mode - using cached data',
        );
      } catch (localError) {
        debugPrint('🛒 GroceryList: Cache load failed: $localError');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load grocery items',
        );
      }
    }
  }

  /// Add a single item to grocery list
  Future<void> addItem(GroceryItem item) async {
    try {
      debugPrint('🛒 GroceryList: Adding single item');
      // Sync with API first
      try {
        await _api.addGroceryItems([item]);
        debugPrint('🛒 GroceryList: API add successful');

        // Reload list from server to get accurate state with real IDs
        await _loadItems();
      } catch (apiError) {
        debugPrint('🛒 GroceryList: API add failed: $apiError');
        if (apiError is GroceryApiException && apiError.statusCode == 409) {
          state = state.copyWith(errorMessage: apiError.message);
          return;
        }
        // API failed, add to local state as fallback
        // Check if item already exists (by ingredient ID)
        final existingIndex = state.items.indexWhere(
          (i) => i.ingredientId == item.ingredientId,
        );

        List<GroceryItem> updatedItems;

        if (existingIndex != -1) {
          // Item exists, combine quantities
          final existing = state.items[existingIndex];
          final updatedItem = existing.copyWith(
            quantity: existing.quantity + item.quantity,
          );
          updatedItems = List.from(state.items);
          updatedItems[existingIndex] = updatedItem;
        } else {
          // New item, add to list
          updatedItems = [...state.items, item];
        }

        // Update UI
        state = state.copyWith(
          items: updatedItems,
          errorMessage: 'Item added locally, sync failed',
        );

        // Cache in local storage
        await _storage.saveItems(_userId, updatedItems);
      }
    } catch (e) {
      debugPrint('🛒 GroceryList: Add item error: $e');
      state = state.copyWith(errorMessage: 'Failed to add item: $e');
    }
  }

  /// Add multiple items (from recipe)
  Future<void> addItems(List<GroceryItem> newItems) async {
    try {
      debugPrint('🛒 GroceryList: Adding ${newItems.length} items');

      // Sync with API first to get real IDs from database
      try {
        await _api.addGroceryItems(newItems);
        debugPrint('🛒 GroceryList: API add successful');

        // Reload entire list from server to get accurate state
        await _loadItems();
        debugPrint(
          '🛒 GroceryList: List reloaded, now have ${state.items.length} total items',
        );
      } catch (apiError) {
        debugPrint('🛒 GroceryList: API add failed: $apiError');
        if (apiError is GroceryApiException && apiError.statusCode == 409) {
          state = state.copyWith(errorMessage: apiError.message);
          return;
        }
        // If API fails, still add to local state as fallback
        final updatedItems = List<GroceryItem>.from(state.items);

        for (final newItem in newItems) {
          final existingIndex = updatedItems.indexWhere(
            (i) => i.ingredientId == newItem.ingredientId,
          );

          if (existingIndex != -1) {
            // Combine quantities
            final existing = updatedItems[existingIndex];
            updatedItems[existingIndex] = existing.copyWith(
              quantity: existing.quantity + newItem.quantity,
            );
          } else {
            // Add new item
            updatedItems.add(newItem);
          }
        }

        // Update UI with local copy
        state = state.copyWith(
          items: updatedItems,
          errorMessage: '${newItems.length} items added locally, sync failed',
        );

        // Cache in local storage
        await _storage.saveItems(_userId, updatedItems);
      }
    } catch (e) {
      debugPrint('🛒 GroceryList: Add items error: $e');
      state = state.copyWith(errorMessage: 'Failed to add items: $e');
    }
  }

  /// Toggle purchased status of an item
  Future<void> togglePurchased(String itemId) async {
    try {
      final updatedItems = state.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isPurchased: !item.isPurchased);
        }
        return item;
      }).toList();

      // Update UI immediately (optimistic update)
      state = state.copyWith(items: updatedItems);

      // Sync with API
      try {
        await _api.toggleItemStatus(itemId);
        // Cache in local storage
        await _storage.saveItems(_userId, updatedItems);
      } catch (apiError) {
        // If API fails, revert to previous state
        state = state.copyWith(errorMessage: 'Failed to sync purchase status');
        await _loadItems(); // Reload from API to get correct state
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update item: $e');
    }
  }

  /// Remove an item
  Future<void> removeItem(String itemId) async {
    try {
      final updatedItems =
          state.items.where((item) => item.id != itemId).toList();

      // Update UI immediately
      state = state.copyWith(items: updatedItems);

      // Sync with API
      try {
        await _api.removeGroceryItem(itemId);
        // Cache in local storage
        await _storage.saveItems(_userId, updatedItems);
      } catch (apiError) {
        // If API fails, reload from API to get correct state
        state = state.copyWith(errorMessage: 'Failed to remove item');
        await _loadItems();
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to remove item: $e');
    }
  }

  /// Clear all purchased items
  Future<void> clearPurchased() async {
    try {
      final updatedItems =
          state.items.where((item) => !item.isPurchased).toList();

      // Update UI immediately
      state = state.copyWith(items: updatedItems);

      // Sync with API
      try {
        await _api.clearPurchasedItems();
        // Cache in local storage
        await _storage.saveItems(_userId, updatedItems);
      } catch (apiError) {
        // If API fails, reload from API
        state = state.copyWith(errorMessage: 'Failed to clear items');
        await _loadItems();
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to clear items: $e');
    }
  }

  /// Clear all items
  Future<void> clearAll() async {
    final itemsToDelete = List<GroceryItem>.from(state.items);
    try {
      // Update UI immediately
      state = GroceryListState();

      // Delete every item on the server individually (no delete-all endpoint)
      try {
        await Future.wait(
          itemsToDelete.map((item) => _api.removeGroceryItem(item.id)),
        );
        await _storage.clearAll(_userId);
      } catch (apiError) {
        // If API fails, reload to restore correct server state
        await _loadItems();
        state = state.copyWith(
          errorMessage: 'Failed to clear items on server',
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to clear all items: $e');
    }
  }

  /// Refresh/reload items from API
  Future<void> refresh() async {
    await _loadItems();
  }
}

/// Provider for grocery local storage
final groceryLocalStorageProvider = Provider<GroceryLocalStorage>((ref) {
  return GroceryLocalStorage();
});

/// Provider for grocery API
final groceryApiProvider = Provider<GroceryApi>((ref) {
  final dio = ref.watch(dio_provider.dioProvider);
  final config = ref.watch(config_provider.appConfigProvider);
  return GroceryApi(dio, config.apiBaseUrl);
});

/// Provider for grocery list state with API sync
/// Uses autoDispose to ensure cleanup when user logs out
/// This provider will automatically recreate when auth state changes
final groceryListProvider =
    StateNotifierProvider.autoDispose<GroceryListNotifier, GroceryListState>((
  ref,
) {
  final storage = ref.watch(groceryLocalStorageProvider);
  final api = ref.watch(groceryApiProvider);

  // Get userId from auth controller state
  // This will trigger provider recreation when auth state changes
  final auth = ref.watch(authControllerProvider);

  // Debug: Print auth state
  debugPrint('🛒 GroceryListProvider: Auth state - user: ${auth.user}');
  debugPrint(
    '🛒 GroceryListProvider: User keys: ${auth.user?.keys.toList()}',
  );

  final userId = (auth.user?['id'] ?? auth.user?['_id'] ?? 'unknown') as String;

  debugPrint('🛒 GroceryListProvider: Extracted userId: $userId');

  // If no valid user, return empty notifier without API calls
  if (userId == 'unknown' || auth.user == null) {
    debugPrint('🛒 GroceryListProvider: No valid user, using guest mode');
    // Pass 'guest' as userId to prevent API calls
    return GroceryListNotifier(storage, api, 'guest');
  }

  debugPrint(
    '🛒 GroceryListProvider: Creating notifier for userId: $userId',
  );
  return GroceryListNotifier(storage, api, userId);
});
