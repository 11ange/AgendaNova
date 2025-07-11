import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/entities/pagamento.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/entities/treinamento.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'package:agendanova/domain/repositories/pagamento_repository.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';
import 'package:agendanova/domain/usecases/pagamento/registrar_pagamento_usecase.dart';
import 'package:agendanova/domain/usecases/pagamento/reverter_pagamento_usecase.dart';
import 'package:agendanova/data/models/paciente_model.dart'; // Import necessário
import 'package:agendanova/core/utils/logger.dart';

class PagamentosViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final PagamentoRepository _pagamentoRepository = GetIt.instance<PagamentoRepository>();
  final TreinamentoRepository _treinamentoRepository = GetIt.instance<TreinamentoRepository>();
  final SessaoRepository _sessaoRepository = GetIt.instance<SessaoRepository>();
  final RegistrarPagamentoUseCase _registrarPagamentoUseCase = GetIt.instance<RegistrarPagamentoUseCase>();
  final ReverterPagamentoUseCase _reverterPagamentoUseCase = GetIt.instance<ReverterPagamentoUseCase>();

  List<Paciente> _pacientes = [];
  List<Treinamento> _treinamentosAtivos = [];
  Map<String, List<Pagamento>> _pagamentosPorTreinamento = {};
  Map<String, List<Sessao>> _sessoesPorTreinamento = {};

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  List<Treinamento> get treinamentosAtivos => _treinamentosAtivos;
  Map<String, List<Pagamento>> get pagamentosPorTreinamento => _pagamentosPorTreinamento;
  Map<String, List<Sessao>> get sessoesPorTreinamento => _sessoesPorTreinamento;

  // --- CORREÇÃO AQUI ---
  // O orElse agora retorna um PacienteModel para corresponder ao tipo da lista,
  // que vem do repositório como uma lista de PacienteModel.
  Paciente? getPacienteById(String id) => _pacientes.firstWhere((p) => p.id == id, orElse: () => PacienteModel(id: '', nome: 'Desconhecido', dataNascimento: DateTime.now(), nomeResponsavel: '', dataCadastro: DateTime.now(), status: 'inativo'));

  PagamentosViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    _setLoading(true);
    try {
      _pacientes = await _pacienteRepository.getPacientes().first;
      _treinamentosAtivos = await _treinamentoRepository.getTreinamentos().first.then((list) => list.where((t) => t.status == 'ativo').toList());
      
      _pagamentosPorTreinamento = {};
      final todosPagamentos = await _pagamentoRepository.getPagamentos().first;
      for (var pagamento in todosPagamentos) {
        _pagamentosPorTreinamento.putIfAbsent(pagamento.treinamentoId, () => []).add(pagamento);
      }
      
      _sessoesPorTreinamento = {};
      for (var treinamento in _treinamentosAtivos) {
        if (treinamento.tipoParcelamento == 'Por sessão') {
          final sessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(treinamento.id!);
          _sessoesPorTreinamento[treinamento.id!] = sessoes;
        }
      }

    } catch (e, stackTrace) {
      logger.e('Erro ao carregar dados de pagamentos', error: e, stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registrarPagamento(Pagamento pagamento) async {
    _setLoading(true);
    try {
      await _registrarPagamentoUseCase.call(
        treinamentoId: pagamento.treinamentoId,
        pacienteId: pagamento.pacienteId,
        formaPagamento: pagamento.formaPagamento,
        tipoParcelamento: pagamento.tipoParcelamento,
        guiaConvenio: pagamento.guiaConvenio,
        dataEnvioGuia: pagamento.dataEnvioGuia,
      );
      await loadData();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reverterPagamento(String pagamentoId) async {
    _setLoading(true);
    try {
      await _reverterPagamentoUseCase.call(pagamentoId);
      await loadData();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}