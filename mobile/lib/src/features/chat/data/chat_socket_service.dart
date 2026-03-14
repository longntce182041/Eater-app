import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/auth_token_provider.dart';
import 'chat_models.dart';

class ChatSocketService {
  IO.Socket? _socket;
  final String _serverUrl;
  final String? _token;

  final _messageController = StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get messages => _messageController.stream;

  ChatSocketService(this._serverUrl, this._token);

  void connect() {
    final token = _token;
    if (token == null) return;

    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      // Connected successfully
    });

    _socket!.on('receive_message', (data) {
      if (data is Map<String, dynamic>) {
        final msg = ChatMessage.fromJson(data);
        _messageController.add(msg);
      }
    });

    _socket!.onConnectError((err) {
      // Connection error — socket will retry automatically
    });

    _socket!.connect();
  }

  void joinRoom(String nutritionistId) {
    _socket?.emit('join_room', {'nutritionistId': nutritionistId});
  }

  void sendMessage(String content) {
    _socket?.emit('send_message', {'content': content});
  }

  void leaveRoom() {
    _socket?.emit('leave_room');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}

final chatSocketServiceProvider =
    Provider.autoDispose<ChatSocketService>((ref) {
  final token = ref.watch(authTokenProvider).accessToken;
  final baseUrl = ref.watch(appConfigProvider).apiBaseUrl;

  final service = ChatSocketService(baseUrl, token);
  service.connect();

  ref.onDispose(service.dispose);
  return service;
});
