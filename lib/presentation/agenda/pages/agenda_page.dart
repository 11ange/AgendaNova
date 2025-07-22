// lib/presentation/agenda/pages/agenda_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/agenda/viewmodels/agenda_viewmodel.dart';
import 'package:provider/provider.dart';

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

  late AgendaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<AgendaViewModel>(context, listen: false);
    _viewModel.loadAgenda();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Horários de Atendimento',
        onBackButtonPressed: () => context.go('/home'),
      ),
      body: Consumer<AgendaViewModel>(
        builder: (context, viewModel, child) {
          // **CORREÇÃO AQUI: Mostra o erro na tela**
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(viewModel.errorMessage!),
              ),
            );
          }

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    day,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                                    onPressed: () async {
                                      final scaffoldMessenger = ScaffoldMessenger.of(context);
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
                                          await viewModel.clearDayAgenda(day);
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(content: Text('Horários de $day limpos com sucesso!')),
                                          );
                                        } catch (e) {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(content: Text('Erro ao limpar horários: ${e.toString()}')),
                                          );
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
                                crossAxisCount: 3,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 2.5,
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
                                    padding: EdgeInsets.zero,
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
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            try {
                              await viewModel.saveAgenda();
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text('Agenda salva com sucesso!')),
                              );
                            } catch (e) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Erro ao salvar agenda: ${e.toString()}')),
                              );
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
    );
  }
}