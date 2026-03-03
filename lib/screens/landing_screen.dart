// path: lib/screens/landing_screen.dart

import 'package:flutter/material.dart';
import '../widgets/screen_container.dart';
import '../widgets/app_card.dart';
import '../widgets/brand_header.dart';
import '../widgets/primary_button.dart';
import '../theme/spacing.dart';
import '../routes/app_routes.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand header with icon, title, subtitle
            const BrandHeader(),
            SizedBox(height: AppSpacing.lg),

            SizedBox(height: AppSpacing.xl),

            // Client login button
            PrimaryButton(
              text: 'Iniciar Sesión',
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
