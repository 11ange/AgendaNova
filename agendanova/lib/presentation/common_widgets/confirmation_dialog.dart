import 'package:flutter/material.dart';

// Widget de diálogo de confirmação reutilizável
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final String cancelButtonText;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmButtonText = 'Confirmar',
    this.cancelButtonText = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Retorna false ao cancelar
          child: Text(cancelButtonText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true), // Retorna true ao confirmar
          child: Text(confirmButtonText),
        ),
      ],
    );
  }

  // Método estático para exibir o diálogo facilmente
  static Future<bool?> show(BuildContext context, {
    required String title,
    required String content,
    String confirmButtonText = 'Confirmar',
    String cancelButtonText = 'Cancelar',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          content: content,
          confirmButtonText: confirmButtonText,
          cancelButtonText: cancelButtonText,
        );
      },
    );
  }
}

