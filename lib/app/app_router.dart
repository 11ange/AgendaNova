// lib/app/app_router.dart
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/auth/pages/login_page.dart';
import 'package:agendanova/presentation/home/pages/home_page.dart';
import 'package:agendanova/presentation/pacientes/pages/pacientes_ativos_page.dart';
import 'package:agendanova/presentation/pacientes/pages/paciente_form_page.dart';
import 'package:agendanova/presentation/pacientes/pages/pacientes_inativos_page.dart';
import 'package:agendanova/presentation/pacientes/pages/historico_paciente_page.dart';
import 'package:agendanova/presentation/agenda/pages/agenda_page.dart';
import 'package:agendanova/presentation/sessoes/pages/sessoes_page.dart';
import 'package:agendanova/presentation/pagamentos/pages/pagamentos_page.dart';
import 'package:agendanova/presentation/relatorios/pages/relatorios_page.dart';
import 'package:agendanova/presentation/lista_espera/pages/lista_espera_page.dart';
import 'package:provider/provider.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/paciente_form_viewmodel.dart';
import 'package:agendanova/presentation/agenda/viewmodels/agenda_viewmodel.dart';
import 'package:agendanova/presentation/lista_espera/viewmodels/lista_espera_viewmodel.dart';
import 'package:agendanova/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:agendanova/core/services/firebase_service.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/pacientes_ativos_viewmodel.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/pacientes_inativos_viewmodel.dart'; // 1. Importe o ViewModel

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: <GoRoute>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pacientes-ativos',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => PacientesAtivosViewModel(),
          child: const PacientesAtivosPage(),
        ),
        routes: [
          GoRoute(
            path: 'novo',
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => PacienteFormViewModel(),
              child: const PacienteFormPage(),
            ),
          ),
          GoRoute(
            path: 'editar/:id',
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => PacienteFormViewModel(),
              child: PacienteFormPage(pacienteId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: 'historico/:id',
            builder: (context, state) {
              final pacienteId = state.pathParameters['id']!;
              return HistoricoPacientePage(pacienteId: pacienteId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/pacientes-inativos',
        // 2. Envolva a rota com o Provider
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => PacientesInativosViewModel(),
          child: const PacientesInativosPage(),
        ),
      ),
      GoRoute(
        path: '/agenda',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => AgendaViewModel(),
          child: const AgendaPage(),
        ),
      ),
      GoRoute(
        path: '/sessoes',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => SessoesViewModel(),
          child: const SessoesPage(),
        ),
      ),
      GoRoute(
        path: '/pagamentos',
        builder: (context, state) => const PagamentosPage(),
      ),
      GoRoute(
        path: '/relatorios',
        builder: (context, state) => const RelatoriosPage(),
      ),
      GoRoute(
        path: '/lista-espera',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => ListaEsperaViewModel(),
          child: const ListaEsperaPage(),
        ),
      ),
    ],
    redirect: (context, state) {
      if (kDebugMode) {
        return null;
      }

      final bool loggedIn = FirebaseService.instance.getCurrentUser() != null;
      final bool isLoggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !isLoggingIn) {
        return '/login';
      }

      if (loggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
  );
}