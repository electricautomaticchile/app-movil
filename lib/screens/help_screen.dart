// path: lib/screens/help_screen.dart

import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
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

  static const _backgroundColor = Color(0xFF0B0B0B);
  static const _surfaceColor = Color(0xFF1A1A1A);
  static const _inputColor = Color(0xFF232323);
  static const _primaryOrange = Color(0xFFFF7A00);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFF888888);
  static const _borderColor = Color(0xFF333333);

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
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mensaje enviado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _subjectController.clear();
        _messageController.clear();
        setState(() => _selectedCategory = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                SizedBox(height: AppSpacing.xxl),
                _buildForm(),
                SizedBox(height: AppSpacing.xl),
                _buildSubmitButton(),
                SizedBox(height: AppSpacing.xxl),
                _buildContactSection(),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, size: 28),
        color: _textPrimary,
        onPressed: () {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: const Text(
        'Centro de Ayuda',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿En qué podemos\nayudarte?',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        const Text(
          'Completa el formulario y nos pondremos en contacto contigo lo antes posible.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Asunto'),
        SizedBox(height: AppSpacing.sm),
        _buildTextField(
          controller: _subjectController,
          hintText: 'Ej. Problema con mi factura',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un asunto';
            }
            return null;
          },
        ),
        SizedBox(height: AppSpacing.lg),
        _buildLabel('Categoría'),
        SizedBox(height: AppSpacing.sm),
        _buildDropdown(),
        SizedBox(height: AppSpacing.lg),
        _buildLabel('Mensaje'),
        SizedBox(height: AppSpacing.sm),
        _buildTextArea(),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: _textPrimary, fontSize: 16),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        filled: true,
        fillColor: _inputColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
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

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      dropdownColor: _surfaceColor,
      style: const TextStyle(color: _textPrimary, fontSize: 16),
      icon: const Icon(Icons.keyboard_arrow_down, color: _textSecondary),
      decoration: InputDecoration(
        hintText: 'Seleccionar opción',
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        filled: true,
        fillColor: _inputColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
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

  Widget _buildTextArea() {
    return TextFormField(
      controller: _messageController,
      maxLines: 5,
      style: const TextStyle(color: _textPrimary, fontSize: 16),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor describe tu problema';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Describe tu problema en detalle…',
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        filled: true,
        fillColor: _inputColor,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: _borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
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
          backgroundColor: _primaryOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryOrange.withValues(alpha: 0.5),
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

  Widget _buildContactSection() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: _borderColor)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: const Text(
                'O contáctanos directamente',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            const Expanded(child: Divider(color: _borderColor)),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.menu_book_outlined,
                title: 'Preguntas Frecuentes',
                subtitle: 'Dudas generales',
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
                title: 'Llamar a Soporte',
                subtitle: 'Lunes a Viernes',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.support);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _surfaceColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: _primaryOrange.withValues(alpha: 0.1),
        highlightColor: _primaryOrange.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Icon(icon, color: _primaryOrange, size: 28),
              SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _textSecondary,
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
