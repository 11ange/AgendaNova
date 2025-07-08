import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/entities/treinamento.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';

class HistoricoPacienteViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final TreinamentoRepository _treinamentoRepository = GetIt.instance<TreinamentoRepository>();
  final SessaoRepository _sessaoRepository = GetIt.instance<SessaoRepository>();

  // State
  Paciente? _paciente;
  List<Treinamento> _treinamentos = [];
  Map<String, List<Sessao>> _sessoesPorTreinamento = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  Paciente? get paciente => _paciente;
  List<Treinamento> get treinamentos => _treinamentos;
  Map<String, List<Sessao>> get sessoesPorTreinamento => _sessoesPorTreinamento;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistorico(String pacienteId) async {
    _setLoading(true);
    try {
      // Carrega o paciente e os treinamentos em paralelo
      final results = await Future.wait([
        _pacienteRepository.getPacienteById(pacienteId),
        _treinamentoRepository.getTreinamentosByPacienteId(pacienteId).first,
      ]);

      _paciente = results[0] as Paciente?;
      if (_paciente == null) throw Exception('Paciente não encontrado');

      final treinamentos = results[1] as List<Treinamento>;
      treinamentos.sort((a, b) => b.dataInicio.compareTo(a.dataInicio));
      _treinamentos = treinamentos;

      // Para cada treinamento, carrega as suas sessões
      final Map<String, List<Sessao>> sessoesMap = {};
      for (final treinamento in _treinamentos) {
        if (treinamento.id != null) {
          final sessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(treinamento.id!);
          sessoes.sort((a, b) => a.dataHora.compareTo(b.dataHora));
          sessoesMap[treinamento.id!] = sessoes;
        }
      }
      _sessoesPorTreinamento = sessoesMap;

    } catch (e) {
      _errorMessage = 'Falha ao carregar histórico: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}