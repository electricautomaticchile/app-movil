import Flutter
import UIKit

// ============================================================================
// FCM / Push notifications (iOS)
//
// El plugin `firebase_messaging` usa "method swizzling" del AppDelegate para
// conectar automáticamente APNs con FCM, por lo que normalmente NO hace falta
// escribir código extra aquí.
//
// PENDIENTE DEL FUNDADOR (requiere cuenta Apple Developer de pago):
//   1. Colocar ios/Runner/GoogleService-Info.plist (descargado de Firebase).
//   2. En Xcode → Signing & Capabilities agregar:
//        - "Push Notifications"
//        - "Background Modes" → marcar "Remote notifications"
//   3. Subir la APNs Auth Key (.p8) a Firebase → Cloud Messaging.
//   Ver FIREBASE_SETUP.md.
//
// Registramos explícitamente para notificaciones remotas por robustez.
// Si desactivas el swizzling (FirebaseAppDelegateProxyEnabled = NO en Info.plist)
// deberás reenviar manualmente el deviceToken a Messaging aquí.
// ============================================================================

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Muestra alertas mientras la app está en foreground (iOS 10+).
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
