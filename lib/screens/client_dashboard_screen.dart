import 'package:flutter/material.dart';
import '../data/mock_db.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );

    // imprimir cada accion consola
    print('Action: $message');
  }

  @override
  Widget build(BuildContext context) {
    // datos del medidor se obtienen
    final currentSeries = MockDB.generateEnergySeries();
    final previousSeries = MockDB.generatePreviousMonthSeries();
    final percentChange = MockDB.calculatePercentChange(currentSeries);

    // calcular totales y se multipliciarian, con funcoin .round se redondea dejando asi en enteros y no decimales
    final currentTotal = (currentSeries.reduce((a, b) => a + b) * 1000).round();
    final previousTotal = (previousSeries.reduce((a, b) => a + b) * 1000)
        .round();

    return Scaffold(
      backgroundColor: AppColors.background,
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

                  Text('¿Qué haremos hoy?', style: AppTypography.h3),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // SIDEBAR
            IconButton(
              icon: const Icon(Icons.menu, size: 18),
              onPressed: () => Scaffold.of(context).openDrawer(),
              color: AppColors.foreground,
            ),
            SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ELECTRICAUTOMATICCHILE', style: AppTypography.label),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text('Bienvenido, ', style: AppTypography.h2),
                    Text(
                      'Emmanuel',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.primary,
                      ),
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
              icon: Icons.person_outline,
              onTap: () => _showSnackBar(context, 'Perfil'),
            ),
            SizedBox(width: AppSpacing.sm),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Histórico', style: AppTypography.h3),
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
