# ElectricAutomaticChile - App Movil

Aplicacion Flutter para clientes de ElectricAutomaticChile. Permite revisar
consumo, facturas, pagos, notificaciones, configuracion y ayuda desde Android e
iOS.

> Estado actual: la app usa datos simulados para validar experiencia y flujo de
> pantallas. La integracion completa con el backend debe documentarse y probarse
> cuando se conecten endpoints reales.

## Funcionalidades

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

- Reemplazar datos simulados por servicios reales del backend.
- Agregar pruebas de widgets para login, dashboard, facturas y pagos.
- Validar almacenamiento seguro de tokens.
- Validar pinning/certificados contra dominios reales.
- Configurar firma release y versionado.
