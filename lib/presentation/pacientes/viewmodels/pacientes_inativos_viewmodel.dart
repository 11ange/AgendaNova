import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/usecases/paciente/reativar_paciente_usecase.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'dart:async';

// ViewModel para a tela de Pacientes Inativos
class PacientesInativosViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final ReativarPacienteUseCase _reativarPacienteUseCase = GetIt.instance<ReativarPacienteUseCase>();

  List<Paciente> _pacientes = [];
  List<Paciente> get pacientes => _pacientes;

  final _pacientesStreamController = StreamController<List<Paciente>>.broadcast();
  Stream<List<Paciente>> get pacientesStream => _pacientesStreamController.stream;

  // Variável para armazenar a inscrição do stream
  StreamSubscription? _pacientesSubscription;

  PacientesInativosViewModel() {
    _listenToPacientes();
  }

  void _listenToPacientes() {
    // Cancela qualquer inscrição anterior para evitar leaks
    _pacientesSubscription?.cancel();
    // Armazena a nova inscrição na variável
    _pacientesSubscription = _pacienteRepository.getPacientesInativos().listen(
      (pacientesList) {
        _pacientes = pacientesList;
        // Adiciona um check de segurança
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

  @override
  void dispose() {
    // Cancela a inscrição e fecha o controller
    _pacientesSubscription?.cancel();
    _pacientesStreamController.close();
    super.dispose();
  }
}