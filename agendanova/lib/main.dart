import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_agenda_fono/app/app_widget.dart';
import 'package:flutter_agenda_fono/firebase_options.dart';
import 'package:flutter_agenda_fono/injection_container.dart' as di; // Importe com alias

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa a injeção de dependência
  await di.init();

  runApp(const AppWidget());
}