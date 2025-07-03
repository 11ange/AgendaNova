import 'package:flutter/material.dart';
import 'app_router.dart';
import 'app_theme.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Agenda de Treinamento Fonoaudiológico',
      theme: AppTheme.lightTheme, // Define o tema claro do aplicativo
      routerConfig: AppRouter.router, // Configura as rotas do aplicativo
      debugShowCheckedModeBanner: false, // Remove o banner de "Debug"
    );
  }
}