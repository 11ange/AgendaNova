import 'package:flutter/material.dart';
import 'package:agendanova/core/services/firebase_service.dart';
import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/repositories/sessao_repository_impl.dart';
import 'package:agendanova/data/repositories/treinamento_repository_impl.dart';
import 'package:agendanova/data/repositories/paciente_repository_impl.dart';
import 'package:agendanova/domain/entities/relatorio.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'package:agendanova/domain/usecases/relatorio/gerar_relatorio_mensal_global_usecase.dart';
import 'package:agendanova/domain/usecases/relatorio/gerar_relatorio_individual_paciente_usecase.dart';
import 'dart:async';

// ViewModel para a tela de Relatórios
class RelatoriosViewModel extends ChangeNotifier {
  final GerarRelatorioMensalGlobalUseCase _gerarRelatorioMensalGlobalUseCase;
  final GerarRelatorioIndividualPacienteUseCase _gerarRelatorioIndividualPacienteUseCase;
  final PacienteRepository _pacienteRepository;

  bool _isLoading = false;
  List<Paciente> _pacientes = [];

  bool get isLoading => _isLoading;
  List<Paciente> get pacientes => _pacientes;

  RelatoriosViewModel({
    SessaoRepository? sessaoRepository,
    TreinamentoRepository? treinamentoRepository,
    PacienteRepository? pacienteRepository,
  })  : _sessaoRepository = sessaoRepository ?? SessaoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        _treinamentoRepository = treinamentoRepository ?? TreinamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        _pacienteRepository = pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        _gerarRelatorioMensalGlobalUseCase = GerarRelatorioMensalGlobalUseCase(
          sessaoRepository ?? SessaoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
          treinamentoRepository ?? TreinamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
          pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        ),
        _gerarRelatorioIndividualPacienteUseCase = GerarRelatorioIndividualPacienteUseCase(
          sessaoRepository ?? SessaoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
          treinamentoRepository ?? TreinamentoRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
          pacienteRepository ?? PacienteRepositoryImpl(FirebaseDatasource(FirebaseService.instance)),
        );

  final SessaoRepository _sessaoRepository; // Adicionado para o construtor
  final TreinamentoRepository _treinamentoRepository; // Adicionado para o construtor

  // Carrega a lista de pacientes para o dropdown de relatório individual
  void loadPacientes() {
    _setLoading(true);
    _pacienteRepository.getPacientes().listen(
      (pacientesList) {
        _pacientes = pacientesList.where((p) => p.status == 'ativo').toList(); // Apenas pacientes ativos
        notifyListeners();
        _setLoading(false);
      },
      onError: (error) {
        print('Erro ao carregar pacientes para relatório: $error');
        _setLoading(false);
      },
    );
  }

  Future<Relatorio> gerarRelatorioMensalGlobal(int year, int month) async {
    _setLoading(true);
    try {
      return await _gerarRelatorioMensalGlobalUseCase.call(year, month);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Relatorio> gerarRelatorioIndividualPaciente(String pacienteId) async {
    _setLoading(true);
    try {
      return await _gerarRelatorioIndividualPacienteUseCase.call(pacienteId);
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

