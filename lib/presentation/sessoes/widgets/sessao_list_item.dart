// lib/presentation/sessoes/widgets/sessao_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/core/utils/date_formatter.dart';
import 'package:agenda_treinamento/core/utils/snackbar_helper.dart';
import 'package:agenda_treinamento/presentation/sessoes/pages/sessoes_page.dart';
import 'package:agenda_treinamento/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:agenda_treinamento/presentation/sessoes/widgets/treinamento_form_dialog.dart';

class SessaoListItem extends StatelessWidget {
  final String timeSlot;
  final Sessao? sessao;
  final bool isDailyBlocked;
  final SessoesViewModel viewModel;
  final DateTime selectedDay;

  const SessaoListItem({
    super.key,
    required this.timeSlot,
    this.sessao,
    required this.isDailyBlocked,
    required this.viewModel,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      color: _getCardBackgroundColor(sessao, isDailyBlocked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                timeSlot,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: _buildSessionInfo(context, sessao, isDailyBlocked),
            ),
            if (!isDailyBlocked)
              SizedBox(
                width: 48,
                child: _buildPopupMenuButton(context, viewModel, sessao, timeSlot),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmPaymentDialog(
      BuildContext context, SessoesViewModel viewModel, Sessao sessao) async {
    final formKey = GlobalKey<FormState>();
    final dataPagamentoController = TextEditingController();
    DateTime? dataPagamentoSelecionada = DateTime.now();
    dataPagamentoController.text = DateFormatter.formatDate(dataPagamentoSelecionada);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirmar Pagamento'),
              content: Form(
                key: formKey,
                child: GestureDetector(
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
                        labelText: 'Data do Pagamento *',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma data';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: const Text('Confirmar'),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final navigator = Navigator.of(dialogContext);
                      try {
                        await viewModel.confirmarPagamentoSessao(
                            sessao, dataPagamentoSelecionada!);
                        if (!context.mounted) return;
                        SnackBarHelper.showSuccess(context, 'Pagamento confirmado com sucesso!');
                        navigator.pop();
                      } catch (e) {
                         if (!context.mounted) return;
                         SnackBarHelper.showError(context, e);
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _showCancellationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Cancelamento'),
          content: const Text('Deseja cancelar apenas esta sessão ou esta e todas as futuras (encerrando o treinamento)?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Voltar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Apenas esta'),
            ),
             ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Todas as futuras'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTrocarHorarioDialog(BuildContext context, SessoesViewModel viewModel, Sessao sessao) async {
    // 1. Selecionar a nova data de início
    final DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: sessao.dataHora,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a data da primeira sessão',
    );

    if (novaData == null || !context.mounted) return;

    // 2. Buscar horários disponíveis na agenda para o dia da semana escolhido
    final diaSemana = DateFormatter.getCapitalizedWeekdayName(novaData);
    final agendaMap = viewModel.agendaDisponibilidade?.agenda ?? {};
    final List<String> horariosDisponiveis = List<String>.from(agendaMap[diaSemana] ?? []);

    if (horariosDisponiveis.isEmpty) {
      if (!context.mounted) return;
      SnackBarHelper.showError(context, 'Não existem horários cadastrados na agenda para $diaSemana.');
      return;
    }

    // 3. Selecionar o horário
    if (!context.mounted) return;
    final String? novoHorario = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Horários para $diaSemana'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: horariosDisponiveis.length,
            itemBuilder: (context, index) {
              final h = horariosDisponiveis[index];
              return ListTile(
                title: Text(h),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context, h),
              );
            },
          ),
        ),
      ),
    );

    // 4. Janela de Confirmação antes de executar a troca
    if (novoHorario != null && context.mounted) {
      final dataFormatada = DateFormat('dd/MM/yyyy').format(novaData);
      final horarioOriginal = timeSlot; // Já disponível na classe SessaoListItem

      final confirmou = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Reagendamento'),
          content: Text(
            'Confirma a mudança de $horarioOriginal para $novoHorario a partir de $dataFormatada?\n\n'
            'As sessões restantes deste treinamento serão movidas para este novo horário.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

      // 5. Executar a lógica de troca se confirmado
      if (confirmou == true && context.mounted) {
// ... dentro do método _showTrocarHorarioDialog em sessao_list_item.dart

try {
  await viewModel.trocarHorarioSessoesRestantes(
    sessaoBase: sessao,
    novaDataInicio: novaData,
    novoHorario: novoHorario,
  );
  if (context.mounted) SnackBarHelper.showSuccess(context, 'Horário atualizado!');
} catch (e) {
  if (!context.mounted) return;

  // Debug para você ver no console o que está chegando
  debugPrint('Erro capturado na View: $e');

  if (e.toString().contains('BLOQUEIO_DETECTADO')) {
    final prosseguir = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Força o usuário a escolher
      builder: (context) => AlertDialog(
        title: const Text('Horário Bloqueado Detectado'),
        content: const Text(
          'Algumas datas futuras possuem bloqueios. Deseja pular essas datas e continuar o agendamento?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, Continuar'),
          ),
        ],
      ),
    );

    if (prosseguir == true && context.mounted) {
      try {
        await viewModel.trocarHorarioSessoesRestantes(
          sessaoBase: sessao,
          novaDataInicio: novaData,
          novoHorario: novoHorario,
          ignorarBloqueios: true, // Segunda tentativa ignorando bloqueios
        );
        if (context.mounted) SnackBarHelper.showSuccess(context, 'Reagendamento concluído!');
      } catch (e2) {
        if (context.mounted) SnackBarHelper.showError(context, e2.toString());
      }
    }
  } else {
    // Mostra qualquer outro erro (ex: conflito de paciente)
    SnackBarHelper.showError(context, e.toString());
  }
}
      }
    }
  }

  Color _getCardBackgroundColor(Sessao? sessao, bool isDailyBlocked) {
    if (isDailyBlocked) return Colors.grey.shade200;
    if (sessao == null) return Colors.green.shade50;
    
    switch (sessao.status) {
      case 'Agendada': return Colors.blue.shade50;
      case 'Realizada': return Colors.blue.shade100;
      case 'Falta': return Colors.red.shade100;
      case 'Cancelada': return Colors.grey.shade100;
      case 'Bloqueada': return Colors.grey.shade200;
      default: return Colors.white;
    }
  }

  Widget _buildSessionInfo(BuildContext context, Sessao? sessao, bool isDailyBlocked) {
    final isOccupied = sessao != null;

    if (isDailyBlocked) {
      return Text('Dia bloqueado', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold));
    }

    if (!isOccupied) {
      return Text('Horário Disponível', style: TextStyle(color: Colors.green.shade800));
    }

    final sessaoNaoNula = sessao;
    final isPatientSessionBlocked = sessaoNaoNula.status == 'Bloqueada' && sessaoNaoNula.treinamentoId != 'bloqueio_manual';
    final isManualBlock = sessaoNaoNula.status == 'Bloqueada' && sessaoNaoNula.treinamentoId == 'bloqueio_manual';

    if (isManualBlock) {
      return Text('Horário bloqueado', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold));
    }

    final patientNameStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
      decoration: isPatientSessionBlocked ? TextDecoration.lineThrough : null,
      decorationColor: isPatientSessionBlocked ? Colors.red.shade700 : null,
      decorationThickness: isPatientSessionBlocked ? 2.0 : null,
      color: isPatientSessionBlocked ? Colors.grey.shade700 : null,
    );
    
    Widget? statusIndicatorWidget;
    if (isPatientSessionBlocked) {
      statusIndicatorWidget = Text(
        'BLOQUEADO',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
      );
    } else if (sessaoNaoNula.status == 'Falta') {
      statusIndicatorWidget = Text(
        'FALTA',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade800),
      );
    } else if (sessaoNaoNula.status == 'Cancelada') {
      statusIndicatorWidget = Text(
        'CANCELADA',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
      );
    } else if (sessaoNaoNula.parcelamento == 'Por sessão') {
      if (sessaoNaoNula.statusPagamento == 'Pendente') {
        statusIndicatorWidget = Text(
          'PENDENTE',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
        );
      } else if (sessaoNaoNula.statusPagamento == 'Realizado') {
        statusIndicatorWidget = Text(
          'PAGO',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800),
        );
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sessaoNaoNula.pacienteNome, style: patientNameStyle),
            const SizedBox(height: 2),
            Text(
              'Sessão ${sessaoNaoNula.numeroSessao} de ${sessaoNaoNula.totalSessoes}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomRight,
            child: statusIndicatorWidget,
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenuButton(BuildContext context, SessoesViewModel viewModel, Sessao? sessao, String timeSlot) {
    final bool isOccupied = sessao != null;

    bool isEditable = true;
    if (sessao != null && sessao.treinamentoId != 'bloqueio_manual') {
      final treinamentosDoPaciente = viewModel.treinamentosDoPacienteSelecionado;
      Treinamento? parentTraining;
      try {
        parentTraining = treinamentosDoPaciente.firstWhere((t) => t.id == sessao.treinamentoId);
      } catch (e) {
        parentTraining = null;
      }

      if (parentTraining != null && parentTraining.status != 'ativo') {
        isEditable = false;
      }
    }

    if (!isEditable) {
      return Container();
    }

    return PopupMenuButton<AcaoSessao>(
      icon: const Icon(Icons.more_vert),
      onSelected: (AcaoSessao action) async {
        if (!context.mounted) return;

        switch (action) {
          case AcaoSessao.agendar:
            final result = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => TreinamentoFormDialog(selectedDay: selectedDay, timeSlot: timeSlot),
            );
            if (result == true) {
              await viewModel.onPageChanged(selectedDay);
            }
            break;
          case AcaoSessao.bloquear:
             if (isOccupied) {
               await viewModel.updateSessaoStatus(sessao, 'Bloqueada');
             } else {
               await viewModel.blockTimeSlot(timeSlot, selectedDay);
             }
             break;
          case AcaoSessao.desbloquear:
            if (sessao?.id != null) {
              await viewModel.deleteBlockedTimeSlot(sessao!.id!);
            }
            break;
          case AcaoSessao.realizar:
            await viewModel.updateSessaoStatus(sessao!, 'Realizada');
            break;
          case AcaoSessao.faltar:
            await viewModel.updateSessaoStatus(sessao!, 'Falta');
            break;
          case AcaoSessao.cancelar:
            final bool? desmarcarTodas = await _showCancellationDialog(context);
            if (desmarcarTodas != null && context.mounted) {
              await viewModel.updateSessaoStatus(sessao!, 'Cancelada', desmarcarTodasFuturas: desmarcarTodas);
            }
            break;
          case AcaoSessao.reverter:
            await viewModel.updateSessaoStatus(sessao!, 'Agendada');
            break;
          case AcaoSessao.confirmarPagamento:
            await _showConfirmPaymentDialog(context, viewModel, sessao!);
            break;
          case AcaoSessao.reverterPagamento:
            await viewModel.reverterPagamentoSessao(sessao!);
            break;
          case AcaoSessao.trocarHorario:
            _showTrocarHorarioDialog(context, viewModel, sessao!);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        if (isOccupied) {
          final sessaoNaoNula = sessao;
          if (sessaoNaoNula.status == 'Bloqueada') {
            if (sessaoNaoNula.treinamentoId == 'bloqueio_manual') {
              return [
                const PopupMenuItem<AcaoSessao>(
                  value: AcaoSessao.desbloquear,
                  child: Text('Desbloquear Horário'),
                ),
              ];
            } else {
              return [
                const PopupMenuItem<AcaoSessao>(
                  value: AcaoSessao.reverter,
                  child: Text('Desbloquear Sessão'),
                ),
              ];
            }
          }

          List<PopupMenuEntry<AcaoSessao>> items = [];

          if (sessaoNaoNula.status == 'Agendada') {
            items.addAll([
              const PopupMenuItem<AcaoSessao>(value: AcaoSessao.bloquear, child: Text('Bloquear Horário')),
              const PopupMenuItem<AcaoSessao>(value: AcaoSessao.realizar, child: Text('Marcar como Realizada')),
              const PopupMenuItem<AcaoSessao>(value: AcaoSessao.faltar, child: Text('Marcar como Falta')),
              const PopupMenuItem<AcaoSessao>(value: AcaoSessao.cancelar, child: Text('Marcar como Cancelada')),
              const PopupMenuItem<AcaoSessao>(value: AcaoSessao.trocarHorario, child: Text('Trocar Horário')),
            ]);
          }

          if (sessaoNaoNula.status == 'Realizada' || sessaoNaoNula.status == 'Falta' || sessaoNaoNula.status == 'Cancelada') {
            items.add(const PopupMenuItem<AcaoSessao>(value: AcaoSessao.reverter, child: Text('Reverter para Agendada')));
          }

          if (sessaoNaoNula.parcelamento == 'Por sessão') {
            bool needsDivider = items.isNotEmpty;
            if (sessaoNaoNula.statusPagamento == 'Pendente' && (sessaoNaoNula.status == 'Agendada' || sessaoNaoNula.status == 'Realizada')) {
              if (needsDivider) items.add(const PopupMenuDivider());
              items.add(const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.confirmarPagamento,
                child: Text('Confirmar Pagamento'),
              ));
            } else if (sessaoNaoNula.statusPagamento == 'Realizado') {
              if (needsDivider) items.add(const PopupMenuDivider());
              items.add(const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.reverterPagamento,
                child: Text('Reverter Pagamento'),
              ));
            }
          }
          
          return items;

        } else {
          return [
            const PopupMenuItem<AcaoSessao>(value: AcaoSessao.agendar, child: Text('Agendar Treinamento')),
            const PopupMenuItem<AcaoSessao>(value: AcaoSessao.bloquear, child: Text('Bloquear Horário')),
          ];
        }
      },
    );
  }
}