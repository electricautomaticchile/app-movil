// path: lib/services/push_notification_service.dart
//
// Servicio de notificaciones push con Firebase Cloud Messaging (FCM).
//
// Responsabilidades:
//   * Inicializar Firebase (Firebase.initializeApp).
//   * Pedir permisos de notificación (Android 13+ / iOS).
//   * Obtener y refrescar el token FCM del dispositivo.
//   * Registrar el token en el backend (POST /notificaciones/fcm-token).
//   * Manejar mensajes en foreground (mostrándolos con
//     flutter_local_notifications), al abrir la app (onMessageOpenedApp) y en
//     background/terminated (handler top-level firebaseMessagingBackgroundHandler).
//
// NOTA para el fundador:
//   El código está completo, pero NO funcionará hasta que agregues los archivos
//   de configuración de Firebase. Ver FIREBASE_SETUP.md.
//     - Android: android/app/google-services.json
//     - iOS:     ios/Runner/GoogleService-Info.plist

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_service.dart';

/// Handler de mensajes recibidos con la app en background o terminada.
///
/// DEBE ser una función top-level (o estática) anotada con
/// `@pragma('vm:entry-point')` porque se ejecuta en un isolate separado.
/// No dependas aquí de estado de la UI: solo trabajo ligero.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase debe inicializarse en este isolate independiente.
  await Firebase.initializeApp();
  // Las notificaciones con bloque `notification` las muestra el sistema
  // automáticamente en background; aquí solo dejamos traza para depuración.
  if (kDebugMode) {
    debugPrint('[FCM][background] ${message.messageId} -> ${message.data}');
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Canal por defecto para Android (obligatorio en Android 8+).
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'eac_default_channel',
    'Notificaciones ElectricAutomaticChile',
    description: 'Alertas, facturación y avisos del servicio eléctrico.',
    importance: Importance.high,
  );

  /// Callback opcional para navegar al abrir una notificación.
  /// Se invoca con el `data` del mensaje. Configúralo desde main.dart si
  /// quieres redirigir (por ejemplo, a la pantalla de notificaciones).
  void Function(Map<String, dynamic> data)? onNotificationTap;

  /// Punto de entrada único. Llamar una sola vez durante el arranque.
  ///
  /// Es seguro invocarlo aunque falten los archivos de Firebase: se captura la
  /// excepción y se deja registrado, sin romper el arranque de la app.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (e) {
      // Sin google-services.json / GoogleService-Info.plist esto fallará.
      // No propagamos el error para no bloquear el arranque de la app.
      if (kDebugMode) {
        debugPrint(
          '[FCM] Firebase.initializeApp() falló. '
          '¿Agregaste google-services.json / GoogleService-Info.plist? -> $e',
        );
      }
      return;
    }

    // Handler de background/terminated (debe registrarse temprano).
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initLocalNotifications();
    await requestPermissions();
    await _configureForegroundPresentation();
    _wireMessageHandlers();

    // Registro inicial del token + suscripción a refrescos.
    await registerTokenWithBackend();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) {
      _sendTokenToBackend(token);
    });
  }

  /// Inicializa flutter_local_notifications y crea el canal Android.
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      // Los permisos se piden explícitamente en requestPermissions().
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          onNotificationTap?.call({'route': payload});
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);
  }

  /// Solicita permisos de notificación (iOS y Android 13+).
  Future<NotificationSettings> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      debugPrint('[FCM] Permisos: ${settings.authorizationStatus}');
    }
    return settings;
  }

  /// En iOS, permite mostrar la notificación mientras la app está en foreground.
  Future<void> _configureForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Registra los listeners de mensajes en foreground y de apertura.
  void _wireMessageHandlers() {
    // App en primer plano: mostramos la notificación manualmente.
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // App en background y el usuario toca la notificación.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationTap?.call(message.data);
    });

    // App terminada y abierta desde una notificación.
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        onNotificationTap?.call(message.data);
      }
    });
  }

  /// Muestra una notificación local a partir de un RemoteMessage (foreground).
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'] as String?,
    );
  }

  /// Obtiene el token FCM actual y lo registra en el backend.
  Future<String?> registerTokenWithBackend() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return null;
      if (kDebugMode) debugPrint('[FCM] token: $token');
      await _sendTokenToBackend(token);
      return token;
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] No se pudo obtener el token: $e');
      return null;
    }
  }

  /// POST del token FCM al backend.
  ///
  /// >>> ENDPOINT REQUERIDO EN EL BACKEND <<<
  ///   POST /api/notificaciones/fcm-token
  ///   Headers: `Authorization: Bearer <JWT>`  (lo agrega ApiService)
  ///   Body JSON: `{ "token": "<fcm_token>", "plataforma": "android" | "ios" }`
  ///
  /// El backend debe asociar el token al usuario autenticado (por el JWT) y
  /// usarlo luego con el Firebase Admin SDK para enviar push. Ver FIREBASE_SETUP.md.
  Future<void> _sendTokenToBackend(String token) async {
    // Solo tiene sentido registrar si hay sesión iniciada.
    final jwt = await ApiService.getToken();
    if (jwt == null) {
      if (kDebugMode) {
        debugPrint('[FCM] Sin sesión activa; se pospone el registro del token.');
      }
      return;
    }

    try {
      await ApiService.dio.post(
        '/notificaciones/fcm-token',
        data: {
          'token': token,
          'plataforma': defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
        },
      );
      if (kDebugMode) debugPrint('[FCM] Token registrado en el backend.');
    } catch (e) {
      // Si el endpoint aún no existe (404) o el usuario no está logueado,
      // no rompemos la app: el token se reintentará en el próximo arranque
      // o cuando cambie (onTokenRefresh).
      if (kDebugMode) debugPrint('[FCM] Error al registrar el token: $e');
    }
  }

  /// Llamar tras un login exitoso para asegurar que el token quede asociado
  /// al usuario recién autenticado.
  Future<void> onUserLoggedIn() => registerTokenWithBackend();

  /// Elimina el token del dispositivo (por ejemplo, al cerrar sesión) para
  /// dejar de recibir push dirigidos a este usuario.
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Error al eliminar el token: $e');
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
  }
}
