import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/pagamentos/viewmodels/pagamentos_viewmodel.dart'; // Será criado em breve
import 'package:agendanova/presentation/pagamentos/widgets/pagamento_card.dart'; // Será criado em breve
import 'package:agendanova/domain/entities/treinamento.dart';
//import 'package:agendanova/domain/entities/pagamento.dart';
//import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/core/utils/date_formatter.dart';
import 'package:provider/provider.dart';

// Tela de Controle de Pagamentos
class PagamentosPage extends StatefulWidget {
  const PagamentosPage({super.key});

  @override
  State<PagamentosPage> createState() => _PagamentosPageState();
}

class _PagamentosPageState extends State<PagamentosPage> {
  final TextEditingController _guiaConvenioController = TextEditingController();
  DateTime? _dataEnvioGuia;
  String? _selectedFormaPagamento;
  String? _selectedTipoParcelamento;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PagamentosViewModel>(
        context,
        listen: false,
      ).loadTreinamentos();
    });
  }

  @override
  void dispose() {
    _guiaConvenioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataEnvioGuia ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dataEnvioGuia) {
      setState(() {
        _dataEnvioGuia = picked;
      });
    }
  }

  Future<void> _showRegisterPaymentDialog(
    BuildContext context,
    PagamentosViewModel viewModel,
    Treinamento treinamento,
  ) async {
    _guiaConvenioController.clear();
    _dataEnvioGuia = null;
    _selectedFormaPagamento = null;
    _selectedTipoParcelamento = null;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Registrar Pagamento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      value: _selectedFormaPagamento,
                      decoration: const InputDecoration(
                        labelText: 'Forma de Pagamento *',
                      ),
                      items: <String>['Dinheiro', 'Pix', 'Convenio']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFormaPagamento = newValue;
                          _selectedTipoParcelamento =
                              null; // Reseta o parcelamento
                          _guiaConvenioController.clear();
                          _dataEnvioGuia = null;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Selecione a forma de pagamento'
                          : null,
                    ),
                    if (_selectedFormaPagamento == 'Dinheiro' ||
                        _selectedFormaPagamento == 'Pix')
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedTipoParcelamento,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Parcelamento *',
                          ),
                          items: <String>['Por sessão', '3x']
                              .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              })
                              .toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTipoParcelamento = newValue;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Selecione o tipo de parcelamento'
                              : null,
                        ),
                      ),
                    if (_selectedFormaPagamento == 'Convenio')
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _guiaConvenioController,
                            decoration: const InputDecoration(
                              labelText: 'Número da Guia *',
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Campo obrigatório'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _selectDate(context).then(
                              (_) => setState(() {}),
                            ), // Atualiza o estado do dialog
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Data de Envio da Guia *',
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  hintText: _dataEnvioGuia == null
                                      ? 'Selecione a data'
                                      : DateFormatter.formatDate(
                                          _dataEnvioGuia!,
                                        ),
                                ),
                                validator: (value) {
                                  if (_dataEnvioGuia == null) {
                                    return 'Por favor, selecione a data de envio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Registrar'),
                  onPressed: () async {
                    // TODO: Adicionar validação do formulário
                    try {
                      await viewModel.registrarPagamento(
                        treinamentoId: treinamento.id!,
                        pacienteId: treinamento.pacienteId,
                        formaPagamento: _selectedFormaPagamento!,
                        tipoParcelamento: _selectedTipoParcelamento,
                        guiaConvenio: _guiaConvenioController.text.isEmpty
                            ? null
                            : _guiaConvenioController.text,
                        dataEnvioGuia: _dataEnvioGuia,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pagamento registrado com sucesso!'),
                          ),
                        );
                        Navigator.of(dialogContext).pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erro ao registrar pagamento: ${e.toString()}',
                            ),
                          ),
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

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PagamentosViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Pagamentos',
          onBackButtonPressed: () => context.go('/home'),
        ),
        body: Consumer<PagamentosViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.treinamentosComPagamentos.isEmpty) {
              return const Center(
                child: Text('Nenhum treinamento com pagamentos para exibir.'),
              );
            }

            return ListView.builder(
              itemCount: viewModel.treinamentosComPagamentos.length,
              itemBuilder: (context, index) {
                final treinamento = viewModel.treinamentosComPagamentos[index];
                final paciente = viewModel.pacientes.firstWhere(
                  (p) => p.id == treinamento.pacienteId,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    title: Text(paciente.nome),
                    subtitle: Text(
                      'Período: ${DateFormatter.formatDate(treinamento.dataInicio)} - ${DateFormatter.formatDate(treinamento.dataFimPrevista)}\n'
                      'Horário: ${treinamento.diaSemana} ${treinamento.horario}\n'
                      'Forma de Pagamento: ${treinamento.formaPagamento} ${treinamento.tipoParcelamento != null ? '(${treinamento.tipoParcelamento})' : ''}',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Histórico de Pagamentos:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 10),
                            // Exibir pagamentos específicos do treinamento
                            if (viewModel
                                    .pagamentosPorTreinamento[treinamento.id]
                                    ?.isEmpty ??
                                true)
                              const Text(
                                'Nenhum pagamento registrado para este treinamento.',
                              )
                            else
                              ...viewModel.pagamentosPorTreinamento[treinamento.id]!.map((
                                pagamento,
                              ) {
                                return PagamentoCard(
                                  pagamento: pagamento,
                                  onRevert: () async {
                                    final confirm = await _showConfirmationDialog(
                                      context,
                                      'Confirmar Reversão',
                                      'Tem certeza que deseja reverter este pagamento?',
                                    );
                                    if (confirm == true) {
                                      try {
                                        await viewModel.reverterPagamento(
                                          pagamento.id!,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Pagamento revertido com sucesso!',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erro ao reverter pagamento: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              }).toList(),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showRegisterPaymentDialog(
                                  context,
                                  viewModel,
                                  treinamento,
                                ),
                                icon: const Icon(Icons.add_card),
                                label: const Text('Registrar Novo Pagamento'),
                              ),
                            ),
                            // Lógica para pagamentos por sessão (se aplicável)
                            if (treinamento.formaPagamento != 'Convenio' &&
                                treinamento.tipoParcelamento == 'Por sessão')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  Text(
                                    'Status de Pagamento por Sessão:',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 10),
                                  // TODO: Exibir status de pagamento de cada sessão individualmente
                                  // Isso exigiria buscar as sessões do treinamento e exibir seus status de pagamento.
                                  const Text(
                                    'Status de pagamento por sessão será exibido aqui.',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
