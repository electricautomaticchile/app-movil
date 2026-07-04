# Configuración de Firebase Cloud Messaging (FCM)

Este documento describe **lo único que falta** para activar las notificaciones push
en la app móvil de ElectricAutomaticChile. Todo el código Dart, la configuración de
Gradle (Android) y las notas de iOS ya están implementados en el repositorio.

> Resumen de lo pendiente para el fundador:
> 1. Crear el proyecto en Firebase.
> 2. Descargar y colocar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS).
> 3. Obtener los SHA-1 / SHA-256 y registrarlos en Firebase (Android).
> 4. (iOS) Configurar la APNs Auth Key y las capabilities en Xcode.
> 5. Exponer el endpoint de backend para registrar tokens y configurar el envío de push.

---

## 1. Crear el proyecto Firebase

1. Ir a https://console.firebase.google.com/ e **crear un proyecto** (por ejemplo,
   `electricautomaticchile`).
2. Dentro del proyecto, agregar **dos apps**:

### App Android
- Icono Android → **Package name**: `com.electricautomaticchile.app`
  (debe coincidir con `applicationId` en `android/app/build.gradle.kts`).
- **App nickname**: `EAC Android` (opcional).
- **SHA-1 / SHA-256**: pegar los fingerprints obtenidos en el paso 3.
- Descargar **`google-services.json`**.

### App iOS
- Icono Apple → **Bundle ID**: el mismo que uses en Xcode
  (`PRODUCT_BUNDLE_IDENTIFIER`, p. ej. `com.electricautomaticchile.app`).
- Descargar **`GoogleService-Info.plist`**.

---

## 2. Dónde colocar los archivos descargados

| Archivo | Ubicación exacta en el repo |
|---|---|
| `google-services.json` | `android/app/google-services.json` |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` (agrégalo **desde Xcode**, arrastrándolo al grupo `Runner`, para que quede referenciado en el target) |

> Ambos archivos están (o deberían estar) en `.gitignore` por ser específicos del
> proyecto Firebase. **No los subas a git si contienen datos sensibles del proyecto.**

Una vez colocado `google-services.json`, el build de Android funcionará. Sin él, el
plugin `com.google.gms.google-services` **hará fallar el build a propósito** (esto es
esperado y está documentado con comentarios en `android/app/build.gradle.kts`).

---

## 3. Obtener los SHA-1 / SHA-256 (Android)

Necesarios para que FCM (y cualquier servicio de Google) valide la firma de la app.

```bash
cd android && ./gradlew signingReport
```

Copia los valores `SHA1` y `SHA-256` de la variante que uses:

- **debug**: para pruebas locales (keystore de debug autogenerado).
- **release**: usa tu keystore de release (configurado vía `android/key.properties`
  o variables de entorno `ANDROID_KEYSTORE_FILE`, etc.).

Pega esos fingerprints en:
Firebase Console → Project Settings → Tus apps → App Android → **Add fingerprint**.

> Si más adelante subes la app a Google Play con **Play App Signing**, agrega también
> el SHA-1/SHA-256 que Google Play te muestre en *App integrity*.

Después de agregar fingerprints, **descarga nuevamente `google-services.json`** (puede
cambiar) y reemplázalo en `android/app/`.

---

## 4. Configuración iOS (requiere cuenta Apple Developer de pago)

1. Abrir `ios/Runner.xcworkspace` en Xcode.
2. Arrastrar `GoogleService-Info.plist` al grupo **Runner** (marcar "Copy items if needed").
3. En **Runner → Signing & Capabilities** agregar:
   - **Push Notifications**.
   - **Background Modes** → marcar **Remote notifications**.
   (Esto ya está reflejado en `ios/Runner/Info.plist` con `UIBackgroundModes`.)
4. En el **Apple Developer Portal**:
   - Crear una **APNs Authentication Key** (`.p8`), anota el *Key ID* y el *Team ID*.
5. En **Firebase Console → Project Settings → Cloud Messaging → Apple app configuration**:
   - Subir la APNs Auth Key `.p8` con su *Key ID* y *Team ID*.

Sin estos pasos, iOS no entregará las notificaciones aunque el código esté correcto.

---

## 5. Backend: registro de tokens y envío de push

### 5.1 Endpoint que la app llama para registrar el token

La app hace un `POST` autenticado (con el JWT en `Authorization: Bearer <token>`)
cada vez que arranca (con sesión activa), tras iniciar sesión y cuando el token FCM
se refresca:

```
POST /api/notificaciones/fcm-token
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "token": "<fcm_device_token>",
  "plataforma": "android"   // o "ios"
}
```

El backend debe:
- Identificar al usuario a partir del JWT.
- Guardar/actualizar el `token` asociado a ese usuario (idempotente: si el token ya
  existe, actualizar `updatedAt`/plataforma; evitar duplicados).
- Idealmente permitir varios tokens por usuario (multi-dispositivo) y limpiar tokens
  inválidos cuando el envío falle (`messaging/registration-token-not-registered`).

> El path exacto (`/notificaciones/fcm-token`) es un **placeholder acordado**. Si el
> backend usa otra ruta, cámbiala en `lib/services/push_notification_service.dart`
> (método `_sendTokenToBackend`).

### 5.2 Envío de push desde el servidor (Firebase Admin SDK)

1. Firebase Console → Project Settings → **Service accounts** → **Generate new private key**.
   Descarga el JSON de la service account (**secreto**, NO commitear).
2. En el backend, cargar esas credenciales de forma segura, por ejemplo con una
   variable de entorno:
   - `FIREBASE_SERVICE_ACCOUNT` = contenido JSON de la service account (o ruta al archivo).
   - Alternativamente `GOOGLE_APPLICATION_CREDENTIALS` = ruta al archivo `.json`.
3. Enviar mensajes con el Admin SDK usando el/los token(s) guardados. El bloque
   `notification` (title/body) es lo que la app muestra automáticamente; puedes añadir
   `data` (p. ej. `{ "route": "notifications" }`) para navegación en la app.

---

## 6. Verificación rápida

1. Colocar `google-services.json` en `android/app/`.
2. `flutter pub get`
3. `flutter run` en un dispositivo/emulador Android.
4. En la consola de logs, buscar la línea `[FCM] token: ...` (en modo debug).
5. Firebase Console → **Messaging** → **Send test message**, pegar el token y enviar.
   - App en foreground → aparece vía `flutter_local_notifications`.
   - App en background → la muestra el sistema; al tocarla, abre la pantalla de
     notificaciones.

---

## 7. Qué ya quedó implementado en el código

- **`pubspec.yaml`**: dependencias `firebase_core`, `firebase_messaging`,
  `flutter_local_notifications`.
- **`lib/services/push_notification_service.dart`**: inicialización de Firebase,
  permisos, obtención/refresh de token, registro en backend, manejo de mensajes en
  foreground / al abrir la app / background (handler top-level).
- **`lib/main.dart`**: inicializa el servicio en el arranque y navega a la pantalla de
  notificaciones al tocar una push.
- **Android**: plugin `com.google.gms.google-services` declarado (settings) y aplicado
  (app), `minSdk >= 21`, permiso `POST_NOTIFICATIONS` y canal por defecto en el manifest.
- **iOS**: `UIBackgroundModes` (remote-notification) en `Info.plist` y notas en
  `AppDelegate.swift`.
