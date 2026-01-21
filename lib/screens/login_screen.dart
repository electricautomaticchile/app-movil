// path: lib/screens/login_screen.dart

import 'package:flutter/material.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingrese un correo válido';
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
          ),
        );
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
                'Iniciar Sesión',
                style: isDark ? AppTypography.h1Dark : AppTypography.h1Light,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),

              Text(
                'Accede a tu cuenta',
                style: isDark
                    ? AppTypography.bodyDark
                    : AppTypography.bodyLight,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
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
            ],
          ),
        ),
      ),
    );
  }
}
