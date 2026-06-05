import 'package:electricautomaticchile/utils/rut_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RutFormatter', () {
    test('formats a Chilean RUT with dots and verifier digit', () {
      final formatter = RutFormatter();

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '123456785'),
      );

      expect(result.text, '12.345.678-5');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('keeps K verifier uppercase', () {
      final formatter = RutFormatter();

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1000005k'),
      );

      expect(result.text, '1.000.005-K');
    });
  });

  group('validarRut', () {
    test('accepts valid RUT values', () {
      expect(validarRut('12.345.678-5'), isTrue);
      expect(validarRut('1.000.005-K'), isTrue);
    });

    test('rejects invalid RUT values', () {
      expect(validarRut('12.345.678-9'), isFalse);
      expect(validarRut('abc'), isFalse);
      expect(validarRut('1'), isFalse);
    });
  });
}
