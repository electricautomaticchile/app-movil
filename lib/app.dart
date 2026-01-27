// path: lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'routes/app_routes.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/company_login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/recover_screen.dart';
import 'screens/client_dashboard_screen.dart';
import 'screens/mi_consumo_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/personal_data_screen.dart';
import 'screens/change_password_screen.dart';

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
            AppRoutes.companyLogin: (context) => const CompanyLoginScreen(),
            AppRoutes.register: (context) => const RegisterScreen(),
            AppRoutes.recover: (context) => const RecoverScreen(),
            AppRoutes.clientDashboard: (context) =>
                const ClientDashboardScreen(),
            AppRoutes.miConsumo: (context) => const MiConsumoScreen(),
            AppRoutes.settings: (context) => const SettingsScreen(),
            AppRoutes.personalData: (context) => const PersonalDataScreen(),
            AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
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
