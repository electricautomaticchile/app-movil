// path: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'theme/theme_provider.dart';
import 'models/user_provider.dart';
import 'models/notification_provider.dart';
import 'models/invoice_provider.dart';
import 'routes/app_routes.dart';
import 'services/api_service.dart';
import 'services/push_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Redirigir al login empresa cuando el token expira
  ApiService.onUnauthorized = () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  };

  // Notificaciones push (FCM). Al tocar una notificación, llevamos al usuario
  // a la pantalla de notificaciones. Es seguro aunque falten los archivos de
  // Firebase: initialize() captura el error y no bloquea el arranque.
  PushNotificationService.instance.onNotificationTap = (data) {
    navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
  };
  await PushNotificationService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemeMode()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
      ],
      // A-02: Wrapper de inactividad para auto-logout
      child: const InactivityWrapper(child: ElectricApp()),
    ),
  );
}

// A-02: Auto-logout tras 15 minutos de inactividad
class InactivityWrapper extends StatefulWidget {
  final Widget child;
  const InactivityWrapper({super.key, required this.child});

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper>
    with WidgetsBindingObserver {
  DateTime _lastActivity = DateTime.now();
  static const _timeout = Duration(minutes: 15);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (DateTime.now().difference(_lastActivity) > _timeout) {
        _handleTimeout();
      }
    } else if (state == AppLifecycleState.paused) {
      _lastActivity = DateTime.now();
    }
  }

  void _handleTimeout() async {
    await ApiService.clearTokens();
    if (mounted) context.read<UserProvider>().clearUser();
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _lastActivity = DateTime.now(),
      onPanDown: (_) => _lastActivity = DateTime.now(),
      child: widget.child,
    );
  }
}
