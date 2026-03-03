// path: lib/screens/terms_screen.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/settings_header.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : AppColors.backgroundLight,
      appBar: const SettingsHeader(title: 'Términos y Condiciones'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              isDark,
              title: '1. Aceptación de los Términos',
              body:
                  'Al utilizar la aplicación ElectricAutomaticChile, aceptas quedar vinculado por estos términos y condiciones. Si no estás de acuerdo con alguna parte de estos términos, no podrás acceder al servicio.',
            ),
            _buildSection(
              isDark,
              title: '2. Uso del Servicio',
              body:
                  'Esta aplicación está destinada exclusivamente para clientes registrados de ElectricAutomaticChile. El acceso es personal e intransferible. Queda prohibido compartir tus credenciales de acceso con terceros.',
            ),
            _buildSection(
              isDark,
              title: '3. Privacidad y Datos Personales',
              body:
                  'Recopilamos y procesamos tus datos personales conforme a la Ley N° 19.628 sobre Protección de la Vida Privada de Chile. Los datos de consumo eléctrico son utilizados únicamente para la prestación del servicio y la generación de reportes.',
            ),
            _buildSection(
              isDark,
              title: '4. Control Remoto del Suministro',
              body:
                  'Las solicitudes de corte o reconexión del suministro eléctrico realizadas a través de la aplicación están sujetas a verificación. ElectricAutomaticChile no se responsabiliza por daños derivados del uso indebido de esta funcionalidad.',
            ),
            _buildSection(
              isDark,
              title: '5. Facturación y Pagos',
              body:
                  'Los montos mostrados en la aplicación son referenciales y pueden diferir de la factura oficial. El pago a través de la aplicación está sujeto a la disponibilidad de los medios de pago habilitados.',
            ),
            _buildSection(
              isDark,
              title: '6. Limitación de Responsabilidad',
              body:
                  'ElectricAutomaticChile no garantiza la disponibilidad continua del servicio. No seremos responsables por interrupciones del servicio debidas a mantenimiento, fallas técnicas o causas de fuerza mayor.',
            ),
            _buildSection(
              isDark,
              title: '7. Modificaciones',
              body:
                  'Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios entrarán en vigor al ser publicados en la aplicación. El uso continuado del servicio implica la aceptación de los nuevos términos.',
            ),
            _buildSection(
              isDark,
              title: '8. Contacto',
              body:
                  'Para consultas relacionadas con estos términos, puedes contactarnos a través de la sección de Soporte dentro de la aplicación o escribirnos a contacto@electricautomaticchile.cl.',
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Última actualización: Enero 2026',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.mutedForeground,
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    bool isDark, {
    required String title,
    required String body,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                (isDark
                        ? AppTypography.bodyLargeDark
                        : AppTypography.bodyLargeLight)
                    .copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: isDark ? AppTypography.bodyDark : AppTypography.bodyLight,
          ),
        ],
      ),
    );
  }
}
