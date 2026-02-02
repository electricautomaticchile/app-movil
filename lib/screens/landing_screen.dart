// path: lib/screens/landing_screen.dart

import 'package:flutter/material.dart';
import '../widgets/screen_container.dart';
import '../widgets/app_card.dart';
import '../widgets/brand_header.dart';
import '../widgets/dot_indicator.dart';
import '../widgets/primary_button.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../routes/app_routes.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScreenContainer(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand header with icon, title, subtitle
            const BrandHeader(),
            SizedBox(height: AppSpacing.lg),

            // Dot indicator
            const DotIndicator(totalDots: 3, activeDot: 0),
            SizedBox(height: AppSpacing.sectionSpacing),

            // Welcome section
            Text(
              'Bienvenido',
              style: isDark ? AppTypography.h2Dark : AppTypography.h2Light,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),

            Text(
              'Gestiona tu energía de forma inteligente',
              style: isDark ? AppTypography.bodyDark : AppTypography.bodyLight,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),

            // Client login button
            PrimaryButton(
              text: 'Iniciar Sesión como cliente',
              icon: Icons.person,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
