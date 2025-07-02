import 'package:flutter/material.dart';
import 'package:flutter_agenda_fono/app/app_router.dart';
import 'package:flutter_agenda_fono/app/app_theme.dart';

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