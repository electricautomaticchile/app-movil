// path: lib/screens/client_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice_provider.dart';
import '../models/notification_provider.dart';
import '../models/user_provider.dart';
import '../routes/app_routes.dart';
import '../services/consumo_service.dart';
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

    // Handle facturas — cambiar tab y recargar boletas
    if (message == 'facturas') {
      _switchToBoletas(context);
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

  void _switchToBoletas(BuildContext context) {
    final clienteId = context.read<UserProvider>().user?.id ?? '';
    if (clienteId.isNotEmpty) {
      context.read<InvoiceProvider>().loadInvoices(clienteId);
    }
    setState(() => _currentIndex = 1);
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
          return FadeTransition(opacity: animation, child: child);
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
      bottomNavigationBar: _buildBottomNav(context, isDark),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 1) {
          // Tab Boletas — recargar al tocar
          final clienteId = context.read<UserProvider>().user?.id ?? '';
          if (clienteId.isNotEmpty) {
            context.read<InvoiceProvider>().loadInvoices(clienteId);
          }
        }
        setState(() => _currentIndex = index);
      },
      backgroundColor: isDark ? AppColors.cardBackgroundDark : Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isDark
          ? AppColors.textSecondaryDark
          : AppColors.mutedForeground,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTypography.label.copyWith(
        fontWeight: FontWeight.w600,
      ),
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
          label: 'Boletas',
        ),
      ],
    );
  }
}

/// Contenido de Home extraído del dashboard original
class _HomeContent extends StatefulWidget {
  final void Function(String) onShowSnackBar;

  const _HomeContent({super.key, required this.onShowSnackBar});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  ConsumoResumen? _resumen;
  bool _loadingConsumo = true;

  @override
  void initState() {
    super.initState();
    _loadConsumo();
  }

  Future<void> _loadConsumo() async {
    try {
      final resumen = await ConsumoService.getResumen();
      if (mounted) {
        setState(() {
          _resumen = resumen;
          _loadingConsumo = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingConsumo = false);
    }
  }

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
                _buildHeader(context, isDark),
                SizedBox(height: AppSpacing.xxl),

                KwhDisplayCard(
                  value: _loadingConsumo
                      ? '...'
                      : _resumen?.consumoActual.toStringAsFixed(2) ?? '--',
                  unit: 'kWh',
                  label: 'Consumo Actual',
                  costo: _resumen?.costoActual,
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

  Widget _buildHeader(BuildContext context, bool isDark) {
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
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return Text(
                          userProvider.user?.nombre.split(' ').first ?? '',
                          style:
                              (isDark
                                      ? AppTypography.h2Dark
                                      : AppTypography.h2Light)
                                  .copyWith(color: AppColors.primary),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            return IconCircleButton(
              icon: Icons.notifications_outlined,
              showBadge: notificationProvider.hasUnread,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
            );
          },
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
          label: 'Boletas',
          onTap: () => widget.onShowSnackBar('facturas'),
        ),
        QuickAction(
          icon: Icons.help_outline,
          label: 'Ayuda',
          onTap: () => widget.onShowSnackBar('help'),
        ),
        QuickAction(
          icon: Icons.payment_outlined,
          label: 'Boletas',
          onTap: () => widget.onShowSnackBar('facturas'),
        ),
        QuickAction(
          icon: Icons.power_settings_new,
          label: 'Control',
          onTap: () => widget.onShowSnackBar('remote_control'),
        ),
        QuickAction(
          icon: Icons.settings_outlined,
          label: 'Ajustes',
          onTap: () => widget.onShowSnackBar('settings'),
        ),
      ],
    );
  }
}
