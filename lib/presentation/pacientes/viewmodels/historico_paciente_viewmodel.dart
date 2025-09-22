// lib/presentation/pacientes/viewmodels/historico_paciente_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/entities/pagamento.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';

class HistoricoPacienteViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final TreinamentoRepository _treinamentoRepository = GetIt.instance<TreinamentoRepository>();
  final SessaoRepository _sessaoRepository = GetIt.instance<SessaoRepository>();

  // State
  Paciente? _paciente;
  List<Treinamento> _treinamentos = [];
  Map<String, List<Sessao>> _sessoesPorTreinamento = {};
  final Map<String, List<Pagamento>> _pagamentosPorTreinamento = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  Paciente? get paciente => _paciente;
  List<Treinamento> get treinamentos => _treinamentos;
  Map<String, List<Sessao>> get sessoesPorTreinamento => _sessoesPorTreinamento;
  Map<String, List<Pagamento>> get pagamentosPorTreinamento => _pagamentosPorTreinamento;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistorico(String pacienteId) async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _pacienteRepository.getPacienteById(pacienteId),
        _treinamentoRepository.getTreinamentosByPacienteId(pacienteId).first,
      ]);

      _paciente = results[0] as Paciente?;
      if (_paciente == null) throw Exception('Paciente não encontrado');

      final treinamentos = results[1] as List<Treinamento>;
      treinamentos.sort((a, b) => b.dataInicio.compareTo(a.dataInicio));
      _treinamentos = treinamentos;

      final Map<String, List<Sessao>> sessoesMap = {};
      _pagamentosPorTreinamento.clear();

      for (final treinamento in _treinamentos) {
        if (treinamento.id != null) {
          final sessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(treinamento.id!);
          sessoes.sort((a, b) => a.dataHora.compareTo(b.dataHora));
          sessoesMap[treinamento.id!] = sessoes;

          if (treinamento.pagamentos != null) {
            _pagamentosPorTreinamento[treinamento.id!] = treinamento.pagamentos!;
          }
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