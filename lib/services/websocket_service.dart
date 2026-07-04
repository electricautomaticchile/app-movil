// path: lib/services/websocket_service.dart
//
// Cliente WebSocket del servicio independiente `websocket-electric`.
//
// El Hub vive en un servicio aparte (no en el backend REST) y entrega los
// eventos en tiempo real (alertas, notificaciones, actualizaciones de
// dispositivo con GPS, consumo). La API publica en Redis Pub/Sub y el Hub
// reenvía a los clientes conectados.
//
// Puntos clave del contrato (ver websocket-electric/handler.go y message.go):
//   * Endpoint de conexión: /ws/connect
//   * Autenticación por JWT: header `Authorization: Bearer <token>` (nativo),
//     cookie `auth_token` (web) o `?token=` (fallback). Aquí usamos el header.
//   * El WritePump del Hub agrupa varios mensajes en un mismo frame separados
//     por '\n' (optimización). HAY QUE dividir por '\n' y parsear cada línea;
//     de lo contrario un jsonDecode del frame completo falla y se pierden lotes
//     de mensajes bajo alta frecuencia. (Mismo fix que en el frontend web.)
//   * Mensajes: { type, data, timestamp, empresaId?, clienteId? }
//     type ∈ alert | notification | device_update | consumption | ping | pong

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Callback con el `data` de un mensaje ya parseado.
typedef WsMessageCallback = void Function(Map<String, dynamic> data);

/// Callback con el mensaje completo (type + data + metadatos).
typedef WsRawMessageCallback = void Function(Map<String, dynamic> message);

class WebSocketService {
  // A-01: URL configurable via --dart-define=WS_URL (no hardcodeada al backend).
  // Por defecto apunta al servicio WebSocket independiente en Render.
  static const String _wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'wss://websocket-electric.onrender.com/ws/connect',
  );
  static const _storage = FlutterSecureStorage();

  WebSocket? _socket;
  StreamSubscription? _sub;
  Timer? _pingTimer;
  bool _disposed = false;
  int _reconnectAttempts = 0; // M-04: Backoff exponencial

  /// Latencia medida con el último ciclo ping/pong (ms). Null si no hay dato.
  int? latenciaMs;
  DateTime? _pingSentAt;

  /// Actualización de dispositivo (incluye GPS lat/lng para el mapa).
  WsMessageCallback? onDeviceUpdate;

  /// Cualquier mensaje entrante (alert, notification, consumption, etc.).
  WsRawMessageCallback? onMessage;

  VoidCallback? onConnected;
  VoidCallback? onDisconnected;

  bool get isConnected => _socket != null;

  Future<void> connect() async {
    if (_disposed) return;
    try {
      final token = await _storage.read(key: 'access_token');
      // C-02: token en header Authorization (no en query param).
      _socket = await WebSocket.connect(
        _wsUrl,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      // Keep-alive a nivel de protocolo: mantiene viva la conexión y ayuda a
      // detectar cortes de red (Render cierra conexiones ociosas).
      _socket!.pingInterval = const Duration(seconds: 25);

      _reconnectAttempts = 0; // Reset en conexión exitosa
      onConnected?.call();
      _startAppPing();

      _sub = _socket!.listen(
        _handleFrame,
        onDone: () {
          _stopAppPing();
          onDisconnected?.call();
          if (!_disposed) _reconnect();
        },
        onError: (_) {
          _stopAppPing();
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

  /// Procesa un frame que puede contener varios mensajes separados por '\n'.
  void _handleFrame(dynamic raw) {
    if (raw is! String) return;
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final msg = jsonDecode(trimmed) as Map<String, dynamic>;
        _dispatch(msg);
      } catch (_) {
        // Línea no-JSON: se ignora.
      }
    }
  }

  void _dispatch(Map<String, dynamic> msg) {
    final type = msg['type'];

    if (type == 'pong') {
      if (_pingSentAt != null) {
        latenciaMs = DateTime.now().difference(_pingSentAt!).inMilliseconds;
        _pingSentAt = null;
      }
      return;
    }

    if (type == 'device_update' && msg['data'] is Map) {
      onDeviceUpdate?.call(Map<String, dynamic>.from(msg['data'] as Map));
    }

    onMessage?.call(msg);
  }

  /// Ping a nivel de aplicación cada 10s para medir latencia (igual que el web).
  void _startAppPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final socket = _socket;
      if (socket == null) return;
      try {
        _pingSentAt = DateTime.now();
        socket.add(jsonEncode({'type': 'ping'}));
      } catch (_) {}
    });
  }

  void _stopAppPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  // M-04: Backoff exponencial con jitter (máx 30s).
  void _reconnect() {
    _socket = null;
    final delay =
        min(30, pow(2, _reconnectAttempts).toInt()) + Random().nextInt(3);
    _reconnectAttempts++;
    if (kDebugMode) {
      debugPrint('[WS] Reconectando en ${delay}s (intento $_reconnectAttempts)');
    }
    Future.delayed(Duration(seconds: delay), () {
      if (!_disposed) connect();
    });
  }

  void dispose() {
    _disposed = true;
    _stopAppPing();
    _sub?.cancel();
    _socket?.close();
    _socket = null;
  }
}
