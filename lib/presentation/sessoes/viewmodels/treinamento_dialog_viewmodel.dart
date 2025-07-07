import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/entities/treinamento.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'package:agendanova/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';
import 'package:agendanova/domain/usecases/treinamento/criar_treinamento_usecase.dart';

class TreinamentoDialogViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository = GetIt.instance<AgendaDisponibilidadeRepository>();
  final TreinamentoRepository _treinamentoRepository = GetIt.instance<TreinamentoRepository>();
  final CriarTreinamentoUseCase _criarTreinamentoUseCase = GetIt.instance<CriarTreinamentoUseCase>();

  bool _isLoading = false;
  List<Paciente> _pacientes = [];
  Map<String, List<String>> _horariosDisponiveisPorDia = {};

  bool get isLoading => _isLoading;
  List<Paciente> get pacientes => _pacientes;
  List<String> horariosParaDia(String? dia) => _horariosDisponiveisPorDia[dia] ?? [];

  TreinamentoDialogViewModel() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _setLoading(true);
    try {
      // Carrega todos os treinamentos para saber quais pacientes já estão ativos
      final List<Treinamento> todosTreinamentos = await _treinamentoRepository.getTreinamentos().first;
      final List<String> pacientesComTreinamentoAtivo = todosTreinamentos
          .where((t) => t.status == 'ativo')
          .map((t) => t.pacienteId)
          .toList();

      // Carrega os pacientes ativos e depois filtra
      final List<Paciente> pacientesAtivos = await _pacienteRepository.getPacientesAtivos().first;
      _pacientes = pacientesAtivos
          .where((p) => !pacientesComTreinamentoAtivo.contains(p.id))
          .toList();

      // Carrega a agenda de disponibilidade
      final agenda = await _agendaDisponibilidadeRepository.getAgendaDisponibilidade().first;
      if (agenda != null) {
        _horariosDisponiveisPorDia = agenda.agenda;
      }
    } catch (e) {
      print('Erro ao carregar dados iniciais do diálogo: $e');
      _pacientes = []; // Garante que a lista esteja vazia em caso de erro
    } finally {
      _setLoading(false);
    }
  }

  Future<void> criarTreinamento({
    required String pacienteId,
    required String diaSemana,
    required String horario,
    required int numeroSessoesTotal,
    required DateTime dataInicio,
    required String formaPagamento,
    String? tipoParcelamento,
  }) async {
    _setLoading(true);
    try {
      await _criarTreinamentoUseCase.call(
        pacienteId: pacienteId,
        diaSemana: diaSemana,
        horario: horario,
        numeroSessoesTotal: numeroSessoesTotal,
        dataInicio: dataInicio,
        formaPagamento: formaPagamento,
        tipoParcelamento: tipoParcelamento,
      );
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