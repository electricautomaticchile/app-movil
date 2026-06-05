import 'package:electricautomaticchile/utils/client_number_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClientNumberFormatter', () {
    test('formats eight digits as customer number plus verifier', () {
      final formatter = ClientNumberFormatter();

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '12345678'),
      );

      expect(result.text, '1234567-8');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('removes non-digit characters', () {
      final formatter = ClientNumberFormatter();

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '12.ab34-56'),
      );

      expect(result.text, '123456');
    });

    test('rejects more than eight digits by keeping the old value', () {
      final formatter = ClientNumberFormatter();
      const oldValue = TextEditingValue(text: '1234567-8');

      final result = formatter.formatEditUpdate(
        oldValue,
        const TextEditingValue(text: '123456789'),
      );

      expect(result, oldValue);
    });
  });
}
