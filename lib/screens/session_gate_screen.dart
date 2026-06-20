import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/user_provider.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';

class SessionGateScreen extends StatefulWidget {
  const SessionGateScreen({super.key});

  @override
  State<SessionGateScreen> createState() => _SessionGateScreenState();
}

class _SessionGateScreenState extends State<SessionGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  Future<void> _restoreSession() async {
    final token = await ApiService.getToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      _go(AppRoutes.login);
      return;
    }

    try {
      final user = await AuthService.getProfile();
      if (!mounted) return;
      context.read<UserProvider>().setUser(user);
      _go(_homeFor(user));
    } catch (_) {
      await ApiService.clearTokens();
      if (!mounted) return;
      context.read<UserProvider>().clearUser();
      _go(AppRoutes.login);
    }
  }

  void _go(String route) {
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  String _homeFor(UserModel user) {
    final role = user.role.toLowerCase();
    if (role.contains('empresa') ||
        role.contains('admin') ||
        role.contains('operador')) {
      return AppRoutes.empresaDashboard;
    }
    return AppRoutes.clientDashboard;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 42,
          height: 42,
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}
