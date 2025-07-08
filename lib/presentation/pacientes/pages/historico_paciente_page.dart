import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/historico_paciente_viewmodel.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/core/utils/date_formatter.dart';
import 'package:agendanova/domain/entities/treinamento.dart';

class HistoricoPacientePage extends StatelessWidget {
  final String pacienteId;

  const HistoricoPacientePage({super.key, required this.pacienteId});

  // Função auxiliar para construir o texto de pagamento
  String _buildPagamentoText(Treinamento treinamento) {
    String texto = 'Pagamento: ${treinamento.formaPagamento}';
    if (treinamento.formaPagamento == 'Convenio') {
      if (treinamento.nomeConvenio != null && treinamento.nomeConvenio!.isNotEmpty) {
        texto += ' (${treinamento.nomeConvenio})';
      }
    } else if (treinamento.tipoParcelamento != null) {
      texto += ' (${treinamento.tipoParcelamento})';
    }
    return texto;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoricoPacienteViewModel>(
      create: (_) => GetIt.instance<HistoricoPacienteViewModel>()..loadHistorico(pacienteId),
      child: Consumer<HistoricoPacienteViewModel>(
        builder: (context, viewModel, child) {
          final pacienteNome = viewModel.paciente?.nome;

          return Scaffold(
            appBar: CustomAppBar(
              title: 'Histórico de ${pacienteNome ?? '...'}',
              onBackButtonPressed: () => context.canPop() ? context.pop() : context.go('/pacientes-ativos'),
            ),
            body: Builder(
              builder: (context) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return Center(child: Text(viewModel.errorMessage!));
                }

                if (viewModel.treinamentos.isEmpty) {
                  return const Center(child: Text('Nenhum treinamento encontrado para este paciente.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: viewModel.treinamentos.length,
                  itemBuilder: (context, index) {
                    final treinamento = viewModel.treinamentos[index];
                    final sessoes = viewModel.sessoesPorTreinamento[treinamento.id] ?? [];
                    final sessoesRealizadas = sessoes.where((s) => s.status == 'Realizada').length;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      child: ExpansionTile(
                        title: Text('Início: ${DateFormatter.formatDate(treinamento.dataInicio)} às ${treinamento.horario}'),
                        // --- AJUSTE AQUI: O subtítulo agora é uma Coluna ---
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2), // Pequeno espaçamento
                            Text('${treinamento.status.toUpperCase()} | $sessoesRealizadas de ${treinamento.numeroSessoesTotal} sessões realizadas'),
                            const SizedBox(height: 4),
                            Text(
                              _buildPagamentoText(treinamento),
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha((0.9 * 255).toInt()),
                              ),
                            ),
                          ],
                        ),
                        children: sessoes.isEmpty
                            ? [const ListTile(title: Text('Nenhuma sessão encontrada para este treinamento.'))]
                            : sessoes.map((sessao) {
                                return ListTile(
                                  title: Text('Sessão #${sessao.numeroSessao} - ${DateFormatter.formatDate(sessao.dataHora)} às ${DateFormat.Hm().format(sessao.dataHora)}'),
                                  subtitle: Text('Status: ${sessao.status} | Pagamento: ${sessao.statusPagamento}'),
                                  dense: true,
                                );
                              }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}