// path: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'theme/theme_provider.dart';
import 'models/user_provider.dart';
import 'models/notification_provider.dart';
import 'models/invoice_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
      ],
      child: const ElectricApp(),
    ),
  );
}
