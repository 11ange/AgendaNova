import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/pacientes/widgets/paciente_card.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/pacientes_inativos_viewmodel.dart'; // Será criado em breve
import 'package:provider/provider.dart';

// Esta página exibe a lista de pacientes inativos
class PacientesInativosPage extends StatefulWidget {
  const PacientesInativosPage({super.key});

  @override
  State<PacientesInativosPage> createState() => _PacientesInativosPageState();
}

class _PacientesInativosPageState extends State<PacientesInativosPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Paciente> _filteredPacientes = [];

  @override
  void initState() {
    super.initState();
    // Inicializa o ViewModel e escuta as mudanças
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PacientesInativosViewModel>(context, listen: false);
      viewModel.loadPacientesInativos();
      viewModel.pacientesStream.listen((pacientes) {
        setState(() {
          _filteredPacientes = pacientes;
          _applyFilter(_searchController.text); // Aplica o filtro inicial
        });
      });
    });

    _searchController.addListener(() {
      _applyFilter(_searchController.text);
    });
  }

  void _applyFilter(String query) {
    final viewModel = Provider.of<PacientesInativosViewModel>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        _filteredPacientes = viewModel.pacientes;
      });
    } else {
      setState(() {
        _filteredPacientes = viewModel.pacientes
            .where((paciente) =>
                paciente.nome.toLowerCase().contains(query.toLowerCase()) ||
                (paciente.telefoneResponsavel?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (paciente.emailResponsavel?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      });
    }
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
                        return const Center(child: Text('Nenhum paciente inativo encontrado.'));
                      }

                      // Ordena os pacientes por nome em ordem alfabética
                      final sortedPacientes = _filteredPacientes..sort((a, b) => a.nome.compareTo(b.nome));

                      return ListView.builder(
                        itemCount: sortedPacientes.length,
                        itemBuilder: (context, index) {
                          final paciente = sortedPacientes[index];
                          return PacienteCard(
                            paciente: paciente,
                            onEdit: () {
                              context.go('/pacientes-ativos/editar/${paciente.id}'); // Reutiliza a tela de edição
                            },
                            onInactivate: () async {
                              // Ação de reativar paciente
                              final confirm = await _showConfirmationDialog(context,
                                  'Confirmar Reativação', 'Tem certeza que deseja reativar este paciente?');
                              if (confirm == true) {
                                try {
                                  await viewModel.reativarPaciente(paciente.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Paciente reativado com sucesso!')));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro ao reativar paciente: $e')));
                                }
                              }
                            },
                            onTap: () {
                              context.go('/pacientes-ativos/historico/${paciente.id}'); // Navega para o histórico
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

