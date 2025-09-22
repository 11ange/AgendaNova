// lib/presentation/pagamentos/pages/pagamentos_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:agenda_treinamento/presentation/pagamentos/viewmodels/pagamentos_viewmodel.dart';
import 'package:agenda_treinamento/presentation/common_widgets/custom_app_bar.dart';
import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/domain/entities/pagamento.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/core/utils/date_formatter.dart';
import 'package:agenda_treinamento/data/models/pagamento_model.dart';

class PagamentosPage extends StatelessWidget {
  const PagamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium;

    return ChangeNotifierProvider(
      create: (_) => PagamentosViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Controle de Pagamentos',
          onBackButtonPressed: () => context.go('/home'),
        ),
        body: Consumer<PagamentosViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.treinamentosAtivos.isEmpty) {
              return const Center(child: Text('Nenhum treinamento ativo ou com pagamento pendente encontrado.'));
            }

            return ListView.builder(
              itemCount: viewModel.treinamentosAtivos.length,
              itemBuilder: (context, index) {
                final treinamento = viewModel.treinamentosAtivos[index];
                final paciente = viewModel.getPacienteById(treinamento.pacienteId);
                final pagamentos = viewModel.pagamentosPorTreinamento[treinamento.id] ?? [];

                final String statusGeral;
                final Color statusColor;

                if (treinamento.formaPagamento == 'Convenio') {
                  final bool isPago = pagamentos.any((p) => p.status == 'Realizado' && p.dataEnvioGuia != null);
                  statusGeral = isPago ? 'Liquidado' : 'Pendente';
                  statusColor = isPago ? Colors.green : Colors.red;
                } else if (treinamento.tipoParcelamento == '3x') {
                  final parcelasPagas = pagamentos.where((p) => p.status == 'Realizado').length;
                  if (parcelasPagas == 3) {
                    statusGeral = 'Liquidado';
                    statusColor = Colors.green;
                  } else if (parcelasPagas > 0) {
                    statusGeral = 'Parcial';
                    statusColor = Colors.orange;
                  } else {
                    statusGeral = 'Pendente';
                    statusColor = Colors.red;
                  }
                } else {
                   final bool isPago = pagamentos.any((p) => p.status == 'Realizado');
                   statusGeral = isPago ? 'Liquidado' : 'Pendente';
                   statusColor = isPago ? Colors.green : Colors.red;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(paciente?.nome ?? 'Paciente não encontrado', style: titleStyle),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormatter.formatDate(treinamento.dataInicio)} - ${DateFormatter.formatDate(treinamento.dataFimPrevista)} às ${treinamento.horario}',
                          style: subtitleStyle,
                        ),
                        Text(
                          'Pagamento: ${treinamento.formaPagamento}${treinamento.tipoParcelamento != null ? ' (${treinamento.tipoParcelamento})' : ''}',
                          style: subtitleStyle,
                        ),
                      ],
                    ),
                    trailing: Text(
                      statusGeral,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: _buildPagamentoDetails(context, viewModel, treinamento, pagamentos),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPagamentoDetails(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, List<Pagamento> pagamentos) {
    if (treinamento.formaPagamento == 'Convenio') {
      return _buildConvenioDetails(context, viewModel, treinamento, pagamentos.firstOrNull);
    } else if (treinamento.tipoParcelamento == '3x') {
      return _buildParceladoDetails(context, viewModel, treinamento, pagamentos);
    } else if (treinamento.tipoParcelamento == 'Por sessão') {
      final sessoes = viewModel.sessoesPorTreinamento[treinamento.id] ?? [];
      return _buildPorSessaoDetails(context, viewModel, treinamento, sessoes);
    }
    return const SizedBox.shrink();
  }

  Widget _buildConvenioDetails(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, Pagamento? pagamento) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final bool guiaEnviada = pagamento?.dataEnvioGuia != null;
    final bool pagamentoRecebido = pagamento?.dataRecebimentoConvenio != null;

    return Column(
      children: [
        ListTile(
          dense: true,
          title: Text('Envio da Guia', style: textStyle),
          trailing: Text(
            guiaEnviada ? DateFormatter.formatDate(pagamento!.dataEnvioGuia!) : 'Pendente',
            style: textStyle?.copyWith(
              color: guiaEnviada ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => _showConvenioEnvioDialog(context, viewModel, treinamento, pagamento),
        ),
        ListTile(
          dense: true,
          title: Text('Pagamento do Convênio', style: textStyle),
          trailing: Text(
            pagamentoRecebido ? DateFormatter.formatDate(pagamento!.dataRecebimentoConvenio!) : 'Pendente',
            style: textStyle?.copyWith(
              color: pagamentoRecebido ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: guiaEnviada 
            ? () => _showConvenioRecebimentoDialog(context, viewModel, treinamento, pagamento) 
            : null,
        ),
      ],
    );
  }

  Widget _buildParceladoDetails(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, List<Pagamento> pagamentos) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(3, (index) {
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
                totalParcelas: 3),
          );

          final bool isPaga = pagamentoDaParcela.status == 'Realizado';

          return ListTile(
            dense: true,
            title: Text('$parcelaNumª Parcela', style: textStyle),
            trailing: Text(
              isPaga ? 'Pago - ${DateFormatter.formatDate(pagamentoDaParcela.dataPagamento)}' : 'Pendente',
              style: textStyle?.copyWith(
                color: isPaga ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showParcelaDateEntryDialog(context, viewModel, treinamento, pagamentoDaParcela),
          );
        }),
      ],
    );
  }

  Future<void> _showConvenioEnvioDialog(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, Pagamento? pagamento) async {
    final dataEnvioController = TextEditingController();
    DateTime? dataSelecionada = pagamento?.dataEnvioGuia ?? DateTime.now();
    dataEnvioController.text = DateFormatter.formatDate(dataSelecionada);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Envio da Guia do Convênio'),
              content: GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dataSelecionada ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      dataSelecionada = picked;
                      dataEnvioController.text = DateFormatter.formatDate(picked);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dataEnvioController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Envio',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Fechar')),
                if (pagamento?.dataEnvioGuia != null) ...[
                  TextButton(
                    onPressed: () async {
                      try {
                        await viewModel.reverterPagamentoConvenio(treinamento.id!);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                      } catch (e) {
                         ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Erro: $e')));
                      }
                    },
                    child: const Text('Reverter Envio', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // --- CORREÇÃO APLICADA AQUI ---
                        await viewModel.updateDataEnvioGuiaConvenio(treinamento.id!, dataSelecionada!);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                      } catch (e) {
                         ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Erro: $e')));
                      }
                    },
                    child: const Text('Atualizar Data'),
                  )
                ] else ...[
                  ElevatedButton(
                    onPressed: () async {
                       try {
                        await viewModel.confirmarPagamentoConvenio(treinamento, dataSelecionada!);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                      } catch (e) {
                         ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Erro: $e')));
                      }
                    },
                    child: const Text('Confirmar Envio'),
                  )
                ]
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showConvenioRecebimentoDialog(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, Pagamento? pagamento) async {
    final dataRecebimentoController = TextEditingController();
    DateTime? dataSelecionada = pagamento?.dataRecebimentoConvenio ?? DateTime.now();
    dataRecebimentoController.text = DateFormatter.formatDate(dataSelecionada);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pagamento do Convênio'),
              content: GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dataSelecionada ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      dataSelecionada = picked;
                      dataRecebimentoController.text = DateFormatter.formatDate(picked);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dataRecebimentoController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Pagamento',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Fechar')),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await viewModel.confirmarRecebimentoConvenio(treinamento.id!, dataSelecionada!);
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Erro: $e')));
                    }
                  },
                  child: Text(pagamento?.dataRecebimentoConvenio != null ? 'Atualizar Data' : 'Confirmar Pagamento'),
                )
              ],
            );
          },
        );
      },
    );
  }

   Future<void> _showParcelaDateEntryDialog(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, Pagamento parcela) async {
    final dataPagamentoController = TextEditingController();
    DateTime? dataPagamentoSelecionada = parcela.status == 'Realizado' ? parcela.dataPagamento : DateTime.now();
    dataPagamentoController.text = DateFormatter.formatDate(dataPagamentoSelecionada);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pagamento da ${parcela.parcelaNumero}ª Parcela'),
              content: GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dataPagamentoSelecionada ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      dataPagamentoSelecionada = picked;
                      dataPagamentoController.text = DateFormatter.formatDate(picked);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dataPagamentoController,
                    decoration: const InputDecoration(
                      labelText: 'Data do Pagamento',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Fechar')),
                if (parcela.status == 'Realizado') ...[
                  TextButton(
                    onPressed: () async {
                      try {
                        await viewModel.reverterPagamentoParcela(treinamento.id!, parcela.parcelaNumero!);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                      } catch (e) {
                         ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Erro: $e')));
                      }
                    },
                    child: const Text('Reverter Pagamento', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await viewModel.updateDataPagamentoParcela(treinamento.id!, parcela.parcelaNumero!, dataPagamentoSelecionada!);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                      } catch (e) {
                         ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Erro: $e')));
                      }
                    },
                    child: const Text('Atualizar Data'),
                  )
                ] else ...[
                  ElevatedButton(
                    onPressed: () async {
                       try {
                        await viewModel.confirmarPagamentoParcela(treinamento, parcela.parcelaNumero!, dataPagamentoSelecionada!);
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                      } catch (e) {
                         ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Erro: $e')));
                      }
                    },
                    child: const Text('Confirmar'),
                  )
                ]
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPorSessaoDetails(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, List<Sessao> sessoes) {
    if (sessoes.isEmpty) return const Center(child: Text('Nenhuma sessão encontrada.'));
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sessoes.map((sessao) {
          final bool pago = sessao.statusPagamento == 'Realizado';
          return ListTile(
            dense: true,
            title: Text('Sessão #${sessao.numeroSessao} - ${DateFormatter.formatDate(sessao.dataHora)}', style: textStyle),
            trailing: Text(
              sessao.statusPagamento,
              style: textStyle?.copyWith(color: pago ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
            ),
          );
        }),
      ],
    );
  }
}