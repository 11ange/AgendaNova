// lib/presentation/sessoes/pages/sessoes_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agenda_treinamento/presentation/common_widgets/custom_app_bar.dart';
import 'package:agenda_treinamento/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:agenda_treinamento/presentation/sessoes/widgets/sessao_list_item.dart';
import 'package:agenda_treinamento/presentation/sessoes/widgets/sessoes_calendar.dart';
import 'package:provider/provider.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
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
  trocarHorario,
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
              SessoesCalendar(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                dailyStatus: viewModel.dailyStatus,
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
                onTodayButtonPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _focusedDay = now;
                    _selectedDay = now;
                  });
                  viewModel.loadSessoesForDay(now);
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

                          // 1. Normaliza a data para usar como chave no mapa de status
                          final normalizedDate = DateUtils.dateOnly(_selectedDay!);
                          
                          // 2. Verifica o status atual do dia
                          final statusDoDia = viewModel.dailyStatus[normalizedDate];

                          // 3. Se já estiver indisponível (bloqueado ou sem horários na agenda), mostra o aviso
                          if (statusDoDia == 'indisponivel') {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Dia Indisponível'),
                                  content: const Text('Este dia já se encontra bloqueado ou não possui horários disponíveis na agenda.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                            return; // Interrompe a execução para não mostrar a confirmação de bloqueio
                          }

                          // 4. Se estiver livre ou parcial, prossegue com o fluxo normal de confirmação
                          final confirm = await _showConfirmationDialog(
                            context, 
                            'Bloquear Dia Inteiro', 
                            'Tem certeza que deseja bloquear o dia inteiro? Isso afetará todas as sessões agendadas.'
                          );
                          
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
                              
                              return SessaoListItem(
                                timeSlot: timeSlot, 
                                sessao: sessao, 
                                isDailyBlocked: isDailyBlocked, 
                                viewModel: viewModel,
                                selectedDay: _selectedDay!,
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
}