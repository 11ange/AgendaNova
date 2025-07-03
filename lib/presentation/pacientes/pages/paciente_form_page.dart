import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/presentation/common_widgets/custom_app_bar.dart';
import 'package:agendanova/presentation/pacientes/viewmodels/paciente_form_viewmodel.dart';
import 'package:agendanova/core/utils/date_formatter.dart';
import 'package:agendanova/core/utils/input_validators.dart';
import 'package:provider/provider.dart';

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
  DateTime? _dataNascimento;
  String? _afinandoCerebro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PacienteFormViewModel>(context, listen: false);
      if (widget.pacienteId != null) {
        viewModel.loadPaciente(widget.pacienteId!).then((_) {
          _populateFields(viewModel.paciente);
        });
      }
    });
  }

  void _populateFields(Paciente? paciente) {
    if (paciente != null) {
      _nomeController.text = paciente.nome;
      _nomeResponsavelController.text = paciente.nomeResponsavel;
      _telefoneResponsavelController.text = paciente.telefoneResponsavel ?? '';
      _emailResponsavelController.text = paciente.emailResponsavel ?? '';
      _observacoesController.text = paciente.observacoes ?? '';
      _dataNascimento = paciente.dataNascimento;
      _afinandoCerebro = paciente.afinandoCerebro;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PacienteFormViewModel(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.pacienteId == null ? 'Novo Paciente' : 'Editar Paciente',
          onBackButtonPressed: () => context.go('/pacientes-ativos'),
        ),
        body: Consumer<PacienteFormViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && widget.pacienteId != null) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeResponsavelController,
                      decoration: const InputDecoration(labelText: 'Nome do Responsável *'),
                      validator: (value) => InputValidators.requiredField(value, 'Nome do Responsável'),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Data de Nascimento *',
                            suffixIcon: const Icon(Icons.calendar_today),
                            hintText: _dataNascimento == null
                                ? 'Selecione a data'
                                : DateFormatter.formatDate(_dataNascimento!),
                          ),
                          validator: (value) {
                            if (_dataNascimento == null) {
                              return 'Por favor, selecione a data de nascimento';
                            }
                            return null;
                          },
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
                      decoration: const InputDecoration(labelText: 'Telefone do Responsável'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => InputValidators.phone(value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailResponsavelController,
                      decoration: const InputDecoration(labelText: 'E-mail do Responsável'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => InputValidators.email(value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _afinandoCerebro,
                      decoration: const InputDecoration(labelText: 'Afinando o Cérebro'),
                      items: <String>['Não enviado', 'Enviado', 'Cadastrado']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _afinandoCerebro = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _observacoesController,
                      decoration: const InputDecoration(labelText: 'Observações'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final newPaciente = Paciente(
                                    id: widget.pacienteId,
                                    nome: _nomeController.text,
                                    dataNascimento: _dataNascimento!,
                                    nomeResponsavel: _nomeResponsavelController.text,
                                    telefoneResponsavel: _telefoneResponsavelController.text.isEmpty
                                        ? null
                                        : _telefoneResponsavelController.text,
                                    emailResponsavel: _emailResponsavelController.text.isEmpty
                                        ? null
                                        : _emailResponsavelController.text,
                                    afinandoCerebro: _afinandoCerebro,
                                    observacoes: _observacoesController.text.isEmpty
                                        ? null
                                        : _observacoesController.text,
                                    dataCadastro: widget.pacienteId == null
                                        ? DateTime.now()
                                        : viewModel.paciente!.dataCadastro, // Mantém a data de cadastro original
                                    status: widget.pacienteId == null ? 'ativo' : viewModel.paciente!.status,
                                  );

                                  try {
                                    if (widget.pacienteId == null) {
                                      await viewModel.cadastrarPaciente(newPaciente);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Paciente cadastrado com sucesso!')),
                                        );
                                        context.go('/pacientes-ativos');
                                      }
                                    } else {
                                      await viewModel.editarPaciente(newPaciente);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Paciente atualizado com sucesso!')),
                                        );
                                        context.go('/pacientes-ativos');
                                      }
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
                        child: Text(viewModel.isLoading
                            ? 'Salvando...'
                            : (widget.pacienteId == null ? 'Cadastrar Paciente' : 'Salvar Alterações')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
