import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agendanova/app/app_widget.dart';
import 'package:agendanova/firebase_options.dart';
import 'package:agendanova/injection_container.dart' as di;
import 'package:intl/date_symbol_data_local.dart'; // Importar para inicialização de dados de localidade

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa os dados de localidade para o pacote intl
  // Isso é necessário para usar DateFormat com locales específicos (ex: 'pt_BR')
  await initializeDateFormatting('pt_BR', null); // Adicionado

  // Inicializa a injeção de dependência
  await di.init();

  runApp(const AppWidget());
}

