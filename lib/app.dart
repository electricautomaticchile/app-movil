// path: lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart' show navigatorKey;
import 'theme/theme_provider.dart';
import 'routes/app_routes.dart';
import 'screens/session_gate_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';

import 'screens/empresa_dashboard_screen.dart';
import 'screens/client_dashboard_screen.dart';
import 'screens/mi_consumo_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/personal_data_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/facturas_screen.dart';
import 'screens/help_screen.dart';
import 'screens/support_screen.dart';
// PaymentsScreen eliminada — unificada con FacturasScreen
import 'screens/remote_control_screen.dart';
import 'screens/terms_screen.dart';

class ElectricApp extends StatelessWidget {
  const ElectricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Electricautomaticchile',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,

          // Theme configuration
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,

          // Routes configuration
          initialRoute: AppRoutes.startup,
          onGenerateRoute: (settings) {
            final routes = <String, WidgetBuilder>{
              AppRoutes.startup: (context) => const SessionGateScreen(),
              AppRoutes.landing: (context) => const LandingScreen(),
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.empresaDashboard: (context) =>
                  const EmpresaDashboardScreen(),
              AppRoutes.clientDashboard: (context) =>
                  const ClientDashboardScreen(),
              AppRoutes.miConsumo: (context) => const MiConsumoScreen(),
              AppRoutes.settings: (context) => const SettingsScreen(),
              AppRoutes.personalData: (context) => const PersonalDataScreen(),
              AppRoutes.changePassword: (context) =>
                  const ChangePasswordScreen(),
              AppRoutes.notifications: (context) => const NotificationsScreen(),
              AppRoutes.facturas: (context) => const FacturasScreen(),
              AppRoutes.help: (context) => const HelpScreen(),
              AppRoutes.support: (context) => const SupportScreen(),
              AppRoutes.payments: (context) => const FacturasScreen(),
              AppRoutes.remoteControl: (context) => const RemoteControlScreen(),
              AppRoutes.terms: (context) => const TermsScreen(),
            };

            final builder = routes[settings.name];
            if (builder == null) return null;

            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  builder(context),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
              transitionDuration: const Duration(milliseconds: 250),
            );
          },

          // Error handling
          onUnknownRoute: (settings) {
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          },
        );
      },
    );
  }
}
