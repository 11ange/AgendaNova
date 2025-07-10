import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import necessário
import 'package:agendanova/app/app_widget.dart';
import 'package:agendanova/firebase_options.dart';
import 'package:agendanova/injection_container.dart' as di;
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- CORREÇÃO AQUI: Desativando o cache do Firestore ---
  // Esta linha instrui o Firestore a não guardar dados em cache no dispositivo,
  // forçando-o a buscar os dados mais recentes do servidor a cada vez.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  // Inicializa os dados de localidade para o pacote intl
  await initializeDateFormatting('pt_BR', null);

  // Inicializa a injeção de dependência
  await di.init();

  runApp(const AppWidget());
}