import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // Importar GetIt
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/usecases/paciente/reativar_paciente_usecase.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'dart:async';

// ViewModel para a tela de Pacientes Inativos
class PacientesInativosViewModel extends ChangeNotifier {
  // Obtenha as instâncias via GetIt
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final ReativarPacienteUseCase _reativarPacienteUseCase = GetIt.instance<ReativarPacienteUseCase>();

  List<Paciente> _pacientes = [];
  List<Paciente> get pacientes => _pacientes;

  final _pacientesStreamController = StreamController<List<Paciente>>.broadcast();
  Stream<List<Paciente>> get pacientesStream => _pacientesStreamController.stream;

  // Construtor sem parâmetros, pois as dependências são resolvidas via GetIt
  PacientesInativosViewModel() {
    _listenToPacientes(); // Chamar o método para iniciar a escuta do stream
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
        // Em vez de print, você pode usar um logger ou exibir uma mensagem mais amigável
        // print('Erro ao carregar pacientes inativos: $error');
      },
    );
  }

  void loadPacientesInativos() {
    // Este método pode ser usado para forçar um recarregamento se necessário,
    // mas a escuta já é iniciada no construtor.
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

