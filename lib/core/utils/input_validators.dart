// Utilitário para validação de campos de entrada
class InputValidators {
  // Regex compilado apenas uma vez para melhor performance.
  // O ignore é necessário devido a um falso positivo no linter do Dart recente.
  // ignore: deprecated_member_use
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  
  // ignore: deprecated_member_use
  static final RegExp _digitsRegex = RegExp(r'\D');

  // Valida se um campo obrigatório não está vazio
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório.';
    }
    return null;
  }

  // Valida um formato de e-mail
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null; // O campo não é obrigatório, mas se preenchido, deve ser válido
    }
    
    if (!_emailRegex.hasMatch(value)) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  // Valida um formato de telefone (exemplo básico, pode ser mais robusto)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // O campo não é obrigatório, mas se preenchido, deve ser válido
    }
    // Remove tudo que não for dígito para validação
    final digitsOnly = value.replaceAll(_digitsRegex, '');
    
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      // Ex: 10 para fixo com DDD, 11 para celular com DDD
      return 'Por favor, insira um telefone válido (DDD + número).';
    }
    return null;
  }

  // Valida se um número inteiro é positivo
  static String? positiveInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório.';
    }
    final int? number = int.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName deve ser um número inteiro positivo.';
    }
    return null;
  }
}