import 'package:flutter/material.dart';

// Widget reutilizável para exibir um indicador de carregamento em tela cheia
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5), // Fundo semi-transparente
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Cor branca para o indicador
        ),
      ),
    );
  }
}

