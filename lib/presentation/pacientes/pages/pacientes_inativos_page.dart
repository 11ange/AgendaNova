import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/pacientes/widgets/paciente_card.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/pacientes_inativos_viewmodel.dart';
import 'package:provider/provider.dart';

// Esta página exibe a lista de pacientes inativos
class PacientesInativosPage extends StatefulWidget {
  const PacientesInativosPage({super.key});

  @override
  State<PacientesInativosPage> createState() => _PacientesInativosPageState();
}

class _PacientesInativosPageState extends State<PacientesInativosPage> {
  final TextEditingController _searchController = TextEditingController();
  // A variável _filteredPacientes não é mais necessária como estado,
  // a filtragem ocorrerá diretamente nos dados do stream.

  @override
  void initState() {
    super.initState();
    // Carrega os pacientes quando a página é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PacientesInativosViewModel>(context, listen: false).loadPacientesInativos();
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
      create: (_) => PacientesInativosViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Pacientes Inativos',
          onBackButtonPressed: () => context.go('/pacientes-ativos'), // Volta para a tela de pacientes ativos
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
            Expanded(
              child: Consumer<PacientesInativosViewModel>(
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
                      // Se não houver dados, exibe a mensagem inicial
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Nenhum paciente inativo encontrado.', style: Theme.of(context).textTheme.bodyMedium));
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

                      // Se a lista filtrada estiver vazia (após a busca)
                      if (currentPacientes.isEmpty && query.isNotEmpty) {
                        return Center(child: Text('Nenhum paciente encontrado com os critérios de busca.', style: Theme.of(context).textTheme.bodyMedium));
                      } else if (currentPacientes.isEmpty) {
                        // Isso só deve acontecer se snapshot.data!.isEmpty for true,
                        // mas é uma salvaguarda.
                        return Center(child: Text('Nenhum paciente inativo encontrado.', style: Theme.of(context).textTheme.bodyMedium));
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
                                  'Confirmar Reativação', 'Tem certeza que deseja reativar este paciente?');
                              if (confirm == true) {
                                try {
                                  await viewModel.reativarPaciente(paciente.id!);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Paciente reativado com sucesso!')));
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erro ao reativar paciente: $e')));
                                  }
                                }
                              }
                            },
                            actionIcon: Icons.person_add_alt_1,
                            actionTooltip: 'Reativar Paciente',
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
