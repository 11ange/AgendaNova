import 'package:flutter/material.dart';
import 'package:agenda_treinamento/presentation/sessoes/viewmodels/treinamento_dialog_viewmodel.dart';
import 'package:agenda_treinamento/core/utils/input_validators.dart';
import 'package:agenda_treinamento/core/utils/snackbar_helper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TreinamentoFormDialog extends StatefulWidget {
  final DateTime selectedDay;
  final String timeSlot;

  const TreinamentoFormDialog({
    super.key,
    required this.selectedDay,
    required this.timeSlot,
  });

  @override
  State<TreinamentoFormDialog> createState() => _TreinamentoFormDialogState();
}

class _TreinamentoFormDialogState extends State<TreinamentoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedPacienteId; 
  
  String? _selectedDiaSemana;
  String? _selectedHorario;
  final TextEditingController _numeroSessoesController = TextEditingController();
  final TextEditingController _nomeConvenioController = TextEditingController();
  DateTime? _dataInicio;
  String? _selectedFormaPagamento;
  String? _selectedTipoParcelamento;

  @override
  void initState() {
    super.initState();
    _dataInicio = widget.selectedDay;
    final dayName = DateFormat('EEEE', 'pt_BR').format(widget.selectedDay);
    _selectedDiaSemana = dayName[0].toUpperCase() + dayName.substring(1);
    _selectedHorario = widget.timeSlot;
  }

  @override
  void dispose() {
    _numeroSessoesController.dispose();
    _nomeConvenioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreinamentoDialogViewModel(),
      child: Consumer<TreinamentoDialogViewModel>(
        builder: (context, viewModel, child) {
          final availablePatientIds = viewModel.pacientes.map((p) => p.id).toSet();
          if (_selectedPacienteId != null && !availablePatientIds.contains(_selectedPacienteId)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedPacienteId = null;
              });
            });
          }

          return AlertDialog(
            title: const Text('Agendar Novo Treinamento'),
            content: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          DropdownButtonFormField<String>(
                            value: _selectedPacienteId,
                            decoration: const InputDecoration(labelText: 'Paciente *'),
                            items: viewModel.pacientes.map((paciente) {
                              return DropdownMenuItem<String>(
                                value: paciente.id,
                                child: Text(paciente.nome),
                              );
                            }).toList(),
                            onChanged: (pacienteId) {
                              setState(() {
                                _selectedPacienteId = pacienteId;
                              });
                            },
                            validator: (value) => value == null ? 'Selecione um paciente' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _numeroSessoesController,
                            decoration: const InputDecoration(labelText: 'Número de Sessões *'),
                            keyboardType: TextInputType.number,
                            validator: (value) => InputValidators.positiveInteger(value, 'Número de Sessões'),
                          ),
                           const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedFormaPagamento,
                            decoration: const InputDecoration(labelText: 'Forma de Pagamento *'),
                            items: ['Dinheiro', 'Pix', 'Convenio']
                                .map((forma) => DropdownMenuItem(value: forma, child: Text(forma)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFormaPagamento = value;
                                _selectedTipoParcelamento = null;
                              });
                            },
                            validator: (value) => value == null ? 'Selecione uma forma de pagamento' : null,
                          ),
                          if (_selectedFormaPagamento == 'Convenio') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nomeConvenioController,
                              decoration: const InputDecoration(labelText: 'Nome do Convênio *'),
                              validator: (value) => InputValidators.requiredField(value, 'Nome do Convênio'),
                            ),
                          ],
                          if (_selectedFormaPagamento == 'Dinheiro' || _selectedFormaPagamento == 'Pix') ...[
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedTipoParcelamento,
                              decoration: const InputDecoration(labelText: 'Tipo de Parcelamento *'),
                              items: ['Por sessão', '3x']
                                  .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTipoParcelamento = value;
                                });
                              },
                              validator: (value) => value == null ? 'Selecione o tipo de parcelamento' : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await viewModel.criarTreinamento(
                              pacienteId: _selectedPacienteId!,
                              diaSemana: _selectedDiaSemana!,
                              horario: _selectedHorario!,
                              numeroSessoesTotal: int.parse(_numeroSessoesController.text),
                              dataInicio: _dataInicio!,
                              formaPagamento: _selectedFormaPagamento!,
                              tipoParcelamento: _selectedTipoParcelamento,
                              nomeConvenio: _selectedFormaPagamento == 'Convenio' ? _nomeConvenioController.text : null,
                            );

                            if (!context.mounted) return;
                            
                            SnackBarHelper.showSuccess(context, 'Treinamento agendado com sucesso!');
                            Navigator.of(context).pop(true);
                          } catch (e) {
                            if (!context.mounted) return;
                            SnackBarHelper.showError(context, e);
                          }
                        }
                      },
                child: const Text('Agendar'),
              ),
            ],
          );
        },
      ),
    );
  }
}