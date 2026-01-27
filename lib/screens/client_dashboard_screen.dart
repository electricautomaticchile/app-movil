import 'package:flutter/material.dart';
import '../data/mock_db.dart';
import '../routes/app_routes.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/icon_circle_button.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_action.dart';
import '../widgets/historical_card.dart';
import '../widgets/app_drawer.dart';

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

  //sidebar
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

    // Handle logout
    if (message == 'logout') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.landing,
        (route) => false, // Remove all previous routes
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );

    // imprimir cada accion consola
    print('Action: $message');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // datos del medidor se obtienen
    final currentSeries = MockDB.generateEnergySeries();
    final previousSeries = MockDB.generatePreviousMonthSeries();
    final percentChange = MockDB.calculatePercentChange(currentSeries);

    // calcular totales y se multipliciarian, con funcoin .round se redondea dejando asi en enteros y no decimales
    final currentTotal = (currentSeries.reduce((a, b) => a + b) * 1000).round();
    final previousTotal = (previousSeries.reduce((a, b) => a + b) * 1000)
        .round();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A) // Gris oscuro, no negro puro
          : AppColors.backgroundLight,
      drawer: AppDrawer(
        selectedKey: 'home',
        onSelect: (key) => _showSnackBar(context, key),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header de la app
                  _buildHeader(context),
                  SizedBox(height: AppSpacing.xxl),

                  // card consumo
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
                    style: isDark
                        ? AppTypography.h3Dark
                        : AppTypography.h3Light,
                  ),
                  SizedBox(height: AppSpacing.lg),

                  _buildQuickActions(context),
                  SizedBox(height: AppSpacing.xxl),

                  // card historico
                  _buildHistoricalHeader(context),
                  SizedBox(height: AppSpacing.lg),

                  _buildHistoricalCards(
                    context,
                    currentTotal,
                    previousTotal,
                    currentSeries,
                    previousSeries,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // SIDEBAR
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
                      style:
                          (isDark
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
            IconCircleButton(
              icon: Icons.notifications_outlined,
              showBadge: true,
              onTap: () => _showSnackBar(context, 'Notificaciones'),
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
          onTap: () => _showSnackBar(context, 'Facturas'),
        ),
        QuickAction(
          icon: Icons.help_outline,
          label: 'Ayuda',
          onTap: () => _showSnackBar(context, 'Ayuda'),
        ),
        QuickAction(
          icon: Icons.payment_outlined,
          label: 'Pagos',
          onTap: () => _showSnackBar(context, 'Pagos'),
        ),
        QuickAction(
          icon: Icons.settings_outlined,
          label: 'Ajustes',
          onTap: () => _showSnackBar(context, 'Ajustes'),
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
          onTap: () => _showSnackBar(context, 'Ver más'),
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
