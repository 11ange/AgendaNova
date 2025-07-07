import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/historico_paciente_viewmodel.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/core/utils/date_formatter.dart';
import 'package:agendanova/domain/entities/treinamento.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/entities/paciente.dart';

class HistoricoPacientePage extends StatefulWidget {
  final String pacienteId;

  const HistoricoPacientePage({super.key, required this.pacienteId});

  @override
  State<HistoricoPacientePage> createState() => _HistoricoPacientePageState();
}

class _HistoricoPacientePageState extends State<HistoricoPacientePage> {
  // O ViewModel é instanciado mas não é usado diretamente aqui no State
  @override
  void initState() {
    super.initState();
    // A inicialização dos dados será feita através do Provider no `create`.
  }

  @override
  Widget build(BuildContext context) {
    // --- CORREÇÃO PRINCIPAL AQUI ---
    // O ChangeNotifierProvider agora envolve toda a tela.
    // Usamos `create` para que o Provider gerencie o ciclo de vida do ViewModel.
    // O ViewModel é criado e os dados são carregados uma única vez.
    return ChangeNotifierProvider<HistoricoPacienteViewModel>(
      create: (_) => GetIt.instance<HistoricoPacienteViewModel>()..loadHistorico(widget.pacienteId),
      child: Consumer<HistoricoPacienteViewModel>(
        builder: (context, viewModel, child) {
          // O título da AppBar agora é acessado de forma segura dentro do Consumer.
          final pacienteNome = viewModel.paciente?.nome;

          return Scaffold(
            appBar: CustomAppBar(
              title: 'Histórico de ${pacienteNome ?? '...'}',
              onBackButtonPressed: () => context.canPop() ? context.pop() : context.go('/pacientes-ativos'),
            ),
            body: Builder(
              builder: (context) {
                if (viewModel.isLoading && viewModel.paciente == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.errorMessage != null) {
                  return Center(child: Text(viewModel.errorMessage!));
                }

                if (viewModel.paciente == null) {
                  return const Center(child: Text('Paciente não encontrado.'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (viewModel.treinamentos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Center(child: Text('Nenhum treinamento encontrado para este paciente.')),
                      )
                    else
                      ...viewModel.treinamentos.map((treinamento) {
                        final sessoes = viewModel.sessoesPorTreinamento[treinamento.id] ?? [];
                        final sessoesRealizadas = sessoes.where((s) => s.status == 'Realizada').length;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          child: ExpansionTile(
                            title: Text('Início: ${DateFormatter.formatDate(treinamento.dataInicio)} às ${treinamento.horario}'),
                            subtitle: Text('${treinamento.status.toUpperCase()} | ${sessoesRealizadas} de ${treinamento.numeroSessoesTotal} sessões realizadas'),
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
                      }).toList(),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}