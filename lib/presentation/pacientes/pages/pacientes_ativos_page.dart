import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/pacientes/widgets/paciente_card.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/pacientes_ativos_viewmodel.dart';
import 'package:provider/provider.dart';

// Esta página exibe a lista de pacientes ativos
class PacientesAtivosPage extends StatefulWidget {
  const PacientesAtivosPage({super.key});

  @override
  State<PacientesAtivosPage> createState() => _PacientesAtivosPageState();
}

class _PacientesAtivosPageState extends State<PacientesAtivosPage> {
  final TextEditingController _searchController = TextEditingController();
  // A variável _filteredPacientes não é mais necessária como estado,
  // a filtragem ocorrerá diretamente nos dados do stream.

  @override
  void initState() {
    super.initState();
    // Carrega os pacientes quando a página é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PacientesAtivosViewModel>(context, listen: false).loadPacientesAtivos();
    });

    // Precisamos acionar uma reconstrução quando a consulta de busca muda
    _searchController.addListener(() {
      setState(() {
        // Aciona uma reconstrução para re-aplicar o filtro nos dados do stream
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PacientesAtivosViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Pacientes Ativos',
          onBackButtonPressed: () => context.go('/home'), // Volta para a tela inicial
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar paciente',
                  hintText: 'Nome, telefone ou e-mail',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: Theme.of(context).textTheme.bodyLarge, // Ajustado para bodyLarge (14.0)
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Reduzido o padding vertical
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribui o espaço igualmente
                children: [
                  Expanded( // Para que o botão ocupe o espaço disponível
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/pacientes-ativos/novo'), // Navega para a tela de novo paciente
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Novo Paciente',
                        style: TextStyle(fontSize: 12), // Mantido 12 para caber
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Ajuste de padding
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Espaçamento entre os botões
                  Expanded( // Para que o botão ocupe o espaço disponível
                    child: TextButton(
                      onPressed: () => context.go('/pacientes-inativos'), // Navega para pacientes inativos
                      child: const Text(
                        'Ver Pacientes Inativos',
                        style: TextStyle(fontSize: 12), // Mantido 12 para caber
                        textAlign: TextAlign.center,
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Ajuste de padding
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<PacientesAtivosViewModel>(
                builder: (context, viewModel, child) {
                  return StreamBuilder<List<Paciente>>(
                    stream: viewModel.pacientesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erro ao carregar pacientes: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Nenhum paciente ativo encontrado.', style: Theme.of(context).textTheme.bodyMedium));
                      }

                      // Aplica filtro e ordena diretamente nos dados do stream
                      List<Paciente> currentPacientes = snapshot.data!;
                      final String query = _searchController.text.toLowerCase();

                      if (query.isNotEmpty) {
                        currentPacientes = currentPacientes
                            .where((paciente) =>
                                paciente.nome.toLowerCase().contains(query) ||
                                (paciente.telefoneResponsavel?.toLowerCase().contains(query) ?? false) ||
                                (paciente.emailResponsavel?.toLowerCase().contains(query) ?? false))
                            .toList();
                      }

                      // Ordena a lista filtrada
                      currentPacientes.sort((a, b) => a.nome.compareTo(b.nome));

                      if (currentPacientes.isEmpty && query.isNotEmpty) {
                        return Center(child: Text('Nenhum paciente encontrado com os critérios de busca.', style: Theme.of(context).textTheme.bodyMedium));
                      } else if (currentPacientes.isEmpty) {
                         return Center(child: Text('Nenhum paciente ativo encontrado.', style: Theme.of(context).textTheme.bodyMedium));
                      }


                      return ListView.builder(
                        itemCount: currentPacientes.length,
                        itemBuilder: (context, index) {
                          final paciente = currentPacientes[index];
                          return PacienteCard(
                            paciente: paciente,
                            onEdit: () {
                              context.push('/pacientes-ativos/editar/${paciente.id}'); // ALTERADO DE .go PARA .push
                            },
                            onAction: () async {
                              final confirm = await _showConfirmationDialog(context,
                                  'Confirmar Inativação', 'Tem certeza que deseja inativar este paciente?');
                              if (confirm == true) {
                                try {
                                  await viewModel.inativarPaciente(paciente.id!);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Paciente inativado com sucesso!')));
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erro ao inativar paciente: $e')));
                                  }
                                }
                              }
                            },
                            actionIcon: Icons.person_off,
                            actionTooltip: 'Inativar Paciente',
                            onTap: () {
                              context.go('/pacientes-ativos/historico/${paciente.id}');
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
