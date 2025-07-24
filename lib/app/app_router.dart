// lib/app/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:agenda_treinamento/presentation/auth/pages/login_page.dart';
import 'package:agenda_treinamento/presentation/home/pages/home_page.dart';
import 'package:agenda_treinamento/presentation/pacientes/pages/pacientes_ativos_page.dart';
import 'package:agenda_treinamento/presentation/pacientes/pages/paciente_form_page.dart';
import 'package:agenda_treinamento/presentation/pacientes/pages/pacientes_inativos_page.dart';
import 'package:agenda_treinamento/presentation/pacientes/pages/historico_paciente_page.dart';
import 'package:agenda_treinamento/presentation/agenda/pages/agenda_page.dart';
import 'package:agenda_treinamento/presentation/sessoes/pages/sessoes_page.dart';
import 'package:agenda_treinamento/presentation/pagamentos/pages/pagamentos_page.dart';
import 'package:agenda_treinamento/presentation/relatorios/pages/relatorios_page.dart';
import 'package:agenda_treinamento/presentation/lista_espera/pages/lista_espera_page.dart';
import 'package:provider/provider.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/paciente_form_viewmodel.dart';
import 'package:agenda_treinamento/presentation/agenda/viewmodels/agenda_viewmodel.dart';
import 'package:agenda_treinamento/presentation/lista_espera/viewmodels/lista_espera_viewmodel.dart';
import 'package:agenda_treinamento/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:agenda_treinamento/core/services/firebase_service.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/pacientes_ativos_viewmodel.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/pacientes_inativos_viewmodel.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login', // Pode iniciar no login, o redirect cuidará do resto
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
      // --- CORREÇÃO AQUI ---
      // A verificação de kDebugMode foi removida, pois a lógica agora é robusta.
      
      final bool loggedIn = FirebaseService.instance.getCurrentUser() != null;
      final bool isLoggingIn = state.matchedLocation == '/login';

      // Se não está logado e não está indo para a tela de login, redireciona para /login
      if (!loggedIn && !isLoggingIn) {
        return '/login';
      }

      // Se está logado e tentando acessar a tela de login, redireciona para /home
      if (loggedIn && isLoggingIn) {
        return '/home';
      }

      // Em todos os outros casos, permite a navegação.
      return null;
    },
  );
}