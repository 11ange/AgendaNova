import 'package:flutter/material.dart';
import 'package:flutter_agenda_fono/core/services/firebase_service.dart';
import 'package:flutter_agenda_fono/data/datasources/firebase_datasource.dart';
import 'package:flutter_agenda_fono/data/repositories/paciente_repository_impl.dart';
import 'package:flutter_agenda_fono/domain/entities/paciente.dart';
import 'package:flutter_agenda_fono/domain/repositories/paciente_repository.dart';
// Importe o repositório de agendamento quando ele for criado
// import 'package:flutter_agenda_fono/data/repositories/agendamento_repository_impl.dart';
// import 'package:flutter_agenda_fono/domain/repositories/agendamento_repository.dart';
// import 'package:flutter_agenda_fono/domain/entities/treinamento.dart'; // Entidade de Treinamento

// ViewModel para a tela de Histórico do Paciente
class HistoricoPacienteViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository;
  // final AgendamentoRepository _agendamentoRepository; // Descomentar quando AgendamentoRepository for criado

  bool _isLoading = false;
  Paciente? _paciente;
  List<dynamic> _treinamentos = []; // Mudar para List<Treinamento> quando a entidade for criada

  bool get isLoading => _isLoading;
  Paciente? get paciente => _paciente;
  List<dynamic> get treinamentos => _treinamentos;

  HistoricoPacienteViewModel({PacienteRepository? pacienteRepository})
      : _pacienteRepository = pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance));
        // _agendamentoRepository = agendamentoRepository ?? AgendamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance));

  Future<void> loadPacienteAndTreinamentos(String pacienteId) async {
    _setLoading(true);
    try {
      _paciente = await _pacienteRepository.getPacienteById(pacienteId);
      if (_paciente == null) {
        throw Exception('Paciente não encontrado.');
      }
      // TODO: Carregar treinamentos do paciente quando o AgendamentoRepository estiver pronto
      // _treinamentos = await _agendamentoRepository.getTreinamentosByPacienteId(pacienteId);
      // Simulando dados de treinamento por enquanto
      _treinamentos = [
        {'id': 'T001', 'dataInicio': '01/01/2024', 'dataFim': '10/03/2024', 'status': 'concluido'},
        {'id': 'T002', 'dataInicio': '15/03/2024', 'dataFim': '20/05/2024', 'status': 'ativo'},
      ];
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

