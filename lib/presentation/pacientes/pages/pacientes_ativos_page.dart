import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agenda_treinamento/presentation/common_widgets/custom_app_bar.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/pacientes_ativos_viewmodel.dart';
import 'package:agenda_treinamento/presentation/pacientes/widgets/pacientes_list_page_body.dart';
import 'package:provider/provider.dart';

class PacientesAtivosPage extends StatefulWidget {
  const PacientesAtivosPage({super.key});

  @override
  State<PacientesAtivosPage> createState() => _PacientesAtivosPageState();
}

class _PacientesAtivosPageState extends State<PacientesAtivosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PacientesAtivosViewModel>(context, listen: false).loadPacientesAtivos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PacientesAtivosViewModel>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pacientes Ativos',
        onBackButtonPressed: () => context.go('/home'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  child: ElevatedButton(
                    onPressed: () => context.go('/pacientes-inativos'),
                    style: ElevatedButton.styleFrom(
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
            child: PacientesListPageBody(
              pacientesStream: viewModel.pacientesStream,
              onAction: viewModel.inativarPaciente,
              actionIcon: Icons.person_off,
              actionTooltip: 'Inativar Paciente',
              confirmationTitle: 'Confirmar Inativação',
              confirmationContent: 'Tem certeza que deseja inativar o paciente',
              emptyListMessage: 'Nenhum paciente ativo encontrado.',
              successMessage: 'Paciente inativado com sucesso!',
            ),
          ),
        ],
      ),
    );
  }
}