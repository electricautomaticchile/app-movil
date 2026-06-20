import 'package:electricautomaticchile/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('loads system theme by default', () async {
    final provider = ThemeProvider();

    await provider.loadThemeMode();

    expect(provider.themeMode, ThemeMode.system);
    expect(provider.loaded, isTrue);
  });

  test('persists selected theme mode', () async {
    final provider = ThemeProvider();
    await provider.loadThemeMode();

    await provider.setThemeMode(ThemeMode.dark);

    final restored = ThemeProvider();
    await restored.loadThemeMode();

    expect(restored.themeMode, ThemeMode.dark);
  });
}
