import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel user;
  final bool requiereCambioPassword;
  final Map<String, dynamic>? permisos;

  AuthResult({
    required this.user,
    required this.requiereCambioPassword,
    this.permisos,
  });
}

class AuthService {
  static Map<String, dynamic> _dataMap(dynamic body) {
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map) {
      return Map<String, dynamic>.from(body);
    }
    throw StateError('Respuesta de autenticación inválida');
  }

  static Future<void> _saveResponseTokens(Map<String, dynamic> data) async {
    final token = data['token'];
    final refreshToken = data['refreshToken'];
    if (token is! String || token.isEmpty) {
      throw StateError('El backend no expuso el token para la app móvil');
    }
    if (refreshToken is! String || refreshToken.isEmpty) {
      throw StateError(
        'El backend no expuso el refresh token para la app móvil',
      );
    }
    await ApiService.saveTokens(token, refreshToken);
  }

  static Future<AuthResult> login(String rut, String password) async {
    final response = await ApiService.dio.post(
      '/auth/login',
      data: {'rut': rut, 'password': password},
    );

    final data = _dataMap(response.data);
    await _saveResponseTokens(data);

    return AuthResult(
      user: UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map)),
      requiereCambioPassword: data['requiereCambioPassword'] ?? false,
    );
  }

  static Future<AuthResult> loginEmpresa(String email, String password) async {
    final response = await ApiService.dio.post(
      '/auth/login/empresa',
      data: {'email': email, 'password': password},
    );

    final data = _dataMap(response.data);
    await _saveResponseTokens(data);

    return AuthResult(
      user: UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map)),
      requiereCambioPassword: data['requiereCambioPassword'] ?? false,
      permisos: data['permisos'] is Map
          ? Map<String, dynamic>.from(data['permisos'] as Map)
          : null,
    );
  }

  static Future<void> logout() async {
    try {
      await ApiService.dio.post('/auth/logout');
    } on DioException {
      // Ignorar errores al hacer logout
    } finally {
      await ApiService.clearTokens();
    }
  }

  static Future<UserModel> getProfile() async {
    final response = await ApiService.dio.get('/auth/me');
    return UserModel.fromJson(response.data['data']);
  }

  static Future<void> cambiarPassword(
    String passwordActual,
    String passwordNuevo,
  ) async {
    await ApiService.dio.post(
      '/auth/cambiar-password',
      data: {'passwordActual': passwordActual, 'passwordNuevo': passwordNuevo},
    );
  }
}
