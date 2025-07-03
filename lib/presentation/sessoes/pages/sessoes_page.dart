import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/sessoes/viewmodels/sessoes_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/core/utils/date_formatter.dart';

// Tela de Sessões
class SessoesPage extends StatefulWidget {
  const SessoesPage({super.key});

  @override
  State<SessoesPage> createState() => _SessoesPageState();
}

class _SessoesPageState extends State<SessoesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SessoesViewModel>(context, listen: false).loadSessoesForDay(_selectedDay!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessoesViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Sessões',
          onBackButtonPressed: () => context.go('/home'),
        ),
        body: Consumer<SessoesViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay; // update `_focusedDay` here as well
                    });
                    viewModel.loadSessoesForDay(selectedDay); // Carrega sessões para o dia selecionado
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: const CalendarStyle( // Adicionado const
                    outsideDaysVisible: false,
                    // TODO: Cores para dias (verde: livre, amarelo: parcial, vermelho: cheio)
                    // Isso exigirá uma lógica para determinar o status do dia com base nas sessões.
                    // Por enquanto, as cores não serão aplicadas dinamicamente.
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Lógica para bloquear o dia inteiro
                            if (mounted) { // Adicionado mounted check
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Bloquear dia inteiro em desenvolvimento.')),
                              );
                            }
                          },
                          child: const Text('Bloquear Dia'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Lógica para desbloquear o dia inteiro
                            if (mounted) { // Adicionado mounted check
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Desbloquear dia inteiro em desenvolvimento.')),
                              );
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
                    'Sessões para: ${DateFormatter.formatDate(_selectedDay!)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Sessao>>(
                    stream: viewModel.sessoesDoDiaStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erro ao carregar sessões: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Nenhuma sessão agendada para este dia.'));
                      }

                      final sessoes = snapshot.data!;
                      return ListView.builder(
                        itemCount: sessoes.length,
                        itemBuilder: (context, index) {
                          final sessao = sessoes[index];
                          // TODO: Criar um widget SessaoCard para exibir as informações da sessão
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text('Sessão ${sessao.numeroSessao} - ${DateFormatter.formatTime(sessao.dataHora)}'),
                              subtitle: Text('Status: ${sessao.status} | Pagamento: ${sessao.statusPagamento}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  // TODO: Opções de ação para a sessão (bloquear, confirmar, faltar, desmarcar, reverter)
                                  _showSessionActions(context, viewModel, sessao);
                                },
                              ),
                              tileColor: _getSessionTileColor(sessao.status), // Cor de fundo baseada no status
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
      ),
    );
  }

  Color _getSessionTileColor(String status) {
    switch (status) {
      case 'Agendada':
        return Colors.green.shade100; // Horário livre (agendado mas não iniciado)
      case 'Cancelada':
      case 'Bloqueada':
        return Colors.yellow.shade100; // Horário desmarcado/bloqueado
      case 'Realizada':
        return Colors.blue.shade100; // Sessão realizada
      case 'Falta':
        return Colors.red.shade100; // Falta
      default:
        return Colors.grey.shade100;
    }
  }

  void _showSessionActions(BuildContext context, SessoesViewModel viewModel, Sessao sessao) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Marcar como Realizada'),
                onTap: () async {
                  Navigator.pop(bc);
                  try {
                    await viewModel.updateSessaoStatus(sessao, 'Realizada');
                    if (mounted) { // Adicionado mounted check
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sessão marcada como Realizada!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) { // Adicionado mounted check
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Marcar como Falta'),
                onTap: () async {
                  Navigator.pop(bc);
                  try {
                    await viewModel.updateSessaoStatus(sessao, 'Falta');
                    if (mounted) { // Adicionado mounted check
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sessão marcada como Falta!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) { // Adicionado mounted check
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Marcar como Cancelada'),
                onTap: () async {
                  Navigator.pop(bc);
                  // Opção de desmarcar apenas a atual ou todas as futuras
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
                      await viewModel.updateSessaoStatus(sessao, 'Cancelada', desmarcarTodasFuturas: desmarcarTodas);
                      if (mounted) { // Adicionado mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sessão(ões) marcada(s) como Cancelada(s)!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) { // Adicionado mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro: ${e.toString()}')),
                        );
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Marcar como Bloqueada'),
                onTap: () async {
                  Navigator.pop(bc);
                  try {
                    await viewModel.updateSessaoStatus(sessao, 'Bloqueada');
                    if (mounted) { // Adicionado mounted check
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sessão marcada como Bloqueada!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) { // Adicionado mounted check
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
              if (sessao.status != 'Agendada') // Opção de reverter só se não for "Agendada"
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Reverter para Agendada'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      await viewModel.updateSessaoStatus(sessao, 'Agendada');
                      if (mounted) { // Adicionado mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sessão revertida para Agendada!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) { // Adicionado mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
              // TODO: Lógica para marcar/desfazer pagamento por sessão
              if (sessao.statusPagamento == 'Pendente' && sessao.status != 'Realizada') // Só pode marcar como paga se não estiver realizada
                ListTile(
                  leading: const Icon(Icons.payments),
                  title: const Text('Marcar Pagamento como Realizado'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      await viewModel.markPaymentAsRealizado(sessao.id!);
                      if (mounted) { // Adicionado mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pagamento marcado como Realizado!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) { // Adicionado mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao marcar pagamento: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
              if (sessao.statusPagamento == 'Realizado')
                ListTile(
                  leading: const Icon(Icons.undo),
                  title: const Text('Desfazer Pagamento'),
                  onTap: () async {
                    Navigator.pop(bc);
                    try {
                      await viewModel.undoPayment(sessao.id!);
                      if (mounted) { // Adicionado mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pagamento desfeito!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) { // Adicionado mounted check
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
