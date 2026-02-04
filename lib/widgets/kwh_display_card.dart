// path: lib/widgets/kwh_display_card.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class KwhDisplayCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const KwhDisplayCard({
    super.key,
    required this.value,
    this.unit = 'kWh',
    this.label = 'Consumo Actual',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with label and period badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: const Text(
                  'Febrero 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.xl),
          
          // Main value display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Stats row
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Promedio diario', '8.2 kWh'),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildStatItem('vs mes anterior', '-12%', isPositive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isPositive = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPositive)
              Icon(
                Icons.trending_down,
                color: Colors.greenAccent.shade200,
                size: 16,
              ),
            if (isPositive) const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPositive ? Colors.greenAccent.shade200 : Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
