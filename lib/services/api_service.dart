import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // A-01: URL configurable via --dart-define (no hardcodeada)
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api-electricautomaticchile.com/api',
  );
  static const _storage = FlutterSecureStorage();

  // C-01: SHA-256 fingerprints del certificado del servidor
  // Actualizar cuando se renueve el certificado
  static const List<String> _pinnedCertFingerprints = [
    // Obtener con: openssl s_client -connect api-electricautomaticchile.com:443 | openssl x509 -fingerprint -sha256
    'PLACEHOLDER_CERT_FINGERPRINT_SHA256',
  ];

  // Callback para redirigir al login cuando el token expira
  static VoidCallback? onUnauthorized;

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // C-01: Certificate pinning (solo en release, no en debug)
    if (!kDebugMode) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              final certBytes = cert.der;
              final fingerprint = sha256
                  .convert(certBytes)
                  .toString()
                  .toUpperCase();
              return _pinnedCertFingerprints.contains(fingerprint);
            };
        return client;
      };
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Intentar refresh antes de redirigir
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Reintentar la request original con el nuevo token
              final token = await _storage.read(key: 'access_token');
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(opts);
                handler.resolve(response);
                return;
              } catch (_) {}
            }
            // Refresh falló — limpiar tokens y notificar
            await clearTokens();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  static Dio get dio => _dio;

  static Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;
      final response = await Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
        ),
      ).post('/auth/refresh-token', data: {'refreshToken': refreshToken});
      final data = response.data['data'];
      await saveTokens(data['token'], data['refreshToken'] ?? refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveTokens(String token, String refreshToken) async {
    await Future.wait([
      _storage.write(key: 'access_token', value: token),
      _storage.write(key: 'refresh_token', value: refreshToken),
    ]);
  }

  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: 'access_token'),
      _storage.delete(key: 'refresh_token'),
    ]);
  }

  static Future<String?> getToken() => _storage.read(key: 'access_token');
}
