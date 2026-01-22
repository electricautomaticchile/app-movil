// path: lib/widgets/historical_card.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/shadows.dart';
import 'energy_line_chart.dart';

class HistoricalCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color borderColor;
  final List<double> chartData;

  const HistoricalCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.borderColor,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          // Barra lateral de color
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLg),
                bottomLeft: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),

                  // Valor
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: AppTypography.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(unit, style: AppTypography.bodySmall),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // Mini gráfico
                  EnergyLineChart(
                    values: chartData,
                    color: borderColor,
                    fillOpacity: 0.1,
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
