import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/historico_paciente_viewmodel.dart'; // Será criado em breve
import 'package:provider/provider.dart';

// Tela de Histórico do Paciente
class HistoricoPacientePage extends StatefulWidget {
  final String pacienteId;

  const HistoricoPacientePage({super.key, required this.pacienteId});

  @override
  State<HistoricoPacientePage> createState() => _HistoricoPacientePageState();
}

class _HistoricoPacientePageState extends State<HistoricoPacientePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoricoPacienteViewModel>(
        context,
        listen: false,
      ).loadPacienteAndTreinamentos(widget.pacienteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoricoPacienteViewModel(),
      child: Consumer<HistoricoPacienteViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Histórico de ${viewModel.paciente?.nome ?? 'Paciente'}',
              onBackButtonPressed: () =>
                  context.pop(), // Volta para a tela anterior
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.paciente == null
                ? const Center(child: Text('Paciente não encontrado.'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dados do Paciente:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text('Nome: ${viewModel.paciente!.nome}'),
                                Text(
                                  'Responsável: ${viewModel.paciente!.nomeResponsavel}',
                                ),
                                Text(
                                  'Idade: ${viewModel.paciente!.idade} anos',
                                ),
                                Text(
                                  'Telefone: ${viewModel.paciente!.telefoneResponsavel ?? 'N/A'}',
                                ),
                                Text(
                                  'Email: ${viewModel.paciente!.emailResponsavel ?? 'N/A'}',
                                ),
                                Text(
                                  'Status: ${viewModel.paciente!.status == 'ativo' ? 'Ativo' : 'Inativo'}',
                                ),
                                if (viewModel.paciente!.observacoes != null &&
                                    viewModel.paciente!.observacoes!.isNotEmpty)
                                  Text(
                                    'Observações: ${viewModel.paciente!.observacoes}',
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Histórico de Treinamentos:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        // TODO: Adicionar lógica para exibir treinamentos e sessões
                        if (viewModel.treinamentos.isEmpty)
                          const Text(
                            'Nenhum treinamento encontrado para este paciente.',
                          )
                        else
                          ...viewModel.treinamentos.map((treinamento) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  'Treinamento: ${treinamento.id ?? 'N/A'}',
                                ), // Substituir pelo nome do treinamento
                                subtitle: Text(
                                  'Início: ${treinamento.dataInicio} - Fim: ${treinamento.dataFim}',
                                ), // Exemplo
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sessões:',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                        // TODO: Listar sessões do treinamento aqui
                                        const Text(
                                          'Sessões serão listadas aqui.',
                                        ), // Placeholder
                                        // Exemplo de como adicionar observações para sessões ativas
                                        if (treinamento.status ==
                                            'ativo') // Assumindo que 'ativo' é um status de treinamento
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                            ),
                                            child: TextFormField(
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Adicionar Observações para a Sessão Ativa',
                                                border: OutlineInputBorder(),
                                              ),
                                              maxLines: 2,
                                              // TODO: Lógica para salvar observações da sessão
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
