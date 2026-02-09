// path: lib/screens/client_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_provider.dart';
import '../routes/app_routes.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/icon_circle_button.dart';
import '../widgets/kwh_display_card.dart';
import '../widgets/quick_action.dart';
import '../widgets/app_drawer.dart';
import 'facturas_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _currentIndex = 0;

  void _showSnackBar(BuildContext context, String message) {
    // Handle settings navigation
    if (message == 'settings') {
      Navigator.pushNamed(context, AppRoutes.settings);
      return;
    }

    // Handle Mi Consumo navigation
    if (message == 'mi_consumo') {
      Navigator.pushNamed(context, AppRoutes.miConsumo);
      return;
    }

    // Handle notifications
    if (message == 'notifications' || message == 'alerts') {
      Navigator.pushNamed(context, AppRoutes.notifications);
      return;
    }

    // Handle help
    if (message == 'help') {
      Navigator.pushNamed(context, AppRoutes.help);
      return;
    }

    // Handle payments
    if (message == 'payments') {
      Navigator.pushNamed(context, AppRoutes.payments);
      return;
    }

    // Handle remote control
    if (message == 'remote_control') {
      Navigator.pushNamed(context, AppRoutes.remoteControl);
      return;
    }

    // Handle facturas
    if (message == 'facturas') {
      setState(() => _currentIndex = 1);
      return;
    }

    // Handle logout
    if (message == 'logout') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.landing,
        (route) => false,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : AppColors.backgroundLight,
      drawer: AppDrawer(
        selectedKey: _currentIndex == 0 ? 'home' : 'facturas',
        onSelect: (key) => _showSnackBar(context, key),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _currentIndex == 0
            ? _HomeContent(
                key: const ValueKey('home'),
                onShowSnackBar: (msg) => _showSnackBar(context, msg),
              )
            : FacturasScreen(
                key: const ValueKey('facturas'),
                onBack: () => setState(() => _currentIndex = 0),
              ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      backgroundColor: isDark ? AppColors.cardBackgroundDark : Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.mutedForeground,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTypography.label,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Facturas',
        ),
      ],
    );
  }
}

/// Contenido de Home extraído del dashboard original
class _HomeContent extends StatelessWidget {
  final void Function(String) onShowSnackBar;

  const _HomeContent({super.key, required this.onShowSnackBar});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Builder(
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: AppSpacing.xxl),

                KwhDisplayCard(
                  value: '245',
                  unit: 'kWh',
                  label: 'Consumo Actual',
                ),
                SizedBox(height: AppSpacing.xxl),

                Text(
                  '¿Qué haremos hoy?',
                  style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
                ),
                SizedBox(height: AppSpacing.lg),

                _buildQuickActions(context),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, size: 18),
              onPressed: () => Scaffold.of(context).openDrawer(),
              color: isDark ? AppColors.textPrimaryDark : AppColors.foreground,
            ),
            SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Text(
                      'Bienvenido, ',
                      style: isDark
                          ? AppTypography.h2Dark
                          : AppTypography.h2Light,
                    ),
                    Text(
                      'Emmanuel',
                      style: (isDark
                              ? AppTypography.h2Dark
                              : AppTypography.h2Light)
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                return IconCircleButton(
                  icon: Icons.notifications_outlined,
                  showBadge: notificationProvider.hasUnread,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        QuickAction(
          icon: Icons.receipt_outlined,
          label: 'Facturas',
          onTap: () => onShowSnackBar('facturas'),
        ),
        QuickAction(
          icon: Icons.help_outline,
          label: 'Ayuda',
          onTap: () => onShowSnackBar('help'),
        ),
        QuickAction(
          icon: Icons.payment_outlined,
          label: 'Pagos',
          onTap: () => onShowSnackBar('payments'),
        ),
        QuickAction(
          icon: Icons.power_settings_new,
          label: 'Control',
          onTap: () => onShowSnackBar('remote_control'),
        ),
        QuickAction(
          icon: Icons.settings_outlined,
          label: 'Ajustes',
          onTap: () => onShowSnackBar('settings'),
        ),
      ],
    );
  }

}
