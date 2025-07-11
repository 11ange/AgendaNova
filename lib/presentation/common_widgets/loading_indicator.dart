import 'package:flutter/material.dart';

// Widget reutilizável para exibir um indicador de carregamento em tela cheia
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(128), // Fundo semi-transparente (0.5 * 255)
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Cor branca para o indicador
        ),
      ),
    );
  }
}
