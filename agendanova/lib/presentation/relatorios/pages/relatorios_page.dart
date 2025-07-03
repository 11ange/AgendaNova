import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/relatorios/viewmodels/relatorios_viewmodel.dart'; // Será criado em breve
import 'package:agendanova/domain/entities/paciente.dart'; // Para seleção de paciente
import 'package:agendanova/core/utils/date_formatter.dart';
import 'package:provider/provider.dart';

// Tela de Relatórios
class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  Paciente? _selectedPaciente;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RelatoriosViewModel>(context, listen: false).loadPacientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RelatoriosViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Relatórios',
          onBackButtonPressed: () => context.go('/home'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gerar Relatório Mensal Global
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Relatório Mensal Global',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedMonth,
                              decoration: const InputDecoration(labelText: 'Mês'),
                              items: List.generate(12, (index) {
                                final month = index + 1;
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(DateFormat.MMMM('pt_BR').format(DateTime(2024, month))),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMonth = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedYear,
                              decoration: const InputDecoration(labelText: 'Ano'),
                              items: List.generate(5, (index) {
                                final year = DateTime.now().year - 2 + index;
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Consumer<RelatoriosViewModel>(
                        builder: (context, viewModel, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      try {
                                        final relatorio = await viewModel.gerarRelatorioMensalGlobal(_selectedYear, _selectedMonth);
                                        if (mounted) {
                                          _showRelatorioDialog(context, relatorio.tipoRelatorio, relatorio.dados);
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erro ao gerar relatório: ${e.toString()}')),
                                          );
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.analytics),
                              label: const Text('Gerar Relatório Mensal'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Gerar Relatório Individual do Paciente
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Relatório Individual do Paciente',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Consumer<RelatoriosViewModel>(
                        builder: (context, viewModel, child) {
                          return DropdownButtonFormField<Paciente>(
                            value: _selectedPaciente,
                            decoration: const InputDecoration(labelText: 'Selecionar Paciente *'),
                            items: viewModel.pacientes.map((paciente) {
                              return DropdownMenuItem<Paciente>(
                                value: paciente,
                                child: Text(paciente.nome),
                              );
                            }).toList(),
                            onChanged: (Paciente? newValue) {
                              setState(() {
                                _selectedPaciente = newValue;
                              });
                            },
                            validator: (value) => value == null ? 'Selecione um paciente' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Consumer<RelatoriosViewModel>(
                        builder: (context, viewModel, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: viewModel.isLoading || _selectedPaciente == null
                                  ? null
                                  : () async {
                                      try {
                                        final relatorio = await viewModel.gerarRelatorioIndividualPaciente(_selectedPaciente!.id!);
                                        if (mounted) {
                                          _showRelatorioDialog(context, relatorio.tipoRelatorio, relatorio.dados);
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erro ao gerar relatório: ${e.toString()}')),
                                          );
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.person_search),
                              label: const Text('Gerar Relatório Individual'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // TODO: Adicionar o relatório de vagas disponíveis e resumo de ocupação
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próximas Vagas Disponíveis e Ocupação',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      const Text('Lógica para vagas e ocupação será implementada aqui.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRelatorioDialog(BuildContext context, String title, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.map((entry) {
                if (entry.value is List) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...entry.value.map((item) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                        child: Text(item.toString()),
                      )).toList(),
                    ],
                  );
                }
                return Text('${entry.key}: ${entry.value}');
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

