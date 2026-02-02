// path: lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'routes/app_routes.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';

import 'screens/client_dashboard_screen.dart';
import 'screens/mi_consumo_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/personal_data_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/facturas_screen.dart';
import 'screens/help_screen.dart';
import 'screens/support_screen.dart';

class ElectricApp extends StatelessWidget {
  const ElectricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Electricautomaticchile',
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,

          // Routes configuration
          initialRoute: AppRoutes.landing,
          routes: {
            AppRoutes.landing: (context) => const LandingScreen(),
            AppRoutes.login: (context) => const LoginScreen(),

            AppRoutes.clientDashboard: (context) =>
                const ClientDashboardScreen(),
            AppRoutes.miConsumo: (context) => const MiConsumoScreen(),
            AppRoutes.settings: (context) => const SettingsScreen(),
            AppRoutes.personalData: (context) => const PersonalDataScreen(),
            AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
            AppRoutes.notifications: (context) => const NotificationsScreen(),
            AppRoutes.facturas: (context) => const FacturasScreen(),
            AppRoutes.help: (context) => const HelpScreen(),
            AppRoutes.support: (context) => const SupportScreen(),
          },

          // Error handling
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const LandingScreen(),
            );
          },
        );
      },
    );
  }
}
