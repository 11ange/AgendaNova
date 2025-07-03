    import 'package:flutter/material.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'app/app_widget.dart';
    import 'firebase_options.dart';
    import 'injection_container.dart' as di; // Importe com alias

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();

      // Inicializa o Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Inicializa a injeção de dependência
      await di.init(); // Chamada para inicializar o GetIt

      runApp(const AppWidget());
    }
    