// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:untitled/app.dart';
import 'package:untitled/theme/theme_provider.dart';

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
