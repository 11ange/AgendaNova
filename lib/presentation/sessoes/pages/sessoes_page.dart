import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:agendanova/presentation/sessoes/widgets/treinamento_form_dialog.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendanova/domain/entities/sessao.dart';
//import 'package:agendanova/core/utils/date_formatter.dart';
import 'package:intl/intl.dart';

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
              StreamBuilder<Map<DateTime, String>>(
                stream: viewModel.dailyStatusMapStream,
                initialData: viewModel.dailyStatus,
                builder: (context, snapshot) {
                  final dailyStatus = snapshot.data ?? {};
                  return TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    locale: 'pt_BR',
                    // --- AJUSTE: Diminui a altura das linhas do calendário ---
                    rowHeight: 38.0, 
                    daysOfWeekHeight: 16, // Diminui a altura da linha dos dias da semana
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      // --- AJUSTE: Diminui os espaços no cabeçalho ---
                      headerPadding: EdgeInsets.symmetric(vertical: 4.0),
                      leftChevronPadding: EdgeInsets.all(4.0),
                      rightChevronPadding: EdgeInsets.all(4.0),
                      titleTextStyle: TextStyle(fontSize: 17.0),
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
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final status = dailyStatus[DateUtils.dateOnly(day)];
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
                            margin: const EdgeInsets.all(4.0), // Diminuído
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${day.day}', style: const TextStyle(color: Colors.white)),
                          );
                        }
                        if (isSameDay(day, DateTime.now())) {
                          return Container(
                            margin: const EdgeInsets.all(4.0), // Diminuído
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${day.day}', style: const TextStyle(color: Colors.black)),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.all(2.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          child: Text('${day.day}', style: const TextStyle(color: Colors.black)),
                        );
                      },
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
                  );
                },
              ),
              Padding(
                // --- AJUSTE: Diminui o espaçamento vertical ---
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
                  // --- AJUSTE: Diminui o espaçamento vertical ---
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Text(
                    // --- CORREÇÃO: Formato do ano de 'BBBB' para 'yyyy' ---
                    DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(_selectedDay!),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              Expanded(
                child: _selectedDay == null
                    ? const Center(child: Text('Selecione um dia no calendário.'))
                    : StreamBuilder<Map<String, Sessao?>>(
                        stream: viewModel.horariosCompletosStream,
                        initialData: viewModel.horariosCompletos,
                        builder: (context, snapshot) {
                          if (viewModel.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(child: Text("Carregando horários..."));
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Erro ao carregar horários: ${snapshot.error}'));
                          }
                          if (snapshot.data!.isEmpty) {
                            return const Center(child: Text('Nenhum horário disponível ou agendado para este dia.'));
                          }

                          final Map<String, Sessao?> horarios = snapshot.data!;
                          final List<String> sortedTimes = horarios.keys.toList()..sort();

                          return ListView.builder(
                            // --- AJUSTE: Remove o padding padrão do ListView ---
                            padding: EdgeInsets.zero,
                            itemCount: sortedTimes.length,
                            itemBuilder: (context, index) {
                              final timeSlot = sortedTimes[index];
                              final sessao = horarios[timeSlot];
                              final isOccupied = sessao != null;

                              return Card(
                                // --- AJUSTE: Diminui a margem do card ---
                                margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 12.0),
                                child: ListTile(
                                  // --- AJUSTE: Torna o ListTile mais denso ---
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(timeSlot, style: Theme.of(context).textTheme.titleMedium),
                                  subtitle: Text(
                                    isOccupied ? 'Paciente: ${sessao.pacienteNome} | Status: ${sessao.status}' : 'Horário Disponível',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () => _showSessionActions(context, viewModel, sessao, timeSlot),
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

  Color _getTileColor(Sessao? sessao, bool isOccupied) {
    if (!isOccupied) return Colors.green.shade50;
    switch (sessao!.status) {
      case 'Agendada': return Colors.blue.shade50;
      case 'Realizada': return Colors.green.shade100;
      case 'Falta': return Colors.red.shade50;
      case 'Cancelada': return Colors.yellow.shade50;
      case 'Bloqueada': return Colors.orange.shade50;
      default: return Colors.grey.shade50;
    }
  }

  void _showSessionActions(BuildContext context, SessoesViewModel viewModel, Sessao? sessao, String timeSlot) {
    final bool isOccupied = sessao != null;
    final bool isBlocked = isOccupied && sessao.status == 'Bloqueada';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              if (!isOccupied)
                ListTile(
                  leading: const Icon(Icons.event_available),
                  title: const Text('Agendar Treinamento'),
                  onTap: () async {
                    Navigator.pop(bc);
                    if (_selectedDay != null) {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return TreinamentoFormDialog(selectedDay: _selectedDay!, timeSlot: timeSlot);
                        },
                      );
                      if (result == true) {
                        viewModel.onPageChanged(_focusedDay);
                      }
                    }
                  },
                ),
              if (!isOccupied)
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Bloquear Horário'),
                  onTap: () async {
                    Navigator.pop(bc);
                    if (_selectedDay != null) {
                      await viewModel.blockTimeSlot(timeSlot, _selectedDay!);
                    }
                  },
                ),
              if (isOccupied && !isBlocked) ...[
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Marcar como Realizada'),
                  onTap: () async {
                     Navigator.pop(bc);
                     await viewModel.updateSessaoStatus(sessao, 'Realizada');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Marcar como Falta'),
                  onTap: () async {
                    Navigator.pop(bc);
                    await viewModel.updateSessaoStatus(sessao, 'Falta');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Marcar como Cancelada'),
                  onTap: () async {
                    Navigator.pop(bc);
                    final bool? desmarcarTodas = await _showConfirmationDialog(
                      context, 'Desmarcar Sessão', 'Deseja desmarcar apenas esta sessão ou esta e todas as futuras (encerra o treinamento)?'
                    );
                    if (desmarcarTodas != null) {
                      await viewModel.updateSessaoStatus(sessao, 'Cancelada', desmarcarTodasFuturas: desmarcarTodas);
                    }
                  },
                ),
              ],
              if (isBlocked)
                ListTile(
                  leading: const Icon(Icons.lock_open),
                  title: const Text('Desbloquear Horário'),
                  onTap: () async {
                    Navigator.pop(bc);
                    if (sessao.id != null) {
                      await viewModel.deleteBlockedTimeSlot(sessao.id!);
                    }
                  },
                ),
              if (isOccupied && sessao.status != 'Agendada')
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Reverter para Agendada'),
                  onTap: () async {
                    Navigator.pop(bc);
                    await viewModel.updateSessaoStatus(sessao, 'Agendada');
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}