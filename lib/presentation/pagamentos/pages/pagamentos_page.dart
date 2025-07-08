import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agendanova/presentation/pagamentos/viewmodels/pagamentos_viewmodel.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/domain/entities/treinamento.dart';
import 'package:agendanova/domain/entities/pagamento.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/core/utils/date_formatter.dart';

class PagamentosPage extends StatelessWidget {
  const PagamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              return const Center(child: Text('Nenhum treinamento ativo encontrado.'));
            }

            return ListView.builder(
              itemCount: viewModel.treinamentosAtivos.length,
              itemBuilder: (context, index) {
                final treinamento = viewModel.treinamentosAtivos[index];
                final paciente = viewModel.getPacienteById(treinamento.pacienteId);
                final pagamentos = viewModel.pagamentosPorTreinamento[treinamento.id] ?? [];
                
                // Lógica para determinar o status geral do pagamento
                final bool isPago = pagamentos.any((p) => p.status == 'Realizado');
                final String statusGeral = isPago ? 'Concluído' : 'Pendente';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(paciente?.nome ?? 'Paciente não encontrado'),
                    // --- AJUSTE 1: Subtítulo agora é a forma de pagamento ---
                    subtitle: Text('Pagamento: ${treinamento.formaPagamento}'),
                    // --- AJUSTE 2: Trailing adicionado para exibir o status ---
                    trailing: Chip(
                      label: Text(
                        statusGeral,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: isPago ? Colors.green : Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
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
    return const Text('Forma de pagamento não especificada.');
  }

  // --- WIDGETS PARA CADA TIPO DE PAGAMENTO ---

  Widget _buildConvenioDetails(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, Pagamento? pagamento) {
    final bool pago = pagamento?.status == 'Realizado';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalhes do Convênio: ${treinamento.nomeConvenio ?? ''}', style: Theme.of(context).textTheme.titleMedium),
        const Divider(height: 20),
        if (pagamento != null) ...[
          Text('Guia: ${pagamento.guiaConvenio ?? 'Não informada'}'),
          Text('Data de Envio: ${pagamento.dataEnvioGuia != null ? DateFormatter.formatDate(pagamento.dataEnvioGuia!) : 'Não informada'}'),
          const SizedBox(height: 8),
          Text(
            'Status do Pagamento: ${pagamento.status}',
            style: TextStyle(fontWeight: FontWeight.bold, color: pago ? Colors.green : Colors.orange),
          ),
          if (pago) Text('Confirmado em: ${DateFormatter.formatDate(pagamento.dataPagamento)}')
        ] else ...[
          const Text('Nenhum registro de pagamento de convênio encontrado.'),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () { /* Lógica do Pop-up para confirmar/editar dados do convênio */ },
            icon: Icon(pago ? Icons.check_circle : Icons.payment),
            label: Text(pago ? 'Pagamento Confirmado' : 'Confirmar Pagamento'),
            style: ElevatedButton.styleFrom(backgroundColor: pago ? Colors.green : Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildParceladoDetails(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, List<Pagamento> pagamentos) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pagamento Parcelado em 3x', style: Theme.of(context).textTheme.titleMedium),
        const Divider(height: 20),
        // Lógica para exibir as 3 parcelas aqui
        const Text('Visualização de parcelas em desenvolvimento.'),
        // TODO: Implementar a lista de parcelas com botões de confirmação
      ],
    );
  }

  Widget _buildPorSessaoDetails(BuildContext context, PagamentosViewModel viewModel, Treinamento treinamento, List<Sessao> sessoes) {
    if (sessoes.isEmpty) return const Center(child: Text('Nenhuma sessão encontrada.'));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pagamento por Sessão', style: Theme.of(context).textTheme.titleMedium),
        const Divider(height: 20),
        ...sessoes.map((sessao) {
          final bool pago = sessao.statusPagamento == 'Realizado';
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text('Sessão #${sessao.numeroSessao} - ${DateFormatter.formatDate(sessao.dataHora)}'),
              subtitle: Text(sessao.status),
              trailing: Text(
                sessao.statusPagamento,
                style: TextStyle(color: pago ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}