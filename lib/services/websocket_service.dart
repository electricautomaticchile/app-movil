import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef WsMessageCallback = void Function(Map<String, dynamic> data);

class WebSocketService {
  static const String _wsUrl =
      'wss://api-electricautomaticchile.com/api/ws/connect';
  static const _storage = FlutterSecureStorage();

  WebSocket? _socket;
  StreamSubscription? _sub;
  bool _disposed = false;

  WsMessageCallback? onDeviceUpdate;
  VoidCallback? onConnected;
  VoidCallback? onDisconnected;

  Future<void> connect() async {
    if (_disposed) return;
    try {
      final token = await _storage.read(key: 'access_token');
      final uri = Uri.parse(token != null ? '$_wsUrl?token=$token' : _wsUrl);
      _socket = await WebSocket.connect(uri.toString());
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

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_disposed) connect();
    });
  }

  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _socket?.close();
  }
}
