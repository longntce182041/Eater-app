import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat_api_client.dart';
import '../../data/chat_models.dart';
import '../../data/chat_socket_service.dart';

class ChatState {
  final bool isLoading;
  final List<ChatMessage> messages;
  final String? error;

  const ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
  });

  ChatState copyWith({
    bool? isLoading,
    List<ChatMessage>? messages,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatApiClient _api;
  final ChatSocketService _socket;
  final String _nutritionistId;
  StreamSubscription<ChatMessage>? _subscription;

  ChatNotifier(this._api, this._socket, this._nutritionistId)
      : super(const ChatState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final history = await _api.getHistory(_nutritionistId);
      if (!mounted) return;
      state = state.copyWith(isLoading: false, messages: history);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }

    if (!mounted) return;
    // Join the socket room
    _socket.joinRoom(_nutritionistId);

    // Listen for incoming messages
    _subscription = _socket.messages.listen((msg) {
      if (!mounted) return;
      // Avoid duplicate if server echoes our own message
      final alreadyExists = state.messages.any((m) => m.id == msg.id);
      if (!alreadyExists) {
        state = state.copyWith(messages: [...state.messages, msg]);
      }
    });
  }

  void send(String content) {
    if (content.trim().isEmpty) return;
    _socket.sendMessage(content.trim());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _socket.leaveRoom();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, String>((ref, nutritionistId) {
  return ChatNotifier(
    ref.watch(chatApiClientProvider),
    ref.watch(chatSocketServiceProvider),
    nutritionistId,
  );
});

/// List of verified nutritionists for the user to browse and start a chat.
final nutritionistsProvider = FutureProvider<List<NutritionistInfo>>((ref) {
  return ref.watch(chatApiClientProvider).getNutritionists();
});
