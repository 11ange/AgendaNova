import 'package:flutter/material.dart';
import 'package:agendanova/core/services/firebase_service.dart';
import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/repositories/paciente_repository_impl.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/usecases/paciente/reativar_paciente_usecase.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'dart:async';

// ViewModel para a tela de Pacientes Inativos
class PacientesInativosViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository;
  final ReativarPacienteUseCase _reativarPacienteUseCase;

  List<Paciente> _pacientes = [];
  List<Paciente> get pacientes => _pacientes;

  final _pacientesStreamController = StreamController<List<Paciente>>.broadcast();
  Stream<List<Paciente>> get pacientesStream => _pacientesStreamController.stream;

  PacientesInativosViewModel({PacienteRepository? pacienteRepository})
      : _pacienteRepository = pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        _reativarPacienteUseCase = ReativarPacienteUseCase(pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance))) {
    _listenToPacientes();
  }

  void _listenToPacientes() {
    _pacienteRepository.getPacientesInativos().listen(
      (pacientesList) {
        _pacientes = pacientesList;
        _pacientesStreamController.add(_pacientes);
        notifyListeners();
      },
      onError: (error) {
        _pacientesStreamController.addError(error);
        print('Erro ao carregar pacientes inativos: $error');
      },
    );
  }

  void loadPacientesInativos() {
    // A escuta já é iniciada no construtor.
  }

  // Reativa um paciente
  Future<void> reativarPaciente(String id) async {
    try {
      await _reativarPacienteUseCase.call(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _pacientesStreamController.close();
    super.dispose();
  }
}

