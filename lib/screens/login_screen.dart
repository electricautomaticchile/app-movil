import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _loginAttempts = 0;
  DateTime? _lockoutUntil;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingresa el correo corporativo';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) return 'Correo inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa la contraseña';
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      _showError('Demasiados intentos. Espera $remaining segundos.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.loginEmpresa(
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
      );

      if (!mounted) return;
      _loginAttempts = 0;
      _lockoutUntil = null;
      context.read<UserProvider>().setUser(
        result.user,
        permissions: result.permisos,
      );

      Navigator.pushReplacementNamed(
        context,
        result.requiereCambioPassword
            ? AppRoutes.changePassword
            : AppRoutes.empresaDashboard,
      );
    } catch (e) {
      if (!mounted) return;
      _loginAttempts++;
      if (_loginAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(
          Duration(seconds: min(300, pow(2, _loginAttempts - 4).toInt() * 15)),
        );
      }
      _showError(_errorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final body = error.response?.data;
      if (status == 401 || status == 403) {
        return 'Correo o contraseña incorrectos';
      }
      if (body is Map) {
        final message = body['message'] ?? body['error'];
        if (message is String && message.isNotEmpty) return message;
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'Sin conexión al servidor';
      }
    }
    return 'No se pudo iniciar sesión';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScreenContainer(
      child: AppCard(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.business_center_outlined,
                  size: 44,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Acceso Empresa',
                  style: isDark ? AppTypography.h1Dark : AppTypography.h1Light,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Ingresa con tu email corporativo',
                  style: isDark
                      ? AppTypography.bodyDark
                      : AppTypography.bodyLight,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo empresa',
                    hintText: 'admin@empresa.cl',
                    prefixIcon: Icon(Icons.alternate_email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: _validateEmail,
                  enabled: !_isLoading,
                ),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: '********',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: _validatePassword,
                  enabled: !_isLoading,
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  text: 'Entrar al panel',
                  icon: Icons.login,
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
