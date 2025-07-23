import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/pacientes_inativos_viewmodel.dart';
import 'package:agendanova/presentation/pacientes/widgets/pacientes_list_page_body.dart';
import 'package:provider/provider.dart';

class PacientesInativosPage extends StatefulWidget {
  const PacientesInativosPage({super.key});

  @override
  State<PacientesInativosPage> createState() => _PacientesInativosPageState();
}

class _PacientesInativosPageState extends State<PacientesInativosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PacientesInativosViewModel>(context, listen: false).loadPacientesInativos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PacientesInativosViewModel>(context, listen: false);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pacientes Inativos',
        onBackButtonPressed: () => context.go('/pacientes-ativos'),
      ),
      body: PacientesListPageBody(
        pacientesStream: viewModel.pacientesStream,
        onAction: viewModel.reativarPaciente,
        actionIcon: Icons.person_add_alt_1,
        actionTooltip: 'Reativar Paciente',
        confirmationTitle: 'Confirmar Reativação',
        confirmationContent: 'Tem certeza que deseja reativar o paciente',
        emptyListMessage: 'Nenhum paciente inativo encontrado.',
        successMessage: 'Paciente reativado com sucesso!',
      ),
    );
  }
}