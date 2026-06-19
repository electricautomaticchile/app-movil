import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef WsMessageCallback = void Function(Map<String, dynamic> data);

class WebSocketService {
  // A-01: URL configurable via const (usar --dart-define en build)
  static const String _wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'wss://electric-backend-tpg9.onrender.com/api/ws/connect',
  );
  static const _storage = FlutterSecureStorage();

  WebSocket? _socket;
  StreamSubscription? _sub;
  bool _disposed = false;
  int _reconnectAttempts = 0; // M-04: Backoff exponencial

  WsMessageCallback? onDeviceUpdate;
  VoidCallback? onConnected;
  VoidCallback? onDisconnected;

  Future<void> connect() async {
    if (_disposed) return;
    try {
      final token = await _storage.read(key: 'access_token');
      // C-02: Enviar token como header en vez de query parameter
      _socket = await WebSocket.connect(
        _wsUrl,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
      _reconnectAttempts = 0; // Reset en conexión exitosa
      onConnected?.call();

      _sub = _socket!.listen(
        (raw) {
          try {
            final msg = jsonDecode(raw as String) as Map<String, dynamic>;
            if (msg['type'] == 'device_update' && msg['data'] != null) {
              onDeviceUpdate?.call(msg['data'] as Map<String, dynamic>);
            }
          } catch (_) {}
        },
        onDone: () {
          onDisconnected?.call();
          if (!_disposed) _reconnect();
        },
        onError: (_) {
          onDisconnected?.call();
          if (!_disposed) _reconnect();
        },
        cancelOnError: true,
      );
    } catch (_) {
      onDisconnected?.call();
      if (!_disposed) _reconnect();
    }
  }

  // M-04: Backoff exponencial con jitter
  void _reconnect() {
    final delay =
        min(30, pow(2, _reconnectAttempts).toInt()) + Random().nextInt(3);
    _reconnectAttempts++;
    Future.delayed(Duration(seconds: delay), () {
      if (!_disposed) connect();
    });
  }

  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _socket?.close();
  }
}
