// path: lib/widgets/dot_indicator.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class DotIndicator extends StatelessWidget {
  final int totalDots;
  final int activeDot;

  const DotIndicator({super.key, this.totalDots = 3, this.activeDot = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalDots,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == activeDot
                ? AppColors.dotActive
                : AppColors.dotInactive,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
