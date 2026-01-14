// lib/presentation/pacientes/pages/historico_paciente_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/historico_paciente_viewmodel.dart';
import 'package:agenda_treinamento/presentation/common_widgets/custom_app_bar.dart';
import 'package:agenda_treinamento/core/utils/date_formatter.dart';
import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/domain/entities/pagamento.dart';
import 'package:agenda_treinamento/data/models/pagamento_model.dart';

class HistoricoPacientePage extends StatelessWidget {
  final String pacienteId;

  const HistoricoPacientePage({super.key, required this.pacienteId});

  String _buildPagamentoText(Treinamento treinamento) {
    String texto = 'Pagamento: ${treinamento.formaPagamento}';
    if (treinamento.formaPagamento == 'Convenio') {
      if (treinamento.nomeConvenio != null &&
          treinamento.nomeConvenio!.isNotEmpty) {
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
      create: (_) =>
          GetIt.instance<HistoricoPacienteViewModel>()
            ..loadHistorico(pacienteId),
      child: Consumer<HistoricoPacienteViewModel>(
        builder: (context, viewModel, child) {
          final pacienteNome = viewModel.paciente?.nome;

          return Scaffold(
            appBar: CustomAppBar(
              title: 'Histórico de ${pacienteNome ?? '...'}',
              onBackButtonPressed: () => context.canPop()
                  ? context.pop()
                  : context.go('/pacientes-ativos'),
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
                  return const Center(
                    child: Text(
                      'Nenhum treinamento encontrado para este paciente.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: viewModel.treinamentos.length,
                  itemBuilder: (context, index) {
                    final treinamento = viewModel.treinamentos[index];
                    final sessoes =
                        viewModel.sessoesPorTreinamento[treinamento.id] ?? [];
                    final pagamentos =
                        viewModel.pagamentosPorTreinamento[treinamento.id] ??
                        [];
                    final sessoesRealizadas = sessoes
                        .where((s) => s.status == 'Realizada')
                        .length;

                    return Card(
                      color: treinamento.status == 'Finalizado'
                          ? Colors.red.shade50
                          : null,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      child: ExpansionTile(
                        title: Text(
                          'Início: ${DateFormatter.formatDate(treinamento.dataInicio)} às ${treinamento.horario}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              '${treinamento.status.toUpperCase()} | $sessoesRealizadas de ${treinamento.numeroSessoesTotal} sessões realizadas',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _buildPagamentoText(treinamento),
                              style: TextStyle(
                                fontSize: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.fontSize,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withAlpha((0.9 * 255).toInt()),
                              ),
                            ),
                            // Mostra os detalhes de pagamento diretamente no subtítulo
                            _buildPagamentoSubtitle(
                              context,
                              treinamento,
                              pagamentos,
                            ),
                          ],
                        ),
                        children: sessoes.isEmpty
                            ? [
                                const ListTile(
                                  title: Text(
                                    'Nenhuma sessão encontrada para este treinamento.',
                                  ),
                                ),
                              ]
                            : sessoes.map((sessao) {
                                String pagamentoInfo = '';
                                // Remove a informação de pagamento da sessão para Convenio e 3x
                                if (treinamento.formaPagamento != 'Convenio' &&
                                    treinamento.tipoParcelamento != '3x') {
                                  if (sessao.status == 'Bloqueada') {
                                    // Se a sessão está bloqueada, o pagamento não se aplica
                                    pagamentoInfo = ' | Pagamento: N/A';
                                  } else if (sessao.statusPagamento ==
                                          'Realizado' &&
                                      sessao.dataPagamento != null) {
                                    pagamentoInfo =
                                        ' | Pagamento em ${DateFormatter.formatDate(sessao.dataPagamento!)}';
                                  } else {
                                    pagamentoInfo =
                                        ' | Pagamento: ${sessao.statusPagamento}';
                                  }
                                }

                                return ListTile(
                                  title: Text(
                                    'Sessão #${sessao.numeroSessao} - ${DateFormatter.formatDate(sessao.dataHora)} às ${DateFormat.Hm().format(sessao.dataHora)}',
                                  ),
                                  subtitle: Text(
                                    'Status: ${sessao.status}$pagamentoInfo',
                                  ),
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

  // Widget para construir os subtítulos de pagamento
  Widget _buildPagamentoSubtitle(
    BuildContext context,
    Treinamento treinamento,
    List<Pagamento> pagamentos,
  ) {
    final textStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
      color: Theme.of(
        context,
      ).textTheme.bodyMedium?.color?.withAlpha((0.9 * 255).toInt()),
      fontWeight: FontWeight.bold,
    );

    // Lógica para Convênio
    if (treinamento.formaPagamento == 'Convenio') {
      final pagamentoConvenio = pagamentos.isNotEmpty ? pagamentos.first : null;
      final bool isPago =
          (pagamentoConvenio != null &&
          pagamentoConvenio.status == 'Realizado' &&
          pagamentoConvenio.dataEnvioGuia != null);
      final String statusText = isPago
          ? 'Guia enviada em ${DateFormatter.formatDate(pagamentoConvenio.dataEnvioGuia!)}'
          : 'Pagamento: Pendente';
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          statusText,
          style: textStyle.copyWith(
            color: isPago ? Colors.green : Colors.orange,
          ),
        ),
      );
    }

    // Lógica para 3x
    if (treinamento.tipoParcelamento == '3x') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(3, (index) {
          final parcelaNum = index + 1;
          final pagamentoDaParcela = pagamentos.firstWhere(
            (p) => p.parcelaNumero == parcelaNum,
            orElse: () => PagamentoModel(
              treinamentoId: treinamento.id!,
              pacienteId: treinamento.pacienteId,
              formaPagamento: treinamento.formaPagamento,
              status: 'Pendente',
              dataPagamento: DateTime.now(),
              parcelaNumero: parcelaNum,
              totalParcelas: 3,
            ),
          );
          final bool isPaga = pagamentoDaParcela.status == 'Realizado';
          final String statusText = isPaga
              ? 'Paga em ${DateFormatter.formatDate(pagamentoDaParcela.dataPagamento)}'
              : 'Pendente';

          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '$parcelaNumª Parcela: $statusText',
              style: textStyle.copyWith(
                color: isPaga ? Colors.green : Colors.orange,
              ),
            ),
          );
        }),
      );
    }

    return const SizedBox.shrink(); // Retorna nada para outros tipos de pagamento
  }
}
