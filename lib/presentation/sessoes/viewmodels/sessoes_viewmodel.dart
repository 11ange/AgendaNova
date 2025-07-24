import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';
import 'package:agenda_treinamento/domain/entities/treinamento.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/usecases/sessao/atualizar_status_sessao_usecase.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SessoesViewModel extends ChangeNotifier {
  final SessaoRepository _sessaoRepository = GetIt.instance<SessaoRepository>();
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository = GetIt.instance<AgendaDisponibilidadeRepository>();
  final TreinamentoRepository _treinamentoRepository = GetIt.instance<TreinamentoRepository>();
  final AtualizarStatusSessaoUseCase _atualizarStatusSessaoUseCase;

  // Stream Controllers
  final _horariosCompletosStreamController = StreamController<Map<String, Sessao?>>.broadcast();
  Stream<Map<String, Sessao?>> get horariosCompletosStream => _horariosCompletosStreamController.stream;

  final _dailyStatusMapStreamController = StreamController<Map<DateTime, String>>.broadcast();
  Stream<Map<DateTime, String>> get dailyStatusMapStream => _dailyStatusMapStreamController.stream;

  // State
  bool _isLoading = true;
  bool _isInitialized = false;
  DateTime? _currentSelectedDate;
  DateTime? _currentFocusedMonth;
  AgendaDisponibilidade? _agendaDisponibilidade;
  List<Sessao> _sessoesDoMes = [];
  final Map<String, List<Treinamento>> _treinamentosPorPaciente = {};
  List<Treinamento> _treinamentosDoPacienteSelecionado = [];

  // State properties for initial data
  Map<DateTime, String> dailyStatus = {};
  Map<String, Sessao?> horariosCompletos = {};

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  List<Treinamento> get treinamentosDoPacienteSelecionado => _treinamentosDoPacienteSelecionado;

  SessoesViewModel()
      : _atualizarStatusSessaoUseCase = AtualizarStatusSessaoUseCase(
          GetIt.instance<SessaoRepository>(),
          GetIt.instance<TreinamentoRepository>(),
          GetIt.instance<AgendaDisponibilidadeRepository>(),
          GetIt.instance<PacienteRepository>(),
        );

  Future<void> initialize(DateTime focusedDay) async {
    _currentFocusedMonth = focusedDay;
    _currentSelectedDate = focusedDay;
    _setLoading(true);

    try {
      final results = await Future.wait([
        _agendaDisponibilidadeRepository.getAgendaDisponibilidade().first,
        _sessaoRepository.getSessoesByMonth(focusedDay).first,
        _treinamentoRepository.getTreinamentos().first,
      ]);

      _agendaDisponibilidade = results[0] as AgendaDisponibilidade?;
      _sessoesDoMes = results[1] as List<Sessao>;
      final allTrainings = results[2] as List<Treinamento>;

      _treinamentosPorPaciente.clear();
      for (var treinamento in allTrainings) {
        _treinamentosPorPaciente.putIfAbsent(treinamento.pacienteId, () => []).add(treinamento);
      }

      _isInitialized = true;
      _processDataAndNotify();
    } catch (e) {
      // Handle error
    } finally {
      _setLoading(false);
    }
  }

  void _processDataAndNotify() {
    if (!_isInitialized) return;

    if (_currentFocusedMonth != null) {
      _calculateAndEmitDailyStatus(_currentFocusedMonth!);
    }
    if (_currentSelectedDate != null) {
      _combineAndEmitSchedule(_currentSelectedDate!);
    }
  }

  void loadSessoesForDay(DateTime date) {
    _currentSelectedDate = date;
    if (_isInitialized) {
      _combineAndEmitSchedule(date);
    }
  }
  
  Future<void> onPageChanged(DateTime focusedMonth) async {
    _currentFocusedMonth = focusedMonth;
    _setLoading(true);
    try {
       _sessoesDoMes = await _sessaoRepository.getSessoesByMonth(focusedMonth).first;
       _processDataAndNotify();
    } catch(e) {
       // Handle error
    } finally {
       _setLoading(false);
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _calculateAndEmitDailyStatus(DateTime focusedMonth) {
    final Map<DateTime, String> statusMap = {};
    final int daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      final currentDay = DateTime(focusedMonth.year, focusedMonth.month, i);
      final String weekdayName = _capitalizeFirstLetter(DateFormat('EEEE', 'pt_BR').format(currentDay));
      final List<String> availableTimesForDay = _agendaDisponibilidade?.agenda[weekdayName] ?? [];

      final List<Sessao> sessionsForCurrentDay = _sessoesDoMes
          .where((sessao) =>
              sessao.dataHora.year == currentDay.year &&
              sessao.dataHora.month == currentDay.month &&
              sessao.dataHora.day == currentDay.day)
          .toList();

      bool isDayBlocked = sessionsForCurrentDay.any((s) => s.treinamentoId == 'dia_bloqueado_completo' && s.status == 'Bloqueada');

      if (isDayBlocked) {
        statusMap[DateUtils.dateOnly(currentDay)] = 'indisponivel';
      } else if (availableTimesForDay.isEmpty) {
        statusMap[DateUtils.dateOnly(currentDay)] = 'indisponivel';
      } else if (sessionsForCurrentDay.where((s) => s.status != 'Cancelada').isEmpty) {
        statusMap[DateUtils.dateOnly(currentDay)] = 'livre';
      } else if (sessionsForCurrentDay.length < availableTimesForDay.length) {
        statusMap[DateUtils.dateOnly(currentDay)] = 'parcial';
      } else {
        statusMap[DateUtils.dateOnly(currentDay)] = 'cheio';
      }
    }
    dailyStatus = statusMap;
    _dailyStatusMapStreamController.add(statusMap);
  }

  void _combineAndEmitSchedule(DateTime date) {
    final Map<String, Sessao?> scheduleMap = {};
    final String weekdayName = _capitalizeFirstLetter(DateFormat('EEEE', 'pt_BR').format(date));
    
    final List<String> availableTimesFromAgenda = _agendaDisponibilidade?.agenda[weekdayName] ?? [];
    
    final List<Sessao> sessionsForSelectedDay = _sessoesDoMes
        .where((sessao) =>
            sessao.dataHora.year == date.year &&
            sessao.dataHora.month == date.month &&
            sessao.dataHora.day == date.day)
        .toList();

    bool isDayBlocked = sessionsForSelectedDay.any((s) => s.treinamentoId == 'dia_bloqueado_completo');

    if (isDayBlocked) {
      final blockedSession = sessionsForSelectedDay.firstWhere((s) => s.treinamentoId == 'dia_bloqueado_completo');
      for (String timeSlot in availableTimesFromAgenda.toList()..sort()) {
         scheduleMap[timeSlot] = blockedSession;
      }
    } else {
      Set<String> timesToDisplay = Set.from(availableTimesFromAgenda);
      for (var sessao in sessionsForSelectedDay) {
        timesToDisplay.add(DateFormat('HH:mm').format(sessao.dataHora));
      }

      final List<String> sortedTimesToDisplay = timesToDisplay.toList()..sort();

      for (String timeSlot in sortedTimesToDisplay) {
        final sessaoExistente = sessionsForSelectedDay.firstWhereOrNull(
          (sessao) => DateFormat('HH:mm').format(sessao.dataHora) == timeSlot,
        );
        scheduleMap[timeSlot] = sessaoExistente;
      }
    }
    horariosCompletos = scheduleMap;
    
    // Atualiza a lista de treinamentos para o paciente do dia selecionado
    if (sessionsForSelectedDay.isNotEmpty) {
      final pacienteId = sessionsForSelectedDay.first.pacienteId;
      _treinamentosDoPacienteSelecionado = _treinamentosPorPaciente[pacienteId] ?? [];
    } else {
      _treinamentosDoPacienteSelecionado = [];
    }
    
    _horariosCompletosStreamController.add(scheduleMap);
    notifyListeners();
  }

  Future<void> blockTimeSlot(String timeSlot, DateTime date) async {
    _setLoading(true);
    try {
      final DateTime blockedDateTime = DateTime(
        date.year, date.month, date.day, int.parse(timeSlot.split(':')[0]), int.parse(timeSlot.split(':')[1]),
      );
      final blockedSession = Sessao(
        id: null, treinamentoId: 'bloqueio_manual', pacienteId: 'bloqueio_manual',
        pacienteNome: 'Horário Bloqueado', dataHora: blockedDateTime, numeroSessao: 0, status: 'Bloqueada',
        statusPagamento: 'N/A', formaPagamento: 'N/A', agendamentoStartDate: blockedDateTime,
        totalSessoes: 0, observacoes: 'Bloqueado manualmente', reagendada: false
      );
      await _sessaoRepository.addSessao(blockedSession);
      _sessoesDoMes.add(blockedSession);
      _processDataAndNotify();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBlockedTimeSlot(String sessionId) async {
    await _sessaoRepository.deleteSessao(sessionId);
    _sessoesDoMes.removeWhere((s) => s.id == sessionId);
    _processDataAndNotify();
  }

  Future<void> blockEntireDay(DateTime date) async {
     await _sessaoRepository.setDayBlockedStatus(date, true);
     await onPageChanged(date);
  }

  Future<void> unblockEntireDay(DateTime date) async {
     await _sessaoRepository.setDayBlockedStatus(date, false);
     await onPageChanged(date);
  }

  Future<void> updateSessaoStatus(Sessao sessao, String novoStatus, {bool? desmarcarTodasFuturas}) async {
    await _atualizarStatusSessaoUseCase.call(
      sessao: sessao, novoStatus: novoStatus, desmarcarTodasFuturas: desmarcarTodasFuturas,
    );
    if(_currentFocusedMonth != null) {
      await onPageChanged(_currentFocusedMonth!);
    }
  }

  Future<void> confirmarPagamentoSessao(Sessao sessao, DateTime dataPagamento) async {
    _setLoading(true);
    try {
      final sessaoAtualizada = sessao.copyWith(
        statusPagamento: 'Realizado',
        dataPagamento: dataPagamento,
      );
      await _sessaoRepository.updateSessao(sessaoAtualizada);
      await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(sessao.treinamentoId);
      if (_currentFocusedMonth != null) {
        await onPageChanged(_currentFocusedMonth!);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reverterPagamentoSessao(Sessao sessao) async {
    _setLoading(true);
    try {
      final sessaoAtualizada = sessao.copyWith(
        statusPagamento: 'Pendente',
        dataPagamento: null,
      );
      await _sessaoRepository.updateSessao(sessaoAtualizada);
      await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(sessao.treinamentoId);
      if (_currentFocusedMonth != null) {
        await onPageChanged(_currentFocusedMonth!);
      }
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
    _horariosCompletosStreamController.close();
    _dailyStatusMapStreamController.close();
    super.dispose();
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
