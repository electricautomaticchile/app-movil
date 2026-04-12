// path: lib/screens/help_screen.dart

import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class HelpScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const HelpScreen({super.key, this.onBack});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  static const List<String> _categories = [
    'Facturación',
    'Consumo',
    'Pagos',
    'Cuenta',
    'Otro',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ApiService.dio.post('/tickets', data: {
          'asunto': _subjectController.text.trim(),
          'categoria': _selectedCategory,
          'mensaje': _messageController.text.trim(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mensaje enviado correctamente. Te responderemos pronto.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
          _subjectController.clear();
          _messageController.clear();
          setState(() => _selectedCategory = null);
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo enviar el mensaje. Intenta de nuevo.'),
              backgroundColor: AppColors.danger,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0B0B0B) : AppColors.backgroundLight;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(isDark),
                SizedBox(height: AppSpacing.xxl),
                _buildForm(isDark),
                SizedBox(height: AppSpacing.xl),
                _buildSubmitButton(),
                SizedBox(height: AppSpacing.xxl),
                _buildContactSection(isDark),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF0B0B0B) : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, size: 28),
        color: textColor,
        onPressed: () {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        'Centro de Ayuda',
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroSection(bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿En qué podemos\nayudarte?',
          style: TextStyle(
            color: textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Completa el formulario y nos pondremos en contacto contigo lo antes posible.',
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Asunto', isDark),
        SizedBox(height: AppSpacing.sm),
        _buildTextField(
          controller: _subjectController,
          hintText: 'Ej. Problema con mi factura',
          isDark: isDark,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un asunto';
            }
            return null;
          },
        ),
        SizedBox(height: AppSpacing.lg),
        _buildLabel('Categoría', isDark),
        SizedBox(height: AppSpacing.sm),
        _buildDropdown(isDark),
        SizedBox(height: AppSpacing.lg),
        _buildLabel('Mensaje', isDark),
        SizedBox(height: AppSpacing.sm),
        _buildTextArea(isDark),
      ],
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    
    return Text(
      text,
      style: TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final inputColor = isDark ? const Color(0xFF232323) : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textPrimary, fontSize: 16),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textSecondary, fontSize: 15),
        filled: true,
        fillColor: inputColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : AppColors.surfaceLight;
    final inputColor = isDark ? const Color(0xFF232323) : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      dropdownColor: surfaceColor,
      style: TextStyle(color: textPrimary, fontSize: 16),
      icon: Icon(Icons.keyboard_arrow_down, color: textSecondary),
      decoration: InputDecoration(
        hintText: 'Seleccionar opción',
        hintStyle: TextStyle(color: textSecondary, fontSize: 15),
        filled: true,
        fillColor: inputColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona una categoría';
        }
        return null;
      },
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
    );
  }

  Widget _buildTextArea(bool isDark) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final inputColor = isDark ? const Color(0xFF232323) : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    
    return TextFormField(
      controller: _messageController,
      maxLines: 5,
      style: TextStyle(color: textPrimary, fontSize: 16),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor describe tu problema';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Describe tu problema en detalle…',
        hintStyle: TextStyle(color: textSecondary, fontSize: 15),
        filled: true,
        fillColor: inputColor,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Enviar Mensaje',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildContactSection(bool isDark) {
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(child: Divider(color: borderColor)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'O contáctanos directamente',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(child: Divider(color: borderColor)),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        
        // Contact cards
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.menu_book_outlined,
                title: 'Preguntas Frecuentes',
                subtitle: 'Dudas generales',
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preguntas frecuentes')),
                  );
                },
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildContactCard(
                icon: Icons.phone_outlined,
                title: 'Llamar',
                subtitle: '+56 2 2345 6789',
                isDark: isDark,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.support);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        
        // Operating hours info
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                color: textSecondary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Horario de atención: Lunes a Viernes, 9:00 - 18:00 hrs',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : AppColors.surfaceLight;
    
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
