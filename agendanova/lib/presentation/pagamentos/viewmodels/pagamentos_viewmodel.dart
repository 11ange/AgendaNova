import 'package:flutter/material.dart';
import 'package:flutter_agenda_fono/core/services/firebase_service.dart';
import 'package:flutter_agenda_fono/data/datasources/firebase_datasource.dart';
import 'package:flutter_agenda_fono/data/repositories/pagamento_repository_impl.dart';
import 'package:flutter_agenda_fono/data/repositories/treinamento_repository_impl.dart';
import 'package:flutter_agenda_fono/data/repositories/sessao_repository_impl.dart';
import 'package:flutter_agenda_fono/data/repositories/paciente_repository_impl.dart'; // Para obter dados do paciente
import 'package:flutter_agenda_fono/domain/entities/pagamento.dart';
import 'package:flutter_agenda_fono/domain/entities/treinamento.dart';
import 'package:flutter_agenda_fono/domain/entities/paciente.dart';
import 'package:flutter_agenda_fono/domain/repositories/pagamento_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/treinamento_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/sessao_repository.dart';
import 'package:flutter_agenda_fono/domain/repositories/paciente_repository.dart';
import 'package:flutter_agenda_fono/domain/usecases/pagamento/registrar_pagamento_usecase.dart';
import 'package:flutter_agenda_fono/domain/usecases/pagamento/reverter_pagamento_usecase.dart';
import 'dart:async';

// ViewModel para a tela de Pagamentos
class PagamentosViewModel extends ChangeNotifier {
  final PagamentoRepository _pagamentoRepository;
  final TreinamentoRepository _treinamentoRepository;
  final SessaoRepository _sessaoRepository;
  final PacienteRepository _pacienteRepository;
  final RegistrarPagamentoUseCase _registrarPagamentoUseCase;
  final ReverterPagamentoUseCase _reverterPagamentoUseCase;

  bool _isLoading = false;
  List<Treinamento> _treinamentosComPagamentos = []; // Treinamentos ativos
  List<Paciente> _pacientes = []; // Para exibir o nome do paciente
  Map<String, List<Pagamento>> _pagamentosPorTreinamento = {}; // Pagamentos agrupados por treinamento

  bool get isLoading => _isLoading;
  List<Treinamento> get treinamentosComPagamentos => _treinamentosComPagamentos;
  List<Paciente> get pacientes => _pacientes;
  Map<String, List<Pagamento>> get pagamentosPorTreinamento => _pagamentosPorTreinamento;

  PagamentosViewModel({
    PagamentoRepository? pagamentoRepository,
    TreinamentoRepository? treinamentoRepository,
    SessaoRepository? sessaoRepository,
    PacienteRepository? pacienteRepository,
  })  : _pagamentoRepository = pagamentoRepository ?? PagamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        _treinamentoRepository = treinamentoRepository ?? TreinamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        _sessaoRepository = sessaoRepository ?? SessaoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        _pacienteRepository = pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        _registrarPagamentoUseCase = RegistrarPagamentoUseCase(
          pagamentoRepository ?? PagamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
          treinamentoRepository ?? TreinamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
          sessaoRepository ?? SessaoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        ),
        _reverterPagamentoUseCase = ReverterPagamentoUseCase(
          pagamentoRepository ?? PagamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
          sessaoRepository ?? SessaoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
          treinamentoRepository ?? TreinamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        ) {
    _listenToDataChanges();
  }

  void _listenToDataChanges() {
    // Escuta mudanças nos treinamentos
    _treinamentoRepository.getTreinamentos().listen((treinamentosList) async {
      _treinamentosComPagamentos = treinamentosList.where((t) => t.status == 'ativo').toList(); // Apenas treinamentos ativos
      await _loadRelatedData(); // Recarrega pacientes e pagamentos
      notifyListeners();
    }, onError: (error) {
      print('Erro ao carregar treinamentos: $error');
    });

    // Escuta mudanças nos pagamentos
    _pagamentoRepository.getPagamentos().listen((pagamentosList) {
      _pagamentosPorTreinamento = _groupPagamentosByTreinamento(pagamentosList);
      notifyListeners();
    }, onError: (error) {
      print('Erro ao carregar pagamentos: $error');
    });

    // Escuta mudanças nos pacientes
    _pacienteRepository.getPacientes().listen((pacientesList) {
      _pacientes = pacientesList;
      notifyListeners();
    }, onError: (error) {
      print('Erro ao carregar pacientes: $error');
    });
  }

  Future<void> _loadRelatedData() async {
    _setLoading(true);
    try {
      // Garante que pacientes e pagamentos sejam carregados e agrupados
      final allPagamentos = await _pagamentoRepository.getPagamentos().first;
      _pagamentosPorTreinamento = _groupPagamentosByTreinamento(allPagamentos);

      final allPacientes = await _pacienteRepository.getPacientes().first;
      _pacientes = allPacientes;
    } catch (e) {
      print('Erro ao carregar dados relacionados: $e');
    } finally {
      _setLoading(false);
    }
  }

  Map<String, List<Pagamento>> _groupPagamentosByTreinamento(List<Pagamento> pagamentos) {
    final Map<String, List<Pagamento>> grouped = {};
    for (var p in pagamentos) {
      if (!grouped.containsKey(p.treinamentoId)) {
        grouped[p.treinamentoId] = [];
      }
      grouped[p.treinamentoId]!.add(p);
    }
    return grouped;
  }

  // Carrega treinamentos (chamado na inicialização da tela)
  void loadTreinamentos() {
    // A escuta já é iniciada no construtor, então os dados serão carregados automaticamente.
  }

  // Registra um novo pagamento
  Future<void> registrarPagamento({
    required String treinamentoId,
    required String pacienteId,
    required String formaPagamento,
    String? tipoParcelamento,
    String? guiaConvenio,
    DateTime? dataEnvioGuia,
  }) async {
    _setLoading(true);
    try {
      await _registrarPagamentoUseCase.call(
        treinamentoId: treinamentoId,
        pacienteId: pacienteId,
        formaPagamento: formaPagamento,
        tipoParcelamento: tipoParcelamento,
        guiaConvenio: guiaConvenio,
        dataEnvioGuia: dataEnvioGuia,
      );
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Reverte um pagamento
  Future<void> reverterPagamento(String pagamentoId) async {
    _setLoading(true);
    try {
      await _reverterPagamentoUseCase.call(pagamentoId);
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

  @override
  void dispose() {
    _pagamentosPorTreinamento.clear(); // Limpa o mapa
    _treinamentosComPagamentos.clear(); // Limpa a lista
    _pacientes.clear(); // Limpa a lista
    super.dispose();
  }
}

