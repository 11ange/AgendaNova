import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:agendanova/presentation/sessoes/widgets/treinamento_form_dialog.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendanova/domain/entities/sessao.dart';
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
                        color = Colors.green.shade200;
                        break;
                      case 'parcial':
                        color = Colors.yellow.shade200;
                        break;
                      case 'cheio':
                        color = Colors.red.shade200;
                        break;
                      case 'indisponivel':
                        color = Colors.transparent;
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
               await viewModel.updateSessaoStatus(sessao!, 'Bloqueada');
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
        }
      },
      itemBuilder: (BuildContext context) {
        // Lógica para construir o menu de acordo com o estado da sessão
        if (isOccupied) {
          // O horário está ocupado por uma sessão
          if (sessao!.status == 'Bloqueada') {
            if (sessao.treinamentoId == 'bloqueio_manual') {
              // É um bloqueio manual em um horário vago
              return [
                const PopupMenuItem<AcaoSessao>(
                  value: AcaoSessao.desbloquear,
                  child: Text('Desbloquear Horário'),
                ),
              ];
            } else {
              // É uma sessão de paciente que foi bloqueada
              return [
                const PopupMenuItem<AcaoSessao>(
                  value: AcaoSessao.reverter,
                  child: Text('Desbloquear Sessão'),
                ),
              ];
            }
          } else if (sessao.status == 'Agendada') {
             // É uma sessão de paciente agendada
            return [
              const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.bloquear,
                child: Text('Bloquear Horário'),
              ),
              const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.realizar,
                child: Text('Marcar como Realizada'),
              ),
              const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.faltar,
                child: Text('Marcar como Falta'),
              ),
              const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.cancelar,
                child: Text('Marcar como Cancelada'),
              ),
            ];
          } else {
            // É uma sessão com outro status (Realizada, Falta, Cancelada)
            return [
              const PopupMenuItem<AcaoSessao>(
                value: AcaoSessao.reverter,
                child: Text('Reverter para Agendada'),
              ),
            ];
          }
        } else {
          // O horário está vago
          return [
            const PopupMenuItem<AcaoSessao>(
              value: AcaoSessao.agendar,
              child: Text('Agendar Treinamento'),
            ),
            const PopupMenuItem<AcaoSessao>(
              value: AcaoSessao.bloquear,
              child: Text('Bloquear Horário'),
            ),
          ];
        }
      },
    );
  }

  Widget _buildSessionInfo(BuildContext context, Sessao? sessao, bool isDailyBlocked) {
    final isOccupied = sessao != null;

    if (isDailyBlocked) {
      return Text('Dia bloqueado', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold));
    }

    if (!isOccupied) {
      return Text('Horário Disponível', style: TextStyle(color: Colors.green.shade800));
    }

    // A partir daqui, sabemos que a sessão não é nula.
    final sessaoNaoNula = sessao!;
    final isPatientSessionBlocked = sessaoNaoNula.status == 'Bloqueada' && sessaoNaoNula.treinamentoId != 'bloqueio_manual';
    final isManualBlock = sessaoNaoNula.status == 'Bloqueada' && sessaoNaoNula.treinamentoId == 'bloqueio_manual';

    if (isManualBlock) {
      return Text('Horário bloqueado', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold));
    }

    // É uma sessão de paciente (agendada, realizada, falta, cancelada ou bloqueada)
    final patientNameStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
      decoration: isPatientSessionBlocked ? TextDecoration.lineThrough : null, // Aplica o tachado se estiver bloqueada
      decorationColor: isPatientSessionBlocked ? Colors.red.shade700 : null,
      decorationThickness: isPatientSessionBlocked ? 2.0 : null,
      color: isPatientSessionBlocked ? Colors.grey.shade700 : null,
    );

    return Stack(
      clipBehavior: Clip.none, // Permite que o texto "BLOQUEADO" saia um pouco dos limites se necessário
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
        // Texto "BLOQUEADO" sobreposto
        if (isPatientSessionBlocked)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'BLOQUEADO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getCardBackgroundColor(Sessao? sessao, bool isDailyBlocked) {
    if (isDailyBlocked) return Colors.orange.shade50;
    if (sessao == null) return Colors.green.shade50;
    
    switch (sessao.status) {
      case 'Agendada': return Colors.blue.shade50;
      case 'Realizada': return Colors.green.shade100;
      case 'Falta': return Colors.red.shade50;
      case 'Cancelada': return Colors.yellow.shade50;
      case 'Bloqueada': return Colors.orange.shade50;
      default: return Colors.grey.shade50;
    }
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
