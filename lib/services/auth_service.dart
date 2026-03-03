import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel user;
  final bool requiereCambioPassword;

  AuthResult({required this.user, required this.requiereCambioPassword});
}

class AuthService {
  static Future<AuthResult> login(String rut, String password) async {
    final response = await ApiService.dio.post(
      '/auth/login',
      data: {'rut': rut, 'password': password},
    );

    final data = response.data['data'];
    await ApiService.saveTokens(data['token'], data['refreshToken']);

    return AuthResult(
      user: UserModel.fromJson(data['user']),
      requiereCambioPassword: data['requiereCambioPassword'] ?? false,
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
