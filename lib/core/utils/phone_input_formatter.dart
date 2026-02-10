// lib/core/utils/phone_input_formatter.dart
import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  // Otimização: Regex compilado apenas uma vez.
  // O ignore é necessário devido a um falso positivo no linter do Dart recente.
  // ignore: deprecated_member_use
  static final RegExp _digitsRegex = RegExp(r'\D');

  // Método estático para formatar um número de telefone a partir de apenas dígitos
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
      // Limita a 11 dígitos para evitar erro de índice se o usuário colar algo maior
      final safeLength = length > 11 ? 11 : length;
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7, safeLength)}';
    }
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Usa a regex estática para limpar o texto
    final digitsOnly = newValue.text.replaceAll(_digitsRegex, '');
    
    // Limita a quantidade de dígitos para 11 (DDD + 9 dígitos)
    if (digitsOnly.length > 11) {
      return oldValue;
    }

    final maskedText = formatPhoneNumber(digitsOnly);

    return TextEditingValue(
      text: maskedText,
      selection: TextSelection.collapsed(offset: maskedText.length),
    );
  }
}