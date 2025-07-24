import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/inativar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'dart:async';

// ViewModel para a tela de Pacientes Ativos
class PacientesAtivosViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final InativarPacienteUseCase _inativarPacienteUseCase = GetIt.instance<InativarPacienteUseCase>();

  List<Paciente> _pacientes = [];
  List<Paciente> get pacientes => _pacientes;

  final _pacientesStreamController = StreamController<List<Paciente>>.broadcast();
  Stream<List<Paciente>> get pacientesStream => _pacientesStreamController.stream;

  // Variável para armazenar a inscrição do stream
  StreamSubscription? _pacientesSubscription;

  PacientesAtivosViewModel() {
    _listenToPacientes();
  }

  void _listenToPacientes() {
    // Cancela qualquer inscrição anterior para evitar leaks
    _pacientesSubscription?.cancel();
    // Armazena a nova inscrição na variável
    _pacientesSubscription = _pacienteRepository.getPacientesAtivos().listen(
      (pacientesList) {
        _pacientes = pacientesList;
        // Adiciona um check de segurança para não adicionar a um controller fechado
        if (!_pacientesStreamController.isClosed) {
          _pacientesStreamController.add(_pacientes);
        }
        notifyListeners();
      },
      onError: (error) {
        if (!_pacientesStreamController.isClosed) {
          _pacientesStreamController.addError(error);
        }
      },
    );
  }

  void loadPacientesAtivos() {
    // A escuta já é iniciada, mas este método pode ser usado para reiniciar se necessário.
    _listenToPacientes();
  }

  Future<void> inativarPaciente(String id) async {
    try {
      await _inativarPacienteUseCase.call(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    // Cancela a inscrição e fecha o controller
    _pacientesSubscription?.cancel();
    _pacientesStreamController.close();
    super.dispose();
  }
}