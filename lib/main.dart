// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <<< IMPORTE O FIREBASE AUTH
import 'package:agendanova/app/app_widget.dart';
import 'package:agendanova/firebase_options.dart';
import 'package:agendanova/injection_container.dart' as di;
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- CORREÇÃO AQUI ---
  // Esta linha garante que o app espere o Firebase Auth inicializar
  // e carregar a sessão do usuário antes de continuar.
  await FirebaseAuth.instance.authStateChanges().first;

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  await initializeDateFormatting('pt_BR', null);

  await di.init();

  runApp(const AppWidget());
}