import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // Importar GetIt
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/usecases/paciente/inativar_paciente_usecase.dart'; // Importação corrigida
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'dart:async';

// ViewModel para a tela de Pacientes Ativos
class PacientesAtivosViewModel extends ChangeNotifier {
  // Obtenha as instâncias via GetIt
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final InativarPacienteUseCase _inativarPacienteUseCase = GetIt.instance<InativarPacienteUseCase>();

  List<Paciente> _pacientes = [];
  List<Paciente> get pacientes => _pacientes;

  // StreamController para gerenciar o stream de pacientes
  final _pacientesStreamController = StreamController<List<Paciente>>.broadcast();
  Stream<List<Paciente>> get pacientesStream => _pacientesStreamController.stream;

  PacientesAtivosViewModel() { // Construtor sem parâmetros, pois as dependências são resolvidas via GetIt
    _listenToPacientes(); // Chamar o método no construtor
  }

  // Escuta as mudanças nos pacientes ativos e atualiza a lista
  void _listenToPacientes() {
    _pacienteRepository.getPacientesAtivos().listen(
      (pacientesList) {
        _pacientes = pacientesList;
        _pacientesStreamController.add(_pacientes); // Adiciona a nova lista ao stream
        notifyListeners(); // Notifica os ouvintes da mudança de estado
      },
      onError: (error) {
        _pacientesStreamController.addError(error);
        // Em vez de print, você pode usar um logger ou exibir uma mensagem mais amigável
        // print('Erro ao carregar pacientes ativos: $error');
      },
    );
  }

  // Carrega os pacientes ativos (chamado na inicialização da tela)
  void loadPacientesAtivos() {
    // A escuta já é iniciada no construtor, então este método pode ser mais para
    // garantir que a primeira carga aconteça ou para recarregar se necessário.
    // A lógica de stream já cuida das atualizações.
  }

  // Inativa um paciente
  Future<void> inativarPaciente(String id) async {
    try {
      await _inativarPacienteUseCase.call(id);
    } catch (e) {
      rethrow; // Relança a exceção para ser tratada na UI
    }
  }

  @override
  void dispose() {
    _pacientesStreamController.close(); // Fecha o stream controller
    super.dispose();
  }
}
