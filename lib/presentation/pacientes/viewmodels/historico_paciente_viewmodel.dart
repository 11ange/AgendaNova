import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/entities/treinamento.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'dart:async';

class HistoricoPacienteViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final TreinamentoRepository _treinamentoRepository = GetIt.instance<TreinamentoRepository>();
  final SessaoRepository _sessaoRepository = GetIt.instance<SessaoRepository>();

  // State
  Paciente? _paciente;
  List<Treinamento> _treinamentos = [];
  Map<String, List<Sessao>> _sessoesPorTreinamento = {};
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _treinamentosSubscription;

  // Getters
  Paciente? get paciente => _paciente;
  List<Treinamento> get treinamentos => _treinamentos;
  Map<String, List<Sessao>> get sessoesPorTreinamento => _sessoesPorTreinamento;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistorico(String pacienteId) async {
    _setLoading(true);
    await _treinamentosSubscription?.cancel(); // Cancela listener anterior

    try {
      // Carrega os detalhes do paciente uma vez
      _paciente = await _pacienteRepository.getPacienteById(pacienteId);
      if (_paciente == null) {
        throw Exception('Paciente não encontrado');
      }
      
      // Ouve as alterações nos treinamentos em tempo real
      _treinamentosSubscription = _treinamentoRepository.getTreinamentosByPacienteId(pacienteId).listen((treinamentos) async {
        _treinamentos = treinamentos;
        _treinamentos.sort((a, b) => b.dataInicio.compareTo(a.dataInicio)); // Ordena
        
        // Para cada treinamento, busca as sessões
        Map<String, List<Sessao>> sessoesMap = {};
        for (var treinamento in _treinamentos) {
          if (treinamento.id != null) {
            final sessoes = await _sessaoRepository.getSessoesByTreinamentoId(treinamento.id!).first;
            sessoes.sort((a, b) => a.dataHora.compareTo(b.dataHora));
            sessoesMap[treinamento.id!] = sessoes;
          }
        }
        _sessoesPorTreinamento = sessoesMap;
        _setLoading(false); // Notifica a UI para reconstruir com os novos dados
      });

    } catch (e) {
      print('Erro ao carregar histórico: $e');
      _errorMessage = 'Falha ao carregar histórico do paciente.';
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _treinamentosSubscription?.cancel();
    super.dispose();
  }
}