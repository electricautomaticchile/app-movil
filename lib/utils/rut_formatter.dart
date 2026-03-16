import 'package:flutter/services.dart';

class RutFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Solo dígitos y K/k
    String clean = newValue.text
        .replaceAll('.', '')
        .replaceAll('-', '')
        .toUpperCase()
        .replaceAll(RegExp(r'[^0-9K]'), '');

    if (clean.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Máximo 9 caracteres (8 dígitos + dv)
    if (clean.length > 9) clean = clean.substring(0, 9);

    // Separar dígitos del dv
    final dv = clean.length > 1 ? clean[clean.length - 1] : '';
    final digits = clean.length > 1
        ? clean.substring(0, clean.length - 1)
        : clean;

    // Formatear con puntos: 12.345.678
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) formatted += '.';
      formatted += digits[i];
    }

    if (dv.isNotEmpty) formatted += '-$dv';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// A-05: Validación de dígito verificador del RUT chileno (módulo 11)
bool validarRut(String rut) {
  final clean = rut.replaceAll('.', '').replaceAll('-', '').toUpperCase();
  if (clean.length < 2) return false;

  final dv = clean[clean.length - 1];
  final body = clean.substring(0, clean.length - 1);

  // Verificar que el cuerpo sea numérico
  if (!RegExp(r'^\d+$').hasMatch(body)) return false;

  int sum = 0, mul = 2;
  for (int i = body.length - 1; i >= 0; i--) {
    sum += int.parse(body[i]) * mul;
    mul = mul == 7 ? 2 : mul + 1;
  }

  final remainder = 11 - (sum % 11);
  final expected = remainder == 11
      ? '0'
      : remainder == 10
      ? 'K'
      : '$remainder';
  return dv == expected;
}
