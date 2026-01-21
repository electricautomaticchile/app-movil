// path: lib/screens/recover_screen.dart

import 'package:flutter/material.dart';
import '../widgets/screen_container.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_link.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../routes/app_routes.dart';

class RecoverScreen extends StatefulWidget {
  const RecoverScreen({super.key});

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
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

  Future<void> _handleRecover() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScreenContainer(
      child: AppCard(
        child: _emailSent
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(76, 175, 80, 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  Text(
                    '¡Correo Enviado!',
                    style: isDark
                        ? AppTypography.h1Dark
                        : AppTypography.h1Light,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),

                  Text(
                    'Hemos enviado instrucciones de recuperación a:',
                    style: isDark
                        ? AppTypography.bodyDark
                        : AppTypography.bodyLight,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm),

                  Text(
                    _emailController.text,
                    style:
                        (isDark
                                ? AppTypography.bodyLargeDark
                                : AppTypography.bodyLargeLight)
                            .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl),

                  PrimaryButton(
                    text: 'Volver al Inicio',
                    icon: Icons.home,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.landing,
                        (route) => false,
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.md),

                  TextLink(
                    text: 'Ir a Iniciar Sesión',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                  ),
                ],
              )
            : Form(
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

                    // Icon
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 152, 0, 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          size: 32,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Title
                    Text(
                      'Recuperar Contraseña',
                      style: isDark
                          ? AppTypography.h1Dark
                          : AppTypography.h1Light,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),

                    Text(
                      'Ingresa tu correo electrónico y te enviaremos instrucciones para restablecer tu contraseña',
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
                      textInputAction: TextInputAction.done,
                      validator: _validateEmail,
                      enabled: !_isLoading,
                      onFieldSubmitted: (_) => _handleRecover(),
                    ),
                    SizedBox(height: AppSpacing.xl),

                    // Send button
                    PrimaryButton(
                      text: 'Enviar',
                      icon: Icons.send,
                      onPressed: _handleRecover,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Back to login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Recordaste tu contraseña? ',
                          style: isDark
                              ? AppTypography.bodySmallDark
                              : AppTypography.bodySmallLight,
                        ),
                        TextLink(
                          text: 'Inicia sesión',
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
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
