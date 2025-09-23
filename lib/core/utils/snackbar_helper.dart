// lib/core/utils/snackbar_helper.dart
import 'package:flutter/material.dart';

class SnackBarHelper {
  static String parseErrorMessage(Object e) {
    String errorMessage = e.toString();

    // 1. PRIORIDADE: Se for uma exceção da nossa lógica de negócio,
    // mostramos a mensagem exata que foi definida.
    if (errorMessage.startsWith('Exception: ')) {
      // Remove o prefixo "Exception: " e retorna a mensagem limpa.
      return errorMessage.substring('Exception: '.length);
    }

    // 2. Se não for, verificamos se é um erro conhecido do Firebase (em minúsculas).
    String lowerCaseError = errorMessage.toLowerCase();

    // Erros de negócio (lógica do app) - Mantemos estes para o caso de virem de outras fontes
    if (lowerCaseError.contains('paciente possui um treinamento ativo')) {
      return 'Ação falhou: O paciente ainda possui um treinamento ativo.';
    }
    if (lowerCaseError.contains('paciente com este nome cadastrado')) {
      return 'Erro: Já existe um paciente com este nome.';
    }
    if (lowerCaseError.contains('treinamento agendado para este dia e horário')) {
      return 'Erro: Já existe um treinamento neste dia e horário.';
    }
    if (lowerCaseError.contains('horário selecionado não está disponível')) {
      return 'Erro: O horário selecionado não está mais disponível.';
    }

    // Erros de autenticação do Firebase
    if (lowerCaseError.contains('invalid-email')) {
      return 'O formato do e-mail é inválido.';
    }
    if (lowerCaseError.contains('email-already-in-use')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (lowerCaseError.contains('wrong-password') || lowerCaseError.contains('invalid-credential')) {
      return 'Usuário ou senha incorretos.';
    }

    // 3. Se não for nenhum dos anteriores, mostramos a mensagem genérica.
    return 'Ocorreu um erro. Verifique sua conexão e tente novamente.';
  }

  // O resto do arquivo (showSuccess, showError) permanece igual...
  static void showSuccess(
    BuildContext context, 
    String message, {
    Duration duration = const Duration(seconds: 1),
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  static void showError(
    BuildContext context, 
    Object e, {
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;
    final message = parseErrorMessage(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }
}