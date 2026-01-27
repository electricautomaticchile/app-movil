// path: lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/client_number_formatter.dart';
import '../widgets/screen_container.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_link.dart';
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
  final _clientNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _clientNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateClientNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su número de cliente';
    }
    final clientNumberRegex = RegExp(r'^\d{7}-\d$');
    if (!clientNumberRegex.hasMatch(value)) {
      return 'Formato inválido. Use: 1234567-8';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Navigate to client dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.clientDashboard);
        }
      }
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
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: AppSpacing.md),

              // Title
              Text(
                'Iniciar Sesión como Cliente',
                style: isDark ? AppTypography.h1Dark : AppTypography.h1Light,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),

              Text(
                'Accede con tu número de cliente',
                style: isDark
                    ? AppTypography.bodyDark
                    : AppTypography.bodyLight,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),

              // Client number field
              TextFormField(
                controller: _clientNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Cliente',
                  hintText: '1234567-8',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [ClientNumberFormatter()],
                validator: _validateClientNumber,
                enabled: !_isLoading,
              ),
              SizedBox(height: AppSpacing.md),

              // Password field
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
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                validator: _validatePassword,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              SizedBox(height: AppSpacing.lg),

              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextLink(
                  text: '¿Olvidaste tu contraseña?',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.recover);
                  },
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Login button
              PrimaryButton(
                text: 'Entrar',
                icon: Icons.login,
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),
              SizedBox(height: AppSpacing.lg),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta? ',
                    style: isDark
                        ? AppTypography.bodySmallDark
                        : AppTypography.bodySmallLight,
                  ),
                  TextLink(
                    text: 'Regístrate',
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.register,
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),

              // Company login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Eres empresa? ',
                    style: isDark
                        ? AppTypography.bodySmallDark
                        : AppTypography.bodySmallLight,
                  ),
                  TextLink(
                    text: 'Ingresa aquí',
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.companyLogin,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
