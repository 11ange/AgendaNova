import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/usecases/treinamento/criar_treinamento_usecase.dart';
import 'dart:async';

class TreinamentoDialogViewModel extends ChangeNotifier {
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository = GetIt.instance<AgendaDisponibilidadeRepository>();
  final TreinamentoRepository _treinamentoRepository = GetIt.instance<TreinamentoRepository>();
  final CriarTreinamentoUseCase _criarTreinamentoUseCase = GetIt.instance<CriarTreinamentoUseCase>();

  bool _isLoading = false;
  List<Paciente> _pacientesDisponiveis = [];
  Map<String, List<String>> _horariosDisponiveisPorDia = {};
  StreamSubscription? _treinamentosSubscription;
  List<Paciente> _todosPacientesAtivos = [];

  bool get isLoading => _isLoading;
  List<Paciente> get pacientes => _pacientesDisponiveis;
  List<String> horariosParaDia(String? dia) => _horariosDisponiveisPorDia[dia] ?? [];

  TreinamentoDialogViewModel() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _setLoading(true);
    await _treinamentosSubscription?.cancel();

    try {
      _todosPacientesAtivos = await _pacienteRepository.getPacientesAtivos().first;
      final agenda = await _agendaDisponibilidadeRepository.getAgendaDisponibilidade().first;
      if (agenda != null) {
        _horariosDisponiveisPorDia = agenda.agenda;
      }

      _treinamentosSubscription = _treinamentoRepository.getTreinamentos().listen((treinamentos) {
        final pacientesOcupados = treinamentos
            .where((t) => t.status == 'ativo' || t.status == 'Pendente Pagamento')
            .map((t) => t.pacienteId)
            .toSet();

        _pacientesDisponiveis = _todosPacientesAtivos
            .where((p) => !pacientesOcupados.contains(p.id))
            .toList();
            
        notifyListeners();
      });

    } catch (e) {
      // Handle error, maybe show a message to the user
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
    String? nomeConvenio,
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
        nomeConvenio: nomeConvenio,
      );
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

  @override
  void dispose() {
    _treinamentosSubscription?.cancel();
    super.dispose();
  }
}
