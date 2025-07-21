// lib/presentation/pacientes/pages/pacientes_inativos_page.dart
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PacientesInativosViewModel>(context, listen: false).loadPacientesInativos();
    });

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // O ChangeNotifierProvider foi removido daqui
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pacientes Inativos',
        onBackButtonPressed: () => context.go('/pacientes-ativos'),
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
              style: Theme.of(context).textTheme.bodyLarge,
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
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Nenhum paciente inativo encontrado.', style: Theme.of(context).textTheme.bodyMedium));
                    }

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

                    currentPacientes.sort((a, b) => a.nome.compareTo(b.nome));

                    if (currentPacientes.isEmpty && query.isNotEmpty) {
                      return Center(child: Text('Nenhum paciente encontrado com os critérios de busca.', style: Theme.of(context).textTheme.bodyMedium));
                    } else if (currentPacientes.isEmpty) {
                      return Center(child: Text('Nenhum paciente inativo encontrado.', style: Theme.of(context).textTheme.bodyMedium));
                    }

                    return ListView.builder(
                      itemCount: currentPacientes.length,
                      itemBuilder: (context, index) {
                        final paciente = currentPacientes[index];
                        return PacienteCard(
                          paciente: paciente,
                          onEdit: () {
                            context.push('/pacientes-ativos/editar/${paciente.id}');
                          },
                          onAction: () async {
                            final confirm = await _showConfirmationDialog(context,
                                'Confirmar Reativação', 'Tem certeza que deseja reativar este paciente?');
                            if (confirm == true) {
                              try {
                                await viewModel.reativarPaciente(paciente.id!);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Paciente reativado com sucesso!')));
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro ao reativar paciente: $e')));
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