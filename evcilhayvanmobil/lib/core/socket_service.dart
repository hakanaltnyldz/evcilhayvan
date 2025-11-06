import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

import 'http.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;

  factory SocketService() => _instance;

  SocketService._internal();

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    _socket?.dispose();

    final backendUri = Uri.parse(apiBaseUrl);
    final authority = backendUri.hasPort
        ? '${backendUri.scheme}://${backendUri.host}:${backendUri.port}'
        : '${backendUri.scheme}://${backendUri.host}';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final builder = IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect();

    if (token != null && token.isNotEmpty) {
      builder.setExtraHeaders({'Authorization': 'Bearer $token'});
    }

    final socket = IO.io(
      authority,
      builder.build(),
    );

    _socket = socket;

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket bağlandı: ${socket.id}');
    });

    socket.onDisconnect((_) {
      print('❌ Socket bağlantısı koptu');
    });
  }

  void joinRoom(String conversationId) {
    final socket = _socket;
    if (socket == null) return;
    if (socket.connected) {
      socket.emit('joinRoom', conversationId);
    } else {
      socket.onConnect((_) => socket.emit('joinRoom', conversationId));
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    final socket = _socket;
    if (socket == null) return;
    socket.emit('sendMessage', data);
  }

  void onMessage(void Function(dynamic) callback) {
    final socket = _socket;
    if (socket == null) return;
    socket.on('receiveMessage', callback);
  }

  void disconnect() {
    final socket = _socket;
    if (socket == null) return;
    socket.disconnect();
    socket.dispose();
    _socket = null;
  }
}
