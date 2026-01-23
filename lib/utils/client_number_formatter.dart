// path: lib/utils/client_number_formatter.dart

import 'package:flutter/services.dart';

class ClientNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 8 digits total
    if (digitsOnly.length > 8) {
      return oldValue;
    }

    // Format: XXXXXXX-X (7 digits, dash, 1 digit)
    String formatted = '';
    if (digitsOnly.isNotEmpty) {
      // First 7 digits
      formatted = digitsOnly.substring(0, digitsOnly.length.clamp(0, 7));

      // Add dash after 7 digits
      if (digitsOnly.length > 7) {
        formatted += '-${digitsOnly.substring(7)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
