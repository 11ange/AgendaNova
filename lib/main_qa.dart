import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agenda_treinamento/app/app_widget.dart';
import 'package:agenda_treinamento/firebase_options_qa.dart';
import 'package:agenda_treinamento/injection_container.dart' as di;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configura o app para usar o Firestore Emulator em modo de depuração/teste
  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      debugPrint("Firestore Emulator conectado com sucesso na porta 8080");
    } catch (e) {
      debugPrint("Erro ao conectar ao Firestore Emulator: $e");
    }
  }

  // Esta linha garante que o app espere o Firebase Auth inicializar
  // e carregar a sessão do usuário antes de continuar.
  await FirebaseAuth.instance.authStateChanges().first;

  // Desativa a persistência de dados para garantir um estado limpo nos testes
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  await initializeDateFormatting('pt_BR', null);

  await di.init();

  runApp(const AppWidget());
}

