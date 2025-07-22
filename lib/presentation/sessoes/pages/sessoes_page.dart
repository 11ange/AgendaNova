// lib/presentation/sessoes/pages/sessoes_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:agendanova/presentation/sessoes/widgets/treinamento_form_dialog.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/entities/treinamento.dart';
import 'package:agendanova/core/utils/date_formatter.dart';
import 'package:intl/intl.dart';

// Enum para tornar as ações do menu mais seguras e legíveis
enum AcaoSessao {
  agendar,
  bloquear,
  desbloquear, // Para bloqueios manuais
  realizar,
  faltar,
  cancelar,
  reverter, // Para reverter status (incluindo desbloqueio de sessão de paciente)
  confirmarPagamento,
  reverterPagamento,
}

class SessoesPage extends StatefulWidget {
  const SessoesPage({super.key});

  @override
  State<SessoesPage> createState() => _SessoesPageState();
}

class _SessoesPageState extends State<SessoesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late SessoesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<SessoesViewModel>(context, listen: false);
      _viewModel.initialize(_focusedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sessões',
        onBackButtonPressed: () => context.go('/home'),
      ),
      body: Consumer<SessoesViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2050, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                locale: 'pt_BR',
                rowHeight: 30.0,
                daysOfWeekHeight: 15,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  headerPadding: EdgeInsets.symmetric(vertical: 4.0),
                  leftChevronPadding: EdgeInsets.all(4.0),
                  rightChevronPadding: EdgeInsets.all(4.0),
                  titleTextStyle: TextStyle(fontSize: 17.0),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final status = viewModel.dailyStatus[DateUtils.dateOnly(day)];
                    Color color;
                    switch (status) {
                      case 'livre':
                        color = Colors.green.shade100;
                        break;
                      case 'parcial':
                        color = Colors.yellow.shade300;
                        break;
                      case 'cheio':
                        color = Colors.red.shade300;
                        break;
                      case 'indisponivel':
                        color = Colors.grey.shade200;
                        break;
                      default:
                        color = Colors.transparent;
                    }

                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: isSameDay(day, _selectedDay)
                            ? const TextStyle(color: Colors.white)
                            : const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                     return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                         borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    );
                  }
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  viewModel.loadSessoesForDay(selectedDay);
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _selectedDay = null; 
                    _focusedDay = focusedDay;
                  });
                  viewModel.onPageChanged(focusedDay);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_selectedDay == null) return;
                          final confirm = await _showConfirmationDialog(context, 'Bloquear Dia Inteiro', 'Tem certeza que deseja bloquear o dia inteiro?');
                          if (confirm == true) {
                            await viewModel.blockEntireDay(_selectedDay!);
                          }
                        },
                        child: const Text('Bloquear Dia'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_selectedDay == null) return;
                           final confirm = await _showConfirmationDialog(context, 'Desbloquear Dia Inteiro', 'Tem certeza que deseja desbloquear o dia inteiro?');
                           if (confirm == true) {
                            await viewModel.unblockEntireDay(_selectedDay!);
                           }
                        },
                        child: const Text('Desbloquear Dia'),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Text(
                    DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(_selectedDay!),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              Expanded(
                child: _selectedDay == null
                    ? const Center(child: Text('Selecione um dia no calendário.'))
                    : Builder(
                        builder: (context) {
                          if (viewModel.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final isDailyBlocked = viewModel.dailyStatus[DateUtils.dateOnly(_selectedDay!)] == 'indisponivel';
                          
                          if (viewModel.horariosCompletos.isEmpty && !isDailyBlocked) {
                            return const Center(child: Text('Nenhum horário disponível para este dia.'));
                          }

                          final Map<String, Sessao?> horarios = viewModel.horariosCompletos;
                          final List<String> sortedTimes = horarios.keys.toList()..sort();

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            itemCount: sortedTimes.length,
                            itemBuilder: (context, index) {
                              final timeSlot = sortedTimes[index];
                              final sessao = horarios[timeSlot];
                              
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
                                      if(!isDailyBlocked)
                                        SizedBox(
                                          width: 48,
                                          child: _buildPopupMenuButton(context, viewModel, sessao, timeSlot),
                                        )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPopupMenuButton(BuildContext context, SessoesViewModel viewModel, Sessao? sessao, String timeSlot) {
    final bool isOccupied = sessao != null;

    // Lógica de bloqueio para treinamentos passados
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
      return Container(); // Oculta o menu se não for editável
    }

    return PopupMenuButton<AcaoSessao>(
      icon: const Icon(Icons.more_vert),
      onSelected: (AcaoSessao action) async {
        if (!context.mounted) return;

        switch (action) {
          case AcaoSessao.agendar:
            final result = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => TreinamentoFormDialog(selectedDay: _selectedDay!, timeSlot: timeSlot),
            );
            if (result == true) {
              await viewModel.onPageChanged(_focusedDay);
            }
            break;
          case AcaoSessao.bloquear:
             if (isOccupied) {
               await viewModel.updateSessaoStatus(sessao, 'Bloqueada');
             } else {
               await viewModel.blockTimeSlot(timeSlot, _selectedDay!);
             }
             break;
          case AcaoSessao.desbloquear: // Apenas para bloqueios manuais
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
          case AcaoSessao.reverter: // Para reverter qualquer status para 'Agendada'
            await viewModel.updateSessaoStatus(sessao!, 'Agendada');
            break;
          case AcaoSessao.confirmarPagamento:
            await _showConfirmPaymentDialog(context, viewModel, sessao!);
            break;
          case AcaoSessao.reverterPagamento:
            await viewModel.reverterPagamentoSessao(sessao!);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        if (isOccupied) {
          final sessaoNaoNula = sessao;
          // Sessão de paciente que foi bloqueada
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

          // Ações para sessão Agendada
          if (sessaoNaoNula.status == 'Agendada') {
            items.addAll([
              const PopupMenuItem<AcaoSessao>(
                  value: AcaoSessao.bloquear, child: Text('Bloquear Horário')),
              const PopupMenuItem<AcaoSessao>(
                  value: AcaoSessao.realizar, child: Text('Marcar como Realizada')),
              const PopupMenuItem<AcaoSessao>(
                  value: AcaoSessao.faltar, child: Text('Marcar como Falta')),
              const PopupMenuItem<AcaoSessao>(
                  value: AcaoSessao.cancelar, child: Text('Marcar como Cancelada')),
            ]);
          }

          // Ação para reverter status (qualquer um que não seja 'Agendada' ou 'Bloqueada')
          if (sessaoNaoNula.status == 'Realizada' || sessaoNaoNula.status == 'Falta' || sessaoNaoNula.status == 'Cancelada') {
            items.add(const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.reverter, child: Text('Reverter para Agendada')));
          }

          // Ações de Pagamento
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
          // Horário vago
          return [
            const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.agendar, child: Text('Agendar Treinamento')),
            const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.bloquear, child: Text('Bloquear Horário')),
          ];
        }
      },
    );
  }

  Widget _buildSessionInfo(BuildContext context, Sessao? sessao, bool isDailyBlocked) {
    final isOccupied = sessao != null;

    if (isDailyBlocked) {
      return Text('Dia bloqueado', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold));
    }

    if (!isOccupied) {
      return Text('Horário Disponível', style: TextStyle(color: Colors.green.shade800));
    }

    // A partir daqui, sabemos que a sessão não é nula.
    final sessaoNaoNula = sessao;
    final isPatientSessionBlocked = sessaoNaoNula.status == 'Bloqueada' && sessaoNaoNula.treinamentoId != 'bloqueio_manual';
    final isManualBlock = sessaoNaoNula.status == 'Bloqueada' && sessaoNaoNula.treinamentoId == 'bloqueio_manual';

    if (isManualBlock) {
      return Text('Horário bloqueado', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold));
    }

    // É uma sessão de paciente (agendada, realizada, falta, cancelada ou bloqueada)
    final patientNameStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
      decoration: isPatientSessionBlocked ? TextDecoration.lineThrough : null,
      decorationColor: isPatientSessionBlocked ? Colors.red.shade700 : null,
      decorationThickness: isPatientSessionBlocked ? 2.0 : null,
      color: isPatientSessionBlocked ? Colors.grey.shade700 : null,
    );
    
    // Define o widget de status da sessão e pagamento
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
        // Conteúdo principal (nome e número da sessão)
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
        // Texto de status sobreposto
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomRight,
            child: statusIndicatorWidget,
          ),
        ),
      ],
    );
  }

  Color _getCardBackgroundColor(Sessao? sessao, bool isDailyBlocked) {
    if (isDailyBlocked) return Colors.grey.shade200;
    if (sessao == null) return Colors.green.shade50;
    
    switch (sessao.status) {
      case 'Agendada': return Colors.blue.shade50;
      case 'Realizada': return Colors.blue.shade200;
      case 'Falta': return Colors.red.shade100;
      case 'Cancelada': return Colors.grey.shade100;
      case 'Bloqueada': return Colors.grey.shade200;
      default: return Colors.white;
    }
  }

  Future<void> _showConfirmPaymentDialog(
    BuildContext context, SessoesViewModel viewModel, Sessao sessao) async {
    final formKey = GlobalKey<FormState>();
    final dataPagamentoController = TextEditingController();
    DateTime? dataPagamentoSelecionada = DateTime.now(); // Initialize
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
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(dialogContext);
                      try {
                        await viewModel.confirmarPagamentoSessao(
                            sessao, dataPagamentoSelecionada!);
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                              content: Text('Pagamento confirmado com sucesso!')),
                        );
                        navigator.pop();
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                              content:
                                  Text('Erro ao confirmar pagamento: $e')),
                        );
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

  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirmar')),
          ],
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
              onPressed: () => Navigator.of(dialogContext).pop(null), // Cancelar a ação
              child: const Text('Voltar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // Apenas esta
              child: const Text('Apenas esta'),
            ),
             ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true), // Todas as futuras
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Todas as futuras'),
            ),
          ],
        );
      },
    );
  }
}