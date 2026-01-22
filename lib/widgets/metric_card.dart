// path: lib/widgets/metric_card.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/shadows.dart';
import 'energy_line_chart.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String percentChange;
  final List<double> chartData;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.percentChange,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = !percentChange.startsWith('-');

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con label y badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}$percentChange%',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Valor grande
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.h1.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  unit,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Gráfico
          EnergyLineChart(
            values: chartData,
            color: AppColors.info,
            fillOpacity: 0.15,
            height: 100,
          ),
        ],
      ),
    );
  }
}
