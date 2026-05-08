import 'package:flutter/material.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/reativar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/arquivar_paciente_usecase.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'dart:async';

// ViewModel para a tela de Pacientes Inativos
class PacientesInativosViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository;
  final ReativarPacienteUseCase _reativarPacienteUseCase;
  final ArquivarPacienteUseCase _arquivarPacienteUseCase;

  List<Paciente> _pacientes = [];
  List<Paciente> get pacientes => _pacientes;

  final _pacientesStreamController = StreamController<List<Paciente>>.broadcast();
  Stream<List<Paciente>> get pacientesStream => _pacientesStreamController.stream;

  StreamSubscription? _pacientesSubscription;

  PacientesInativosViewModel(
    this._pacienteRepository,
    this._reativarPacienteUseCase,
    this._arquivarPacienteUseCase,
  ) {
    _listenToPacientes();
  }

  void _listenToPacientes() {
    _pacientesSubscription?.cancel();
    _pacientesSubscription = _pacienteRepository.getPacientesInativos().listen(
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

  void loadPacientesInativos() {
    _listenToPacientes();
  }

  Future<void> reativarPaciente(String id) async {
    try {
      await _reativarPacienteUseCase.call(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> arquivarPaciente(String id) async {
    try {
      await _arquivarPacienteUseCase.call(id);
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
