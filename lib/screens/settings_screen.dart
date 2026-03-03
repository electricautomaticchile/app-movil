// path: lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/theme_provider.dart';
import '../models/user_provider.dart';
import '../services/auth_service.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_section_title.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_switch_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A) // Gris oscuro, igual que dashboard cliente
          : AppColors.backgroundLight,
      appBar: const SettingsHeader(title: 'Configuración'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CUENTA
            const SettingsSectionTitle(title: 'CUENTA'),
            SettingsTile(
              icon: Icons.person_outline,
              title: 'Datos Personales',
              subtitle: 'Actualiza tu información',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.personalData);
              },
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              indent: AppSpacing.md + 24 + AppSpacing.md,
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              title: 'Cambiar Contraseña',
              subtitle: 'Actualiza tu contraseña',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.changePassword);
              },
            ),

            // PERSONALIZA TU EXPERIENCIA
            const SettingsSectionTitle(title: 'PERSONALIZA TU EXPERIENCIA'),
            SettingsSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Tema Oscuro',
              subtitle: 'Ajustar a mi preferencia',
              value: themeProvider.isDarkMode(context),
              onChanged: (value) {
                themeProvider.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              indent: AppSpacing.md + 24 + AppSpacing.md,
            ),
            SettingsSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Notificaciones',
              subtitle: 'Recibe alertas importantes',
              value: userProvider.user?.notificacionesSms ?? false,
              onChanged: (value) {
                userProvider.toggleNotifications(value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Notificaciones activadas'
                          : 'Notificaciones desactivadas',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),

            // AYUDA Y LEGAL
            const SettingsSectionTitle(title: 'AYUDA Y LEGAL'),
            SettingsTile(
              icon: Icons.help_outline,
              title: 'Ayuda',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.help);
              },
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              indent: AppSpacing.md + 24 + AppSpacing.md,
            ),
            SettingsTile(
              icon: Icons.description_outlined,
              title: 'Términos y condiciones',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.terms);
              },
            ),

            SizedBox(height: AppSpacing.xxl),

            // Logout Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService.logout();
                    if (!context.mounted) return;
                    context.read<UserProvider>().clearUser();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.landing,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xxl),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'ELECTRICAUTOMATICCHILE',
                    style: AppTypography.label.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Versión 2.0.1',
                    style: AppTypography.bodySmall.copyWith(
                      color: (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.mutedForeground),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
