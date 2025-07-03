import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/agenda/viewmodels/agenda_viewmodel.dart';
import 'package:provider/provider.dart';

// Tela de Definição de Agenda
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final List<String> _weekdays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
  ];

  final List<String> _times = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
    '17:00', '17:30',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AgendaViewModel>(context, listen: false).loadAgenda();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AgendaViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Horários de Atendimento',
          onBackButtonPressed: () => context.go('/home'),
        ),
        body: Consumer<AgendaViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column( // Usar Column para fixar o botão na parte inferior
              children: [
                Expanded( // Conteúdo da agenda rolável
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._weekdays.map((day) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row( // Usar Row para colocar o texto e o botão lado a lado
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      day,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_sweep, color: Colors.red),
                                      onPressed: () async {
                                        // Confirmação antes de limpar
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext dialogContext) {
                                            return AlertDialog(
                                              title: const Text('Limpar Horários do Dia'),
                                              content: Text('Tem certeza que deseja limpar todos os horários para $day?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                                  child: const Text('Limpar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm == true) {
                                          try {
                                            await viewModel.clearDayAgenda(day); // Chama o método do ViewModel
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Horários de $day limpos com sucesso!')),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Erro ao limpar horários: ${e.toString()}')),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      tooltip: 'Limpar horários de $day',
                                    ),
                                  ],
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, // 3 botões lado a lado
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                  childAspectRatio: 2.5, // Ajuste para o tamanho do botão
                                ),
                                itemCount: _times.length,
                                itemBuilder: (context, index) {
                                  final time = _times[index];
                                  final isSelected = viewModel.isTimeSelected(day, time);
                                  return ElevatedButton(
                                    onPressed: () {
                                      viewModel.toggleTimeSelection(day, time);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                                      foregroundColor: isSelected ? Colors.white : Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.zero, // Remove padding padrão para melhor controle
                                    ),
                                    child: Text(
                                      time,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: 20), // Espaço extra para o final do conteúdo rolável
                      ],
                    ),
                  ),
                ),
                // Botão Salvar Agenda fixo na parte inferior
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              try {
                                await viewModel.saveAgenda();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Agenda salva com sucesso!')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro ao salvar agenda: ${e.toString()}')),
                                  );
                                }
                              }
                            },
                      child: viewModel.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Salvar Agenda'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
