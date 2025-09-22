import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  // NOVO: Método estático para formatar um número de telefone a partir de apenas dígitos
  static String formatPhoneNumber(String digitsOnly) {
    final length = digitsOnly.length;

    if (length == 0) {
      return '';
    }

    if (length <= 2) {
      return '($digitsOnly';
    } else if (length <= 6) {
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, length)}';
    } else if (length <= 10) {
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6, length)}';
    } else {
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7, 11)}';
    }
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final maskedText = formatPhoneNumber(digitsOnly);

    return TextEditingValue(
      text: maskedText,
      selection: TextSelection.collapsed(offset: maskedText.length),
    );
  }
}