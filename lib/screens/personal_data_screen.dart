// path: lib/screens/personal_data_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/shadows.dart';
import '../models/user_provider.dart';
import '../services/api_service.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_text_field.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.nombre ?? '');
    _emailController = TextEditingController(text: user?.correo ?? '');
    _phoneController = TextEditingController(text: user?.telefono ?? '');
    _addressController = TextEditingController(text: user?.direccion ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Correo inválido';
    }
    return null;
  }

  bool _isSaving = false;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id ?? '';

      await ApiService.dio.put(
        '/clientes/$userId',
        data: {
          'nombre': _nameController.text.trim(),
          'correo': _emailController.text.trim(),
          'telefono': _phoneController.text.trim(),
          'direccion': _addressController.text.trim(),
        },
      );

      userProvider.updateUser(
        nombre: _nameController.text.trim(),
        correo: _emailController.text.trim(),
        telefono: _phoneController.text.trim(),
        direccion: _addressController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cambios guardados exitosamente'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudieron guardar los cambios'),
            backgroundColor: AppColors.danger,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const SettingsHeader(title: 'Datos Personales'),
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
                  icon: Icons.person_outline,
                  label: 'Nombre completo',
                  hintText: 'Juan Pérez',
                  controller: _nameController,
                  validator: _validateName,
                ),
                SizedBox(height: AppSpacing.md),
                SettingsTextField(
                  icon: Icons.email_outlined,
                  label: 'Correo electrónico',
                  hintText: 'juan@correo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: AppSpacing.md),
                SettingsTextField(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  hintText: '+56 9 1234 5678',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: AppSpacing.md),
                SettingsTextField(
                  icon: Icons.location_on_outlined,
                  label: 'Dirección',
                  hintText: 'Av. Principal 123, Santiago',
                  controller: _addressController,
                  maxLines: 2,
                ),
                SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
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
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Guardar cambios',
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
