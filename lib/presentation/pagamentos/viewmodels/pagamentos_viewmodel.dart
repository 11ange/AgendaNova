// lib/presentation/pagamentos/viewmodels/pagamentos_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/entities/pagamento.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/usecases/sessao/atualizar_status_sessao_usecase.dart';
import 'package:agenda_treinamento/core/utils/logger.dart';

class PagamentosViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final TreinamentoRepository _treinamentoRepository = GetIt.instance<TreinamentoRepository>();
  final SessaoRepository _sessaoRepository = GetIt.instance<SessaoRepository>();
  final AtualizarStatusSessaoUseCase _atualizarStatusSessaoUseCase = GetIt.instance<AtualizarStatusSessaoUseCase>();

  List<Paciente> _pacientes = [];
  List<Treinamento> _treinamentosAtivos = [];
  final Map<String, List<Pagamento>> _pagamentosPorTreinamento = {};
  final Map<String, List<Sessao>> _sessoesPorTreinamento = {};

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  List<Treinamento> get treinamentosAtivos => _treinamentosAtivos;
  Map<String, List<Pagamento>> get pagamentosPorTreinamento => _pagamentosPorTreinamento;
  Map<String, List<Sessao>> get sessoesPorTreinamento => _sessoesPorTreinamento;

  Paciente? getPacienteById(String id) {
    try {
      return _pacientes.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  PagamentosViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    _setLoading(true);
    try {
      _pacientes = await _pacienteRepository.getPacientes().first;
      _treinamentosAtivos = await _treinamentoRepository.getTreinamentos().first.then((list) => 
          list.where((t) => t.status == 'ativo' || t.status == 'Pendente Pagamento' || t.status == 'cancelado').toList()
      );
      
      _treinamentosAtivos.sort((a, b) {
        final nomeA = getPacienteById(a.pacienteId)?.nome.toLowerCase() ?? '';
        final nomeB = getPacienteById(b.pacienteId)?.nome.toLowerCase() ?? '';
        return nomeA.compareTo(nomeB);
      });
      
      _pagamentosPorTreinamento.clear();
      for (var treinamento in _treinamentosAtivos) {
        if (treinamento.pagamentos != null) {
          _pagamentosPorTreinamento[treinamento.id!] = treinamento.pagamentos!;
        }
      }
      
      _sessoesPorTreinamento.clear();
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

  Future<void> confirmarPagamentoConvenio(Treinamento treinamento, DateTime dataEnvio) async {
    final novoPagamento = Pagamento(
      treinamentoId: treinamento.id!,
      pacienteId: treinamento.pacienteId,
      formaPagamento: treinamento.formaPagamento,
      status: 'Realizado',
      dataPagamento: dataEnvio,
      dataEnvioGuia: dataEnvio,
    );

    final treinamentoAtualizado = treinamento.copyWith(pagamentos: [novoPagamento]);
    await _treinamentoRepository.updateTreinamento(treinamentoAtualizado);
    await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(treinamento.id!);
    await loadData();
  }

  Future<void> updateDataEnvioGuiaConvenio(String treinamentoId, DateTime novaData) async {
    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null || treinamento.pagamentos == null || treinamento.pagamentos!.isEmpty) return;

    final pagamentoAtualizado = treinamento.pagamentos!.first.copyWith(
      dataPagamento: novaData,
      dataEnvioGuia: novaData,
    );
    final treinamentoAtualizado = treinamento.copyWith(pagamentos: [pagamentoAtualizado]);
    await _treinamentoRepository.updateTreinamento(treinamentoAtualizado);
    await loadData();
  }

  Future<void> reverterPagamentoConvenio(String treinamentoId) async {
    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null) return;

    final treinamentoAtualizado = treinamento.copyWith(pagamentos: []);
    await _treinamentoRepository.updateTreinamento(treinamentoAtualizado);
    await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(treinamento.id!);
    await loadData();
  }

  Future<void> confirmarRecebimentoConvenio(String treinamentoId, DateTime dataRecebimento) async {
    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null || treinamento.pagamentos == null || treinamento.pagamentos!.isEmpty) return;

    final pagamentoAtualizado = treinamento.pagamentos!.first.copyWith(dataRecebimentoConvenio: dataRecebimento);
    final treinamentoAtualizado = treinamento.copyWith(pagamentos: [pagamentoAtualizado]);
    await _treinamentoRepository.updateTreinamento(treinamentoAtualizado);
    // --- VERIFICAÇÃO ADICIONADA AQUI ---
    await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(treinamento.id!);
    await loadData();
  }

  Future<void> confirmarPagamentoParcela(Treinamento treinamento, int parcelaNum, DateTime dataPagamento) async {
    final novoPagamento = Pagamento(
      treinamentoId: treinamento.id!,
      pacienteId: treinamento.pacienteId,
      formaPagamento: treinamento.formaPagamento,
      tipoParcelamento: treinamento.tipoParcelamento,
      status: 'Realizado',
      dataPagamento: dataPagamento,
      parcelaNumero: parcelaNum,
      totalParcelas: 3,
    );

    List<Pagamento> pagamentosAtuais = List.from(treinamento.pagamentos ?? []);
    pagamentosAtuais.add(novoPagamento);
    
    final treinamentoAtualizado = treinamento.copyWith(pagamentos: pagamentosAtuais);
    await _treinamentoRepository.updateTreinamento(treinamentoAtualizado);
    await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(treinamento.id!);
    await loadData();
  }

  Future<void> updateDataPagamentoParcela(String treinamentoId, int parcelaNum, DateTime novaData) async {
    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null || treinamento.pagamentos == null) return;
    
    final pagamentosAtualizados = treinamento.pagamentos!.map((p) {
      if (p.parcelaNumero == parcelaNum) {
        return p.copyWith(dataPagamento: novaData);
      }
      return p;
    }).toList();

    final treinamentoAtualizado = treinamento.copyWith(pagamentos: pagamentosAtualizados);
    await _treinamentoRepository.updateTreinamento(treinamentoAtualizado);
    await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(treinamento.id!);
    await loadData();
  }

  Future<void> reverterPagamentoParcela(String treinamentoId, int parcelaNum) async {
    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null || treinamento.pagamentos == null) return;

    final pagamentosAtualizados = treinamento.pagamentos!.where((p) => p.parcelaNumero != parcelaNum).toList();
    
    final treinamentoAtualizado = treinamento.copyWith(pagamentos: pagamentosAtualizados);
    await _treinamentoRepository.updateTreinamento(treinamentoAtualizado);
    await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(treinamento.id!);
    await loadData();
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}