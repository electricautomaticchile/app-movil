// path: lib/screens/client_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_db.dart';
import '../models/notification_provider.dart';
import '../routes/app_routes.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/icon_circle_button.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_action.dart';
import '../widgets/historical_card.dart';
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeContent(
            onShowSnackBar: (msg) => _showSnackBar(context, msg),
          ),
          const FacturasScreen(),
        ],
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

  const _HomeContent({required this.onShowSnackBar});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // datos del medidor
    final currentSeries = MockDB.generateEnergySeries();
    final previousSeries = MockDB.generatePreviousMonthSeries();
    final percentChange = MockDB.calculatePercentChange(currentSeries);

    final currentTotal = (currentSeries.reduce((a, b) => a + b) * 1000).round();
    final previousTotal = (previousSeries.reduce((a, b) => a + b) * 1000).round();

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

                MetricCard(
                  label: 'Consumo Actual',
                  value: '245',
                  unit: 'kWh',
                  percentChange: percentChange.toString(),
                  chartData: currentSeries,
                ),
                SizedBox(height: AppSpacing.xxl),

                Text(
                  '¿Qué haremos hoy?',
                  style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
                ),
                SizedBox(height: AppSpacing.lg),

                _buildQuickActions(context),
                SizedBox(height: AppSpacing.xxl),

                _buildHistoricalHeader(context),
                SizedBox(height: AppSpacing.lg),

                _buildHistoricalCards(
                  context,
                  currentTotal,
                  previousTotal,
                  currentSeries,
                  previousSeries,
                ),
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
          onTap: () => onShowSnackBar('Ayuda'),
        ),
        QuickAction(
          icon: Icons.payment_outlined,
          label: 'Pagos',
          onTap: () => onShowSnackBar('Pagos'),
        ),
        QuickAction(
          icon: Icons.settings_outlined,
          label: 'Ajustes',
          onTap: () => onShowSnackBar('settings'),
        ),
      ],
    );
  }

  Widget _buildHistoricalHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Histórico',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
        ),
        GestureDetector(
          onTap: () => onShowSnackBar('Ver más'),
          child: Text('Ver más', style: AppTypography.link),
        ),
      ],
    );
  }

  Widget _buildHistoricalCards(
    BuildContext context,
    int currentTotal,
    int previousTotal,
    List<double> currentSeries,
    List<double> previousSeries,
  ) {
    return Row(
      children: [
        Expanded(
          child: HistoricalCard(
            label: 'Mes Anterior',
            value: previousTotal.toString(),
            unit: 'kWh',
            borderColor: AppColors.danger,
            chartData: previousSeries,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: HistoricalCard(
            label: 'Mes Actual',
            value: currentTotal.toString(),
            unit: 'kWh',
            borderColor: AppColors.success,
            chartData: currentSeries,
          ),
        ),
      ],
    );
  }
}
