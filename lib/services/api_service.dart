import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl = 'https://api-electricautomaticchile.com/api';
  static const _storage = FlutterSecureStorage();

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await _storage.read(key: 'access_token');
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              handler.next(options);
            },
            onError: (error, handler) {
              handler.next(error);
            },
          ),
        );

  static Dio get dio => _dio;

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
