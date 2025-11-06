import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;

  factory SocketService() => _instance;

  SocketService._internal();

  void connect() {
    socket = IO.io(
      'http://10.0.2.2:4000', // <-- backend adresi (Android Emulator)
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket bağlandı: ${socket.id}');
    });

    socket.onDisconnect((_) {
      print('❌ Socket bağlantısı koptu');
    });
  }

  void joinRoom(String conversationId) {
    socket.emit('joinRoom', conversationId);
  }

  void sendMessage(Map<String, dynamic> data) {
    socket.emit('sendMessage', data);
  }

  void onMessage(void Function(dynamic) callback) {
    socket.on('receiveMessage', callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}
