import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agenda_treinamento/presentation/common_widgets/custom_app_bar.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/pacientes_arquivados_viewmodel.dart';
import 'package:agenda_treinamento/presentation/pacientes/widgets/pacientes_list_page_body.dart';
import 'package:provider/provider.dart';

class PacientesArquivadosPage extends StatefulWidget {
  const PacientesArquivadosPage({super.key});

  @override
  State<PacientesArquivadosPage> createState() => _PacientesArquivadosPageState();
}

class _PacientesArquivadosPageState extends State<PacientesArquivadosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PacientesArquivadosViewModel>(context, listen: false).loadPacientesArquivados();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PacientesArquivadosViewModel>(context, listen: false);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pacientes Arquivados',
        onBackButtonPressed: () => context.go('/pacientes-inativos'),
      ),
      body: PacientesListPageBody(
        pacientesStream: viewModel.pacientesStream,
        onAction: viewModel.reativarPaciente,
        actionIcon: Icons.person_add_alt_1,
        actionTooltip: 'Reativar Paciente',
        confirmationTitle: 'Confirmar Reativação',
        confirmationContent: 'Tem certeza que deseja reativar o paciente',
        emptyListMessage: 'Nenhum paciente arquivado encontrado.',
        successMessage: 'Paciente reativado com sucesso!',
      ),
    );
  }
}
