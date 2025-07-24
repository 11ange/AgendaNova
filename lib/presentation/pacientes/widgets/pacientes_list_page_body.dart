// lib/presentation/pacientes/widgets/pacientes_list_page_body.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/presentation/pacientes/widgets/paciente_card.dart';
import 'package:agenda_treinamento/core/utils/snackbar_helper.dart';

class PacientesListPageBody extends StatefulWidget {
  final Stream<List<Paciente>> pacientesStream;
  final Function(String) onAction;
  final String actionTooltip;
  final IconData actionIcon;
  final String confirmationTitle;
  final String confirmationContent;
  final String emptyListMessage;
  final String successMessage;

  const PacientesListPageBody({
    super.key,
    required this.pacientesStream,
    required this.onAction,
    required this.actionTooltip,
    required this.actionIcon,
    required this.confirmationTitle,
    required this.confirmationContent,
    required this.emptyListMessage,
    required this.successMessage,
  });

  @override
  State<PacientesListPageBody> createState() => _PacientesListPageBodyState();
}

class _PacientesListPageBodyState extends State<PacientesListPageBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    return Column(
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
          child: StreamBuilder<List<Paciente>>(
            stream: widget.pacientesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erro ao carregar pacientes: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text(widget.emptyListMessage, style: Theme.of(context).textTheme.bodyMedium));
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
                      // **A CORREÇÃO DEFINITIVA ESTÁ AQUI**
                      // Capturamos a referência ao ScaffoldMessenger ANTES de qualquer `await`.
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      final confirm = await _showConfirmationDialog(context,
                          widget.confirmationTitle, '${widget.confirmationContent} ${paciente.nome}?');
                      
                      if (confirm == true) {
                        try {
                          await widget.onAction(paciente.id!);
                          
                          // Usamos a referência `scaffoldMessenger` que ainda é válida,
                          // mesmo que o widget original tenha desaparecido da tela.
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(widget.successMessage),
                              backgroundColor: Colors.green[700],
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          // O mesmo se aplica ao tratamento de erros.
                          final errorMessage = SnackBarHelper.parseErrorMessage(e);
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red[700],
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    },
                    actionIcon: widget.actionIcon,
                    actionTooltip: widget.actionTooltip,
                    onTap: () {
                      context.go('/pacientes-ativos/historico/${paciente.id}');
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}