import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:agenda_treinamento/presentation/common_widgets/custom_app_bar.dart';
import 'package:agenda_treinamento/presentation/home/viewmodels/home_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:agenda_treinamento/injection_container.dart' as di;
import 'package:agenda_treinamento/domain/entities/sessao.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'pt_BR';

    return ChangeNotifierProvider(
      create: (_) => GetIt.instance<HomeViewModel>(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'AgendaNova',
          actions: [
            Consumer<HomeViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await viewModel.signOut();
                    await GetIt.instance.reset();
                    await di.init();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  tooltip: 'Sair',
                );
              },
            ),
          ],
        ),
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- DASHBOARD METRICS ---
                  Row(
                    children: [
                      _buildMetricCard(
                        context,
                        'Sessões Hoje',
                        viewModel.sessoesHojeCount.toString(),
                        Icons.today,
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        context,
                        'Pagamentos',
                        viewModel.pagamentosPendentesCount.toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        context,
                        'Aniversários',
                        viewModel.aniversariantesMesCount.toString(),
                        Icons.cake,
                        Colors.pink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- NEXT SESSION HIGHLIGHT ---
                  if (viewModel.proximaSessao != null) ...[
                    _buildNextSessionCard(context, viewModel, viewModel.proximaSessao!),
                    const SizedBox(height: 20),
                  ],

                  // --- QUICK ACCESS GRID ---
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.0,
                    children: [
                      _buildModuleButton(context, 'Pacientes', Icons.people, '/pacientes'),
                      _buildModuleButton(context, 'Sessões', Icons.event_note, '/sessoes'),
                      _buildModuleButton(context, 'Pagamentos', Icons.payment, '/pagamentos'),
                      _buildModuleButton(context, 'Agenda', Icons.calendar_today, '/agenda'),
                      _buildModuleButton(context, 'Lista Espera', Icons.queue, '/lista-espera'),
                      _buildModuleButton(context, 'Relatórios', Icons.bar_chart, '/relatorios'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- UPCOMING SCHEDULES ---
                  _buildSectionTitle(context, 'Próximos Agendamentos'),
                  const SizedBox(height: 8),
                  _buildUpcomingList(context, viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextSessionCard(BuildContext context, HomeViewModel viewModel, Sessao sessao) {
    return Card(
      elevation: 4,
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('PRÓXIMA SESSÃO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(
                  DateFormat.Hm('pt_BR').format(sessao.dataHora),
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(sessao.pacienteNome, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('Sessão ${sessao.numeroSessao} de ${sessao.totalSessoes}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => viewModel.marcarComoRealizada(sessao),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('MARCAR COMO REALIZADA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildUpcomingList(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.proximosAgendamentos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Nenhum agendamento futuro.'),
        ),
      );
    }

    return Column(
      children: viewModel.proximosAgendamentos.map((sessao) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(sessao.pacienteNome[0], style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
            title: Text(sessao.pacienteNome, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${DateFormat.EEEE('pt_BR').format(sessao.dataHora)}, ${DateFormat('d/MMM', 'pt_BR').format(sessao.dataHora)}'),
            trailing: Text(DateFormat.Hm('pt_BR').format(sessao.dataHora), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModuleButton(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
