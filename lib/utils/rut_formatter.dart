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
