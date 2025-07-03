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
import 'package:agendanova/presentation/sessoes/viewmodels/sessoes_viewmodel.dart'; // Importar SessoesViewModel


// Classe para gerenciar as rotas do aplicativo usando GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
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
        builder: (context, state) => const PacientesAtivosPage(),
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
        builder: (context, state) => const PacientesInativosPage(),
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
        builder: (context, state) => ChangeNotifierProvider( // Fornece o ViewModel aqui
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
  );
}

