import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// Singleton WebSocket manager for admin dashboard real-time updates
class AdminWebSocket {
  static final AdminWebSocket _instance = AdminWebSocket._internal();
  factory AdminWebSocket() => _instance;
  AdminWebSocket._internal();

  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onEvent;

  void connect({required String url, Function(Map<String, dynamic>)? onEvent}) {
    if (_channel != null) return;
    _channel = WebSocketChannel.connect(Uri.parse(url));
    this.onEvent = onEvent;
    _channel!.stream.listen((event) {
      try {
        final data = event is String ? event : event.toString();
        final decoded = data.startsWith('{') ? data : null;
        if (decoded != null) {
          final map = Map<String, dynamic>.from(jsonDecode(data));
          this.onEvent?.call(map);
        }
      } catch (_) {}
    });
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }
}
