import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/core/services/firebase_service.dart'; // Para logout

// Tela Inicial do aplicativo
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tela Inicial',
        // Não há botão de retorno na tela inicial, mas podemos adicionar um botão de logout
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseService.instance.signOut();
              if (context.mounted) {
                context.go(
                  '/login',
                ); // Volta para a tela de login após o logout
              }
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção de Próximos Horários Disponíveis
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
                    const SizedBox(height: 10),
                    // TODO: Adicionar lógica para exibir horários disponíveis
                    Text(
                      'Nenhum horário disponível no momento.', // Placeholder
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Seção de Próximos Agendamentos
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
                    const SizedBox(height: 10),
                    // TODO: Adicionar lógica para exibir próximos agendamentos
                    Text(
                      'Nenhum agendamento futuro.', // Placeholder
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Botões de Navegação para os Módulos
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 colunas
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildModuleButton(
                    context,
                    'Pacientes',
                    Icons.people,
                    '/pacientes-ativos',
                  ),
                  _buildModuleButton(
                    context,
                    'Sessões',
                    Icons.event_note,
                    '/sessoes',
                  ),
                  _buildModuleButton(
                    context,
                    'Agenda',
                    Icons.calendar_today,
                    '/agenda',
                  ),
                  _buildModuleButton(
                    context,
                    'Lista de Espera',
                    Icons.queue,
                    '/lista-espera',
                  ),
                  _buildModuleButton(
                    context,
                    'Pagamentos',
                    Icons.payment,
                    '/pagamentos',
                  ),
                  _buildModuleButton(
                    context,
                    'Relatórios',
                    Icons.bar_chart,
                    '/relatorios',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar botões de módulo
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
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
