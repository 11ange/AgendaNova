import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/presentation/common_widgets/custom_app_bar.dart';
import 'package:agenda_treinamento/presentation/pacientes/viewmodels/paciente_form_viewmodel.dart';
import 'package:agenda_treinamento/core/utils/date_formatter.dart';
import 'package:agenda_treinamento/core/utils/input_validators.dart';
import 'package:agenda_treinamento/core/utils/phone_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:agenda_treinamento/core/utils/snackbar_helper.dart';

// Tela de formulário para cadastro e edição de pacientes
class PacienteFormPage extends StatefulWidget {
  final String? pacienteId; // ID do paciente para edição (opcional)

  const PacienteFormPage({super.key, this.pacienteId});

  @override
  State<PacienteFormPage> createState() => _PacienteFormPageState();
}

class _PacienteFormPageState extends State<PacienteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _nomeResponsavelController = TextEditingController();
  final TextEditingController _telefoneResponsavelController = TextEditingController();
  final TextEditingController _emailResponsavelController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final TextEditingController _dataNascimentoController = TextEditingController();
  DateTime? _dataNascimento;
  String? _afinandoCerebro;

  late PacienteFormViewModel _viewModel;
  bool _isInitialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<PacienteFormViewModel>(context, listen: false);

    if (widget.pacienteId != null) {
      Future.microtask(() async {
        await _viewModel.loadPaciente(widget.pacienteId!);
        if (mounted && !_isInitialDataLoaded) {
          _populateFields(_viewModel.paciente);
          _isInitialDataLoaded = true;
        }
      });
    } else {
      _isInitialDataLoaded = true;
    }
  }

  void _populateFields(Paciente? paciente) {
    if (paciente != null) {
      setState(() {
        _nomeController.text = paciente.nome;
        _nomeResponsavelController.text = paciente.nomeResponsavel;
        // --- CORREÇÃO APLICADA AQUI ---
        _telefoneResponsavelController.text = paciente.telefoneResponsavel != null
            ? PhoneInputFormatter.formatPhoneNumber(paciente.telefoneResponsavel!)
            : '';
        _emailResponsavelController.text = paciente.emailResponsavel ?? '';
        _observacoesController.text = paciente.observacoes ?? '';
        _dataNascimento = paciente.dataNascimento;
        _dataNascimentoController.text = DateFormatter.formatDate(paciente.dataNascimento);
        _afinandoCerebro = paciente.afinandoCerebro;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataNascimento) {
      setState(() {
        _dataNascimento = picked;
        _dataNascimentoController.text = DateFormatter.formatDate(picked);
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nomeResponsavelController.dispose();
    _telefoneResponsavelController.dispose();
    _emailResponsavelController.dispose();
    _observacoesController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.pacienteId == null ? 'Novo Paciente' : 'Editar Paciente',
        onBackButtonPressed: () => context.pop(),
      ),
      body: Consumer<PacienteFormViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && widget.pacienteId != null && !_isInitialDataLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(labelText: 'Nome do Paciente *'),
                          validator: (value) => InputValidators.requiredField(value, 'Nome do Paciente'),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomeResponsavelController,
                          decoration: const InputDecoration(labelText: 'Nome do Responsável *'),
                          validator: (value) => InputValidators.requiredField(value, 'Nome do Responsável'),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _dataNascimentoController,
                              decoration: InputDecoration(
                                labelText: 'Data de Nascimento *',
                                suffixIcon: const Icon(Icons.calendar_today),
                                labelStyle: Theme.of(context).textTheme.bodyLarge,
                              ),
                              validator: (value) {
                                if (_dataNascimento == null) {
                                  return 'Data de Nascimento é obrigatório';
                                }
                                return null;
                              },
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_dataNascimento != null)
                          Text(
                            'Idade: ${Paciente(nome: '', dataNascimento: _dataNascimento!, nomeResponsavel: '', dataCadastro: DateTime.now(), status: 'ativo').idade} anos',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _telefoneResponsavelController,
                          decoration: const InputDecoration(
                            labelText: 'Telefone do Responsável',
                            counterText: '',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => InputValidators.phone(value),
                          style: Theme.of(context).textTheme.bodyLarge,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            PhoneInputFormatter(),
                          ],
                          maxLength: 15,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailResponsavelController,
                          decoration: const InputDecoration(labelText: 'E-mail do Responsável'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => InputValidators.email(value),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _afinandoCerebro,
                          decoration: InputDecoration(
                            labelText: 'Afinando o Cérebro',
                            labelStyle: Theme.of(context).textTheme.bodyLarge,
                          ),
                          items: <String>['Não enviado', 'Enviado', 'Cadastrado']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _afinandoCerebro = newValue;
                            });
                          },
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _observacoesController,
                          decoration: const InputDecoration(labelText: 'Observações'),
                          maxLines: 3,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
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
                            if (_formKey.currentState!.validate()) {
                              final telefoneApenasDigitos = _telefoneResponsavelController.text.replaceAll(RegExp(r'\D'), '');

                              final newPaciente = Paciente(
                                id: widget.pacienteId,
                                nome: _nomeController.text,
                                dataNascimento: _dataNascimento!,
                                nomeResponsavel: _nomeResponsavelController.text,
                                telefoneResponsavel: telefoneApenasDigitos.isEmpty
                                    ? null
                                    : telefoneApenasDigitos,
                                emailResponsavel: _emailResponsavelController.text.isEmpty
                                    ? null
                                    : _emailResponsavelController.text,
                                afinandoCerebro: _afinandoCerebro,
                                observacoes: _observacoesController.text.isEmpty
                                    ? null
                                    : _observacoesController.text,
                                dataCadastro: widget.pacienteId == null
                                    ? DateTime.now()
                                    : viewModel.paciente!.dataCadastro,
                                status: widget.pacienteId == null ? 'ativo' : viewModel.paciente!.status,
                              );

                              try {
                                if (widget.pacienteId == null) {
                                  await viewModel.cadastrarPaciente(newPaciente);
                                  if (!context.mounted) return;
                                  SnackBarHelper.showSuccess(context, 'Paciente cadastrado com sucesso!');
                                } else {
                                  await viewModel.editarPaciente(newPaciente);
                                  if (!context.mounted) return;
                                  SnackBarHelper.showSuccess(context, 'Paciente atualizado com sucesso!');
                                }
                                if (!context.mounted) return;
                                context.pop();
                              } catch (e) {
                                if (!context.mounted) return;
                                SnackBarHelper.showError(context, e);
                              }
                            }
                          },
                    child: Text(viewModel.isLoading
                        ? 'Salvando...'
                        : (widget.pacienteId == null ? 'Cadastrar Paciente' : 'Salvar Alterações')),
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