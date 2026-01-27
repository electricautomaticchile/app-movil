// path: lib/screens/mi_consumo_screen.dart

import 'package:flutter/material.dart';
import '../data/mock_db.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/metric_card.dart';
import '../widgets/historical_card.dart';

class MiConsumoScreen extends StatelessWidget {
  const MiConsumoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Obtener datos del medidor
    final currentSeries = MockDB.generateEnergySeries();
    final previousSeries = MockDB.generatePreviousMonthSeries();
    final percentChange = MockDB.calculatePercentChange(currentSeries);

    // Calcular totales
    final currentTotal = (currentSeries.reduce((a, b) => a + b) * 1000).round();
    final previousTotal = (previousSeries.reduce((a, b) => a + b) * 1000)
        .round();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A) // Gris oscuro, igual que dashboard
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1A1A1A)
            : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.foreground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mi Consumo',
          style: isDark ? AppTypography.h2Dark : AppTypography.h2Light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descripción
              Text(
                'Monitorea tu consumo de energía en tiempo real',
                style: isDark
                    ? AppTypography.bodyDark
                    : AppTypography.bodyLight,
              ),
              SizedBox(height: AppSpacing.xxl),

              // Card de consumo actual
              MetricCard(
                label: 'Consumo Actual',
                value: '245',
                unit: 'kWh',
                percentChange: percentChange.toString(),
                chartData: currentSeries,
              ),
              SizedBox(height: AppSpacing.xxl),

              // Título de histórico
              Text(
                'Comparativa Mensual',
                style: isDark ? AppTypography.h3Dark : AppTypography.h3Light,
              ),
              SizedBox(height: AppSpacing.lg),

              // Cards históricos
              Row(
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
              ),

              SizedBox(height: AppSpacing.xxl),

              // Información adicional
              _buildInfoCard(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Consejos de Ahorro',
                style:
                    (isDark
                            ? AppTypography.bodyLargeDark
                            : AppTypography.bodyLargeLight)
                        .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildTip(context, isDark, 'Desconecta los dispositivos que no uses'),
          SizedBox(height: AppSpacing.sm),
          _buildTip(
            context,
            isDark,
            'Usa electrodomésticos en horas de menor consumo',
          ),
          SizedBox(height: AppSpacing.sm),
          _buildTip(
            context,
            isDark,
            'Cambia a iluminación LED para ahorrar hasta 80%',
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, bool isDark, String tip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle, size: 16, color: AppColors.success),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            tip,
            style: isDark
                ? AppTypography.bodySmallDark
                : AppTypography.bodySmallLight,
          ),
        ),
      ],
    );
  }
}
