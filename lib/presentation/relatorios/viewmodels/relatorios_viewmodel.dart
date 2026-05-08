import 'package:flutter/material.dart';
import 'package:agenda_treinamento/domain/entities/relatorio.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/usecases/relatorio/gerar_relatorio_mensal_global_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/relatorio/gerar_relatorio_individual_paciente_usecase.dart';
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

  RelatoriosViewModel(
    this._gerarRelatorioMensalGlobalUseCase,
    this._gerarRelatorioIndividualPacienteUseCase,
    this._pacienteRepository,
  );

  // Carrega a lista de pacientes para o dropdown de relatório individual
  void loadPacientes() {
    _setLoading(true);
    _pacienteRepository.getPacientes().listen(
      (pacientesList) {
        _pacientes = pacientesList.where((p) => p.status == 'ativo').toList();
        notifyListeners();
        _setLoading(false);
      },
      onError: (error) {
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
