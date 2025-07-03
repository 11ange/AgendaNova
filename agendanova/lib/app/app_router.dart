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


// Classe para gerenciar as rotas do aplicativo usando GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login', // Rota inicial do aplicativo
    routes: <GoRoute>[
      // Rota para a tela de Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // Rota para a tela inicial após o login
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      // Rotas para o módulo de Pacientes
      GoRoute(
        path: '/pacientes-ativos',
        builder: (context, state) => const PacientesAtivosPage(),
        routes: [
          GoRoute(
            path: 'novo', // Rota para o formulário de novo paciente
            builder: (context, state) => const PacienteFormPage(),
          ),
          GoRoute(
            path: 'editar/:id', // Rota para o formulário de edição de paciente
            builder: (context, state) {
              final pacienteId = state.pathParameters['id']!;
              return PacienteFormPage(pacienteId: pacienteId);
            },
          ),
          GoRoute(
            path: 'historico/:id', // Rota para o histórico do paciente
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
      // Rota para a tela de Agenda
      GoRoute(
        path: '/agenda',
        builder: (context, state) => const AgendaPage(),
      ),
      // Rota para a tela de Sessões
      GoRoute(
        path: '/sessoes',
        builder: (context, state) => const SessoesPage(),
      ),
      // Rota para a tela de Pagamentos
      GoRoute(
        path: '/pagamentos',
        builder: (context, state) => const PagamentosPage(),
      ),
      // Rota para a tela de Relatórios
      GoRoute(
        path: '/relatorios',
        builder: (context, state) => const RelatoriosPage(),
      ),
      // Rota para a tela de Lista de Espera
      GoRoute(
        path: '/lista-espera',
        builder: (context, state) => const ListaEsperaPage(),
      ),
    ],
  );
}

