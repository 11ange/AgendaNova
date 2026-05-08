import 'package:flutter/material.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/inativar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'dart:async';

// ViewModel para a tela de Pacientes Ativos
class PacientesAtivosViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository;
  final InativarPacienteUseCase _inativarPacienteUseCase;

  List<Paciente> _pacientes = [];
  List<Paciente> get pacientes => _pacientes;

  final _pacientesStreamController = StreamController<List<Paciente>>.broadcast();
  Stream<List<Paciente>> get pacientesStream => _pacientesStreamController.stream;

  StreamSubscription? _pacientesSubscription;

  PacientesAtivosViewModel(
    this._pacienteRepository,
    this._inativarPacienteUseCase,
  ) {
    _listenToPacientes();
  }

  void _listenToPacientes() {
    _pacientesSubscription?.cancel();
    _pacientesSubscription = _pacienteRepository.getPacientesAtivos().listen(
      (pacientesList) {
        _pacientes = pacientesList;
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
    _pacientesSubscription?.cancel();
    _pacientesStreamController.close();
    super.dispose();
  }
}
