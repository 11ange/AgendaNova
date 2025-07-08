import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/pacientes/widgets/paciente_card.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/pacientes_ativos_viewmodel.dart';
import 'package:provider/provider.dart';

class PacientesAtivosPage extends StatefulWidget {
  const PacientesAtivosPage({super.key});

  @override
  State<PacientesAtivosPage> createState() => _PacientesAtivosPageState();
}

class _PacientesAtivosPageState extends State<PacientesAtivosPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PacientesAtivosViewModel>(context, listen: false).loadPacientesAtivos();
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
    return ChangeNotifierProvider(
      create: (_) => PacientesAtivosViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Pacientes Ativos',
          onBackButtonPressed: () => context.go('/home'),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/pacientes-ativos/novo'),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Novo Paciente',
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    // --- AJUSTE: Alterado para ElevatedButton para ter cor de fundo ---
                    child: ElevatedButton(
                      onPressed: () => context.go('/pacientes-inativos'),
                      style: ElevatedButton.styleFrom(
                        // Define a cor de fundo cinza claro e a cor do texto
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                      child: const Text(
                        'Ver Pacientes Inativos',
                        textAlign: TextAlign.center,
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

                      if (currentPacientes.isEmpty) {
                        return Center(child: Text('Nenhum paciente encontrado com os critérios de busca.', style: Theme.of(context).textTheme.bodyMedium));
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