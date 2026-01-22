// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:ElectricAutomaticChile/app.dart';
import 'package:ElectricAutomaticChile/theme/theme_provider.dart';

void main() {
  testWidgets('App renders landing screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const ElectricApp(),
      ),
    );

    // Verify that the landing screen renders with brand text
    expect(find.text('Electricautomaticchile'), findsOneWidget);
    expect(find.text('Bienvenido'), findsOneWidget);
  });
}
