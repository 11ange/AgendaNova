import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/core/services/firebase_service.dart';
import 'package:agendanova/presentation/home/viewmodels/home_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart'; // Import necessário
import 'package:agendanova/injection_container.dart' as di; // Import necessário

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'pt_BR';

    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Tela Inicial',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                // --- CORREÇÃO AQUI: Lógica de logout atualizada ---
                
                // 1. Desautenticar o utilizador no Firebase
                await FirebaseService.instance.signOut();

                // 2. Reiniciar o contêiner de injeção de dependência
                await GetIt.instance.reset(); // Limpa todas as instâncias antigas
                await di.init();  // Reinicializa com instâncias novas para a próxima sessão

                // 3. Navegar para a tela de login
                if (context.mounted) {
                  context.go('/login');
                }
              },
              tooltip: 'Sair',
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próximos Horários Disponíveis',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (viewModel.proximosHorariosDisponiveis.isEmpty)
                            Text(
                              'Nenhum horário disponível nos próximos 30 dias.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            ...viewModel.proximosHorariosDisponiveis.map((horario) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '• ${DateFormat.EEEE().format(horario)}, ${DateFormat.yMd().format(horario)} às ${DateFormat.Hm().format(horario)}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próximos Agendamentos',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (viewModel.proximosAgendamentos.isEmpty)
                            Text(
                              'Nenhum agendamento futuro.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            ...viewModel.proximosAgendamentos.map((sessao) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '• ${sessao.pacienteNome} - ${DateFormat.yMd().format(sessao.dataHora)} às ${DateFormat.Hm().format(sessao.dataHora)}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.3,
                      children: [
                        _buildModuleButton(context, 'Pacientes', Icons.people, '/pacientes-ativos'),
                        _buildModuleButton(context, 'Sessões', Icons.event_note, '/sessoes'),
                        _buildModuleButton(context, 'Agenda', Icons.calendar_today, '/agenda'),
                        _buildModuleButton(context, 'Lista de Espera', Icons.queue, '/lista-espera'),
                        _buildModuleButton(context, 'Pagamentos', Icons.payment, '/pagamentos'),
                        _buildModuleButton(context, 'Relatórios', Icons.bar_chart, '/relatorios'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModuleButton(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}