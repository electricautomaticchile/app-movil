# ElectricAutomaticChile - App Movil

Aplicacion Flutter para ElectricAutomaticChile. El foco actual es el panel
empresa: autenticacion con email corporativo, dashboard operativo, gestion de
clientes, dispositivos, alertas, tickets, usuarios y configuracion. Mantiene
pantallas cliente heredadas para consumo, boletas y control remoto.

> Estado actual: la app apunta por defecto al backend productivo de Render
> `https://electric-backend-tpg9.onrender.com/api`. Los endpoints empresa ya se
> consumen desde el backend; algunas pantallas cliente siguen siendo legacy o
> dependen de endpoints especificos del usuario cliente.

## Funcionalidades

- Login empresa con email y contraseña.
- Restauracion de sesion con token y redireccion por rol.
- Dashboard empresa con metricas, busqueda, filtros y detalle de registros.
- Modo claro/oscuro/sistema con preferencia persistida.
- Dashboard cliente con consumo actual, promedio diario y comparacion mensual.
- Facturas por periodo, detalle y descarga de reportes.
- Pagos, metodos de pago e historial.
- Consumo historico con graficos.
- Configuracion de perfil, tema y notificaciones.
- Centro de notificaciones.
- Centro de ayuda y formulario de contacto.

## Tecnologias

- Flutter y Dart.
- Material 3.
- Provider para estado.
- `fl_chart` para graficos.
- `dio` para HTTP.
- `flutter_secure_storage` para tokens.
- `local_auth` para biometria.
- Android e iOS.

## Requisitos

- Flutter SDK compatible con Dart `^3.10.7`.
- Android SDK configurado.
- JDK 17 o superior para builds Android.

En esta maquina Flutter esta instalado en:

```bash
/home/pipeaalzamora/flutter/bin/flutter
```

## Desarrollo

```bash
flutter pub get
flutter run
```

Si el binario `flutter` no esta en `PATH`, usar:

```bash
/home/pipeaalzamora/flutter/bin/flutter pub get
/home/pipeaalzamora/flutter/bin/flutter run
```

## Tests y analisis

```bash
flutter analyze
flutter test
```

Tests existentes:

- `test/models/user_provider_test.dart`
- `test/theme/theme_provider_test.dart`
- `test/utils/client_number_formatter_test.dart`
- `test/utils/rut_formatter_test.dart`

## Build Android

Debug:

```bash
flutter build apk --debug
```

Tambien se puede usar Gradle directamente:

```bash
./gradlew assembleDebug
```

Release requiere firma. Configurar `android/key.properties` o estas variables:

```env
ANDROID_KEYSTORE_FILE=/ruta/al/keystore.jks
ANDROID_KEYSTORE_PASSWORD=
ANDROID_KEY_ALIAS=
ANDROID_KEY_PASSWORD=
```

Luego:

```bash
flutter build apk --release
```

## Pendiente antes de produccion

- Agregar pruebas de widgets para login, dashboard empresa, facturas y pagos.
- Definir si la app final sera solo empresa o multi-rol empresa/cliente.
- Completar acciones de escritura empresa cuando existan endpoints: crear
  cliente, asignar dispositivo, resolver alerta, actualizar ticket e invitar
  usuario.
- Validar almacenamiento seguro de tokens.
- Validar pinning/certificados contra dominios reales antes de activar
  `ENABLE_CERT_PINNING=true`.
- Configurar firma release y versionado.
