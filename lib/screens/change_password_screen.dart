// path: lib/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/shadows.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña actual es requerida';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La nueva contraseña es requerida';
    }
    if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu nueva contraseña';
    }
    if (value != _newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  bool _isLoading = false;

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.cambiarPassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada exitosamente'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _formKey.currentState!.reset();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: ${e.toString()}'),
          backgroundColor: AppColors.danger,
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

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const SettingsHeader(title: 'Cambiar Contraseña'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackgroundDark : AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: isDark ? [] : AppShadows.medium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsTextField(
                  icon: Icons.lock_outline,
                  label: 'Contraseña actual',
                  hintText: '••••••',
                  controller: _currentPasswordController,
                  obscureText: true,
                  validator: _validateCurrentPassword,
                ),
                SizedBox(height: AppSpacing.md),
                SettingsTextField(
                  icon: Icons.lock_open_outlined,
                  label: 'Nueva contraseña',
                  hintText: '••••••',
                  controller: _newPasswordController,
                  obscureText: true,
                  validator: _validateNewPassword,
                ),
                SizedBox(height: AppSpacing.md),
                SettingsTextField(
                  icon: Icons.lock_open_outlined,
                  label: 'Confirmar nueva contraseña',
                  hintText: '••••••',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: _validateConfirmPassword,
                ),
                SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Actualizar contraseña',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
