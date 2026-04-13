import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../models/invoice_provider.dart';
import '../models/notification_provider.dart';
import '../services/auth_service.dart';
import '../utils/rut_formatter.dart';
import '../widgets/screen_container.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rutController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  // C-05: Rate limiting client-side
  int _loginAttempts = 0;
  DateTime? _lockoutUntil;

  @override
  void dispose() {
    _rutController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateRut(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su RUT';
    }
    if (!RegExp(r'^\d{1,2}\.?\d{3}\.?\d{3}-[\dKk]$').hasMatch(value)) {
      return 'Formato inválido. Use: 12.345.678-9';
    }
    // A-05: Validar dígito verificador
    if (!validarRut(value)) {
      return 'RUT inválido. Verifique el dígito verificador';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // C-05: Verificar bloqueo temporal
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demasiados intentos. Espera $remaining segundos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        _rutController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // C-05: Reset intentos en login exitoso
      _loginAttempts = 0;
      _lockoutUntil = null;

      // Guardar usuario en provider
      final userProvider = context.read<UserProvider>();
      userProvider.setUser(result.user);

      // Cargar datos del usuario en paralelo
      await Future.wait([
        context.read<InvoiceProvider>().loadInvoices(result.user.id),
        context.read<NotificationProvider>().loadNotifications(),
      ]);

      if (!mounted) return;

      // Si requiere cambio de contraseña, redirigir ahí primero
      if (result.requiereCambioPassword) {
        Navigator.pushReplacementNamed(context, AppRoutes.changePassword);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.clientDashboard);
      }
    } catch (e) {
      if (!mounted) return;
      // C-05: Incrementar intentos y aplicar delay exponencial
      _loginAttempts++;
      if (_loginAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(
          Duration(seconds: min(300, pow(2, _loginAttempts - 4).toInt() * 15)),
        );
      }
      String mensaje = 'Error al iniciar sesión';
      final errorStr = e.toString();
      if (errorStr.contains('401') || errorStr.contains('credenciales')) {
        mensaje = 'RUT o contraseña incorrectos';
      } else if (errorStr.contains('SocketException') ||
          errorStr.contains('connection')) {
        mensaje = 'Sin conexión al servidor';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScreenContainer(
      child: AppCard(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Iniciar Sesión',
                style: isDark ? AppTypography.h1Dark : AppTypography.h1Light,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Accede con tu RUT',
                style: isDark
                    ? AppTypography.bodyDark
                    : AppTypography.bodyLight,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _rutController,
                decoration: const InputDecoration(
                  labelText: 'RUT',
                  hintText: '12.345.678-9',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                inputFormatters: [RutFormatter()],
                validator: _validateRut,
                enabled: !_isLoading,
              ),
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: '••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
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
                validator: _validatePassword,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: 'Entrar',
                icon: Icons.login,
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
