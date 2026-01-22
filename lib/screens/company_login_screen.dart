// path: lib/screens/company_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/screen_container.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_link.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../routes/app_routes.dart';

class CompanyLoginScreen extends StatefulWidget {
  const CompanyLoginScreen({super.key});

  @override
  State<CompanyLoginScreen> createState() => _CompanyLoginScreenState();
}

class _CompanyLoginScreenState extends State<CompanyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rutController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _rutController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validar formato RUT chileno (ejemplo: 12.345.678-9)
  String? _validateRUT(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el RUT de la empresa';
    }

    // Remover puntos y guión
    String rut = value.replaceAll('.', '').replaceAll('-', '');

    if (rut.length < 2) {
      return 'RUT inválido';
    }

    // Separar número y dígito verificador
    String rutNumber = rut.substring(0, rut.length - 1);
    String dv = rut.substring(rut.length - 1).toUpperCase();

    // Validar que el número sea numérico
    if (int.tryParse(rutNumber) == null) {
      return 'RUT debe contener solo números';
    }

    // Calcular dígito verificador
    int suma = 0;
    int multiplicador = 2;

    for (int i = rutNumber.length - 1; i >= 0; i--) {
      suma += int.parse(rutNumber[i]) * multiplicador;
      multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
    }

    int resto = suma % 11;
    String dvCalculado = (11 - resto).toString();

    if (dvCalculado == '11') {
      dvCalculado = '0';
    } else if (dvCalculado == '10') {
      dvCalculado = 'K';
    }

    if (dv != dvCalculado) {
      return 'RUT inválido';
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

  // Formatear RUT mientras se escribe
  String _formatRUT(String value) {
    String rut = value.replaceAll('.', '').replaceAll('-', '');

    if (rut.isEmpty) return '';

    if (rut.length <= 1) return rut;

    String dv = rut.substring(rut.length - 1);
    String number = rut.substring(0, rut.length - 1);

    // Agregar puntos cada 3 dígitos
    String formatted = '';
    int count = 0;
    for (int i = number.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = '.$formatted';
        count = 0;
      }
      formatted = number[i] + formatted;
      count++;
    }

    return '$formatted-$dv';
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
            content: Text('Inicio de sesión de empresa exitoso'),
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

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 152, 0, 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.business,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Iniciar Sesión como Empresa',
                style: isDark ? AppTypography.h1Dark : AppTypography.h1Light,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),

              Text(
                'Accede con el RUT de tu empresa',
                style: isDark
                    ? AppTypography.bodyDark
                    : AppTypography.bodyLight,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),

              // RUT field
              TextFormField(
                controller: _rutController,
                decoration: const InputDecoration(
                  labelText: 'RUT de la Empresa',
                  hintText: '12.345.678-9',
                  prefixIcon: Icon(Icons.badge_outlined),
                  helperText: 'Formato: 12.345.678-9',
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9kK.\-]')),
                  LengthLimitingTextInputFormatter(12),
                ],
                onChanged: (value) {
                  // Auto-format RUT as user types
                  if (value.length >= 2) {
                    String formatted = _formatRUT(value);
                    if (formatted != value) {
                      _rutController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  }
                },
                validator: _validateRUT,
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
                text: 'Entrar como Empresa',
                icon: Icons.business,
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),
              SizedBox(height: AppSpacing.lg),

              // Switch to client login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Eres cliente? ',
                    style: isDark
                        ? AppTypography.bodySmallDark
                        : AppTypography.bodySmallLight,
                  ),
                  TextLink(
                    text: 'Ingresa aquí',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
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
