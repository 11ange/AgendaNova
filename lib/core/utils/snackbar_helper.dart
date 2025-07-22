// lib/core/utils/snackbar_helper.dart
import 'package:flutter/material.dart';

class SnackBarHelper {
  static String parseErrorMessage(Object e) {
    String errorMessage = e.toString().toLowerCase();

    // Erros de negócio (lógica do app)
    if (errorMessage.contains('paciente possui um treinamento ativo')) {
      return 'Ação falhou: O paciente ainda possui um treinamento ativo.';
    }
    if (errorMessage.contains('paciente com este nome cadastrado')) {
      return 'Erro: Já existe um paciente com este nome.';
    }
    if (errorMessage.contains('treinamento agendado para este dia e horário')) {
      return 'Erro: Já existe um treinamento neste dia e horário.';
    }
    if (errorMessage.contains('horário selecionado não está disponível')) {
      return 'Erro: O horário selecionado não está mais disponível.';
    }
    if (errorMessage.contains('horários com sessões já agendadas')) {
      return 'Não é possível remover horários com sessões futuras já agendadas.';
    }

    // Erros de autenticação do Firebase
    if (errorMessage.contains('invalid-email')) {
      return 'O formato do e-mail é inválido.';
    }
    if (errorMessage.contains('email-already-in-use')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (errorMessage.contains('wrong-password') || errorMessage.contains('invalid-credential')) {
      return 'Usuário ou senha incorretos.';
    }

    // Erro padrão para problemas de conexão ou outros casos
    return 'Ocorreu um erro. Verifique sua conexão e tente novamente.';
  }

  // Exibe um SnackBar de sucesso padronizado
  static void showSuccess(
    BuildContext context, 
    String message, {
    // Parâmetro opcional de duração com valor padrão de 3 segundos
    Duration duration = const Duration(seconds: 1),
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: duration, // <<< A propriedade duration é usada aqui
      ),
    );
  }

  // Exibe um SnackBar de erro padronizado
  static void showError(
    BuildContext context, 
    Object e, {
    // Duração padrão maior para erros, permitindo mais tempo para leitura
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;
    final message = parseErrorMessage(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: duration, // <<< A propriedade duration é usada aqui
      ),
    );
  }
}