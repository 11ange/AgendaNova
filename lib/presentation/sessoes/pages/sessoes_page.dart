import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/core/utils/date_formatter.dart';
import 'package:intl/intl.dart';

// Tela de Sessões
class SessoesPage extends StatefulWidget {
  const SessoesPage({super.key});

  @override
  State<SessoesPage> createState() => _SessoesPageState();
}

class _SessoesPageState extends State<SessoesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late SessoesViewModel _viewModel;
  bool _isInitialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<SessoesViewModel>(context, listen: false);
      _viewModel.loadSessoesForMonth(_focusedDay);
      _viewModel.loadSessoesForDay(_selectedDay!);
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
          if (viewModel.isLoading && viewModel.dailyStatusMapStream == null) {
             return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              StreamBuilder<Map<DateTime, String>>(
                stream: viewModel.dailyStatusMapStream,
                initialData: const {},
                builder: (context, snapshot) {
                  print('DEBUG UI: snapshot.connectionState (DailyStatus): ${snapshot.connectionState}');
                  print('DEBUG UI: snapshot.hasData (DailyStatus): ${snapshot.hasData}');
                  print('DEBUG UI: snapshot.data?.isEmpty (DailyStatus): ${snapshot.data?.isEmpty}');
                  print('DEBUG UI: snapshot.data?.length (DailyStatus): ${snapshot.data?.length}');
                  print('DEBUG UI: snapshot.data (DailyStatus): ${snapshot.data}');

                  final dailyStatus = snapshot.data ?? {};
                  return TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    locale: 'pt_BR',
                    rowHeight: 42.0,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      viewModel.loadSessoesForDay(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      viewModel.loadSessoesForMonth(focusedDay);
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade100,
                      ),
                      selectedDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final status = dailyStatus[day];
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
                            color = Colors.grey.shade200;
                            break;
                          default:
                            color = Colors.transparent;
                        }

                        if (isSameDay(day, _selectedDay)) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        if (isSameDay(day, DateTime.now())) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.all(2.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Bloquear Dia Inteiro'),
                                content: const Text('Tem certeza que deseja bloquear o dia inteiro?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
                                    child: const Text('Bloquear'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            try {
                              await viewModel.blockEntireDay(_selectedDay!);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Dia inteiro bloqueado com sucesso!')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao bloquear dia: ${e.toString()}')),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('Bloquear Dia'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Desbloquear Dia Inteiro'),
                                content: const Text('Tem certeza que deseja desbloquear o dia inteiro?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
                                    child: const Text('Desbloquear'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            try {
                              await viewModel.unblockEntireDay(_selectedDay!);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Dia inteiro desbloqueado com sucesso!')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao desbloquear dia: ${e.toString()}')),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('Desbloquear Dia'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  DateFormat('EEEE, dd \'de\' MMMM \'de\' BBBB', 'pt_BR').format(_selectedDay!),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: StreamBuilder<Map<String, Sessao?>>(
                  stream: viewModel.horariosCompletosStream,
                  initialData: const {},
                  builder: (context, snapshot) {
                    print('DEBUG UI: snapshot.connectionState (Horarios): ${snapshot.connectionState}');
                    print('DEBUG UI: snapshot.hasData (Horarios): ${snapshot.hasData}');
                    print('DEBUG UI: snapshot.data?.isEmpty: ${snapshot.data?.isEmpty}');
                    print('DEBUG UI: snapshot.data?.length: ${snapshot.data?.length}');
                    print('DEBUG UI: snapshot.data (Horarios): ${snapshot.data}');

                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro ao carregar horários: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nenhum horário disponível ou agendado para este dia.'));
                    }

                    final Map<String, Sessao?> horarios = snapshot.data!;
                    final List<String> sortedTimes = horarios.keys.toList()..sort();

                    return ListView.builder(
                      itemCount: sortedTimes.length,
                      itemBuilder: (context, index) {
                        final timeSlot = sortedTimes[index];
                        final sessao = horarios[timeSlot];
                        final isOccupied = sessao != null;
                        final isBlocked = isOccupied && (sessao!.status == 'Bloqueada');

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              timeSlot,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              isBlocked
                                  ? 'Status: Bloqueado'
                                  : isOccupied
                                      ? 'Paciente: ${sessao!.pacienteNome} - Sessão ${sessao.numeroSessao}/${sessao.totalSessoes} | Status: ${sessao.status} | Pagamento: ${sessao.statusPagamento}'
                                      : 'Horário Disponível',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      _showSessionActions(context, viewModel, sessao, timeSlot);
                                    },
                                  ),
                            tileColor: _getTileColor(sessao, isOccupied),
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

  Color _getTileColor(Sessao? sessao, bool isOccupied) {
    if (!isOccupied) {
      return Colors.green.shade50;
    }
    switch (sessao!.status) {
      case 'Agendada':
        return Colors.blue.shade50;
      case 'Realizada':
        return Colors.green.shade100;
      case 'Falta':
        return Colors.red.shade50;
      case 'Cancelada':
        return Colors.yellow.shade50;
      case 'Bloqueada':
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  void _showSessionActions(BuildContext context, SessoesViewModel viewModel, Sessao? sessao, String timeSlot) {
    final bool isOccupied = sessao != null;
    final bool isBlocked = isOccupied && sessao!.status == 'Bloqueada';
    final bool isDayBlockedComplete = isBlocked && sessao!.treinamentoId == 'dia_bloqueado_completo';


    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              if (!isOccupied)
                ListTile(
                  leading: const Icon(Icons.event_available),
                  title: const Text('Agendar Treinamento'),
                  onTap: () {
                    Navigator.pop(bc);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Agendar treinamento para ${DateFormatter.formatDate(_selectedDay!)} às $timeSlot em desenvolvimento.')),
                    );
                  },
                ),
              if (!isBlocked && !isDayBlockedComplete)
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Bloquear Horário'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      if (isOccupied) {
                        await viewModel.updateSessaoStatus(sessao!, 'Bloqueada');
                      } else {
                        await viewModel.blockTimeSlot(timeSlot, _selectedDay!);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Horário ${DateFormatter.formatDate(_selectedDay!)} às $timeSlot bloqueado com sucesso!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao bloquear horário: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
              
              if (isOccupied && !isBlocked)
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Marcar como Realizada'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      await viewModel.updateSessaoStatus(sessao!, 'Realizada');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sessão marcada como Realizada!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
              if (isOccupied && !isBlocked)
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Marcar como Falta'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      await viewModel.updateSessaoStatus(sessao!, 'Falta');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sessão marcada como Falta!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
              if (isOccupied && !isBlocked)
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Marcar como Cancelada'),
                  onTap: () async {
                    Navigator.pop(bc);
                    final bool? desmarcarTodas = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Desmarcar Sessão'),
                          content: const Text('Deseja desmarcar apenas esta sessão ou esta e todas as futuras (encerra o treinamento)?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: const Text('Apenas esta'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              child: const Text('Todas as futuras'),
                            ),
                          ],
                        );
                      },
                    );

                    if (desmarcarTodas != null) {
                      try {
                        await viewModel.updateSessaoStatus(sessao!, 'Cancelada', desmarcarTodasFuturas: desmarcarTodas);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sessão(ões) marcada(s) como Cancelada(s)!')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                ),
              
              if (isBlocked)
                ListTile(
                  leading: const Icon(Icons.lock_open),
                  title: const Text('Desbloquear Horário'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      if (isDayBlockedComplete) {
                        await viewModel.unblockEntireDay(_selectedDay!);
                      } else {
                        await viewModel.deleteBlockedTimeSlot(sessao!.id!);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Horário ${DateFormatter.formatDate(_selectedDay!)} às $timeSlot desbloqueado com sucesso!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao desbloquear horário: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),

              if (isOccupied && !isBlocked && sessao!.status != 'Agendada')
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Reverter para Agendada'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      await viewModel.updateSessaoStatus(sessao, 'Agendada');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sessão revertida para Agendada!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),

              if (isOccupied && !isBlocked && sessao!.statusPagamento == 'Pendente' && sessao.status != 'Realizada')
                ListTile(
                  leading: const Icon(Icons.payments),
                  title: const Text('Marcar Pagamento como Realizado'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      await viewModel.markPaymentAsRealizado(sessao.id!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pagamento marcado como Realizado!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao marcar pagamento: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
              if (isOccupied && !isBlocked && sessao!.statusPagamento == 'Realizado')
                ListTile(
                  leading: const Icon(Icons.undo),
                  title: const Text('Desfazer Pagamento'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      await viewModel.undoPayment(sessao.id!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pagamento desfeito!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao desfazer pagamento: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
