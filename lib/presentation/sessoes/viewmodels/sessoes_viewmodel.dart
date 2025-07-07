import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/entities/agenda_disponibilidade.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';
import 'package:agendanova/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'package:agendanova/domain/usecases/sessao/atualizar_status_sessao_usecase.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// ViewModel para a tela de Sessões
class SessoesViewModel extends ChangeNotifier {
  final SessaoRepository _sessaoRepository = GetIt.instance<SessaoRepository>();
  final TreinamentoRepository _treinamentoRepository = GetIt.instance<TreinamentoRepository>();
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository = GetIt.instance<AgendaDisponibilidadeRepository>();
  final PacienteRepository _pacienteRepository = GetIt.instance<PacienteRepository>();
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
  StreamSubscription? _agendaSubscription;
  StreamSubscription? _sessoesSubscription;
  bool _agendaDataReceived = false;
  bool _sessoesDataReceived = false;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  SessoesViewModel()
      : _atualizarStatusSessaoUseCase = AtualizarStatusSessaoUseCase(
          GetIt.instance<SessaoRepository>(),
          GetIt.instance<TreinamentoRepository>(),
          GetIt.instance<AgendaDisponibilidadeRepository>(),
          GetIt.instance<PacienteRepository>(),
        );

  void setInitialSelectedDay(DateTime date) {
    _currentSelectedDate = date;
  }

  void loadSessoesForMonth(DateTime focusedMonth) {
    if (_currentFocusedMonth != null &&
        focusedMonth.year == _currentFocusedMonth!.year &&
        focusedMonth.month == _currentFocusedMonth!.month) {
      return;
    }

    _currentFocusedMonth = focusedMonth;
    _setLoading(true);
    _agendaDataReceived = false;
    _sessoesDataReceived = false;

    _agendaSubscription?.cancel();
    _sessoesSubscription?.cancel();

    _agendaSubscription = _agendaDisponibilidadeRepository.getAgendaDisponibilidade().listen(
      (agenda) {
        _agendaDisponibilidade = agenda;
        _agendaDataReceived = true;
        _processDataAndNotify();
      },
      onError: (error) => print('Erro ao carregar agenda: $error'),
    );

    _sessoesSubscription = _sessaoRepository.getSessoesByMonth(focusedMonth).listen(
      (sessoesList) {
        _sessoesDoMes = sessoesList;
        _sessoesDataReceived = true;
        _processDataAndNotify();
      },
      onError: (error) => print('Erro ao carregar sessões: $error'),
    );
  }

  void _processDataAndNotify() {
    if (_agendaDataReceived && _sessoesDataReceived) {
      if (_currentFocusedMonth != null) {
        _calculateAndEmitDailyStatus(_currentFocusedMonth!);
      }
      if (_currentSelectedDate != null) {
        _combineAndEmitSchedule(_currentSelectedDate!);
      }
      _isInitialized = true;
      _setLoading(false);
    }
  }

  void loadSessoesForDay(DateTime date) {
    _currentSelectedDate = date;
    if (_isInitialized) {
      _combineAndEmitSchedule(date);
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _calculateAndEmitDailyStatus(DateTime focusedMonth) {
    final Map<DateTime, String> dailyStatus = {};
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
        dailyStatus[DateUtils.dateOnly(currentDay)] = 'indisponivel';
      } else if (availableTimesForDay.isEmpty) {
        dailyStatus[DateUtils.dateOnly(currentDay)] = 'indisponivel';
      } else if (sessionsForCurrentDay.isEmpty) {
        dailyStatus[DateUtils.dateOnly(currentDay)] = 'livre';
      } else if (sessionsForCurrentDay.length < availableTimesForDay.length) {
        dailyStatus[DateUtils.dateOnly(currentDay)] = 'parcial';
      } else {
        dailyStatus[DateUtils.dateOnly(currentDay)] = 'cheio';
      }
    }
    _dailyStatusMapStreamController.add(dailyStatus);
  }

  void _combineAndEmitSchedule(DateTime date) {
    final Map<String, Sessao?> combinedSchedule = {};
    final String weekdayName = _capitalizeFirstLetter(DateFormat('EEEE', 'pt_BR').format(date));
    
    final List<String> availableTimesFromAgenda = _agendaDisponibilidade?.agenda[weekdayName] ?? [];
    
    final List<Sessao> sessionsForSelectedDay = _sessoesDoMes
        .where((sessao) =>
            sessao.dataHora.year == date.year &&
            sessao.dataHora.month == date.month &&
            sessao.dataHora.day == date.day)
        .toList();

    bool isDayBlocked = sessionsForSelectedDay.any((s) => s.treinamentoId == 'dia_bloqueado_completo' && s.status == 'Bloqueada');

    if (isDayBlocked) {
      for (String timeSlot in availableTimesFromAgenda.toList()..sort()) {
        combinedSchedule[timeSlot] = Sessao(
          id: '${DateFormat('yyyy-MM-dd').format(date)}-${timeSlot.replaceAll(':', '')}',
          treinamentoId: 'dia_bloqueado_completo',
          pacienteId: 'dia_bloqueado_completo',
          pacienteNome: 'Dia Bloqueado',
          dataHora: DateTime(date.year, date.month, date.day, int.parse(timeSlot.split(':')[0]), int.parse(timeSlot.split(':')[1])),
          numeroSessao: 0,
          status: 'Bloqueada',
          statusPagamento: 'N/A',
          formaPagamento: 'N/A',
          agendamentoStartDate: date,
          totalSessoes: 0,
          reagendada: false,
          observacoes: 'Dia inteiro bloqueado',
        );
      }
    } else {
      Set<String> timesToDisplay = <String>{};
      
      for (String agendaTime in availableTimesFromAgenda) {
        timesToDisplay.add(agendaTime);
      }

      for (var sessao in sessionsForSelectedDay) {
        timesToDisplay.add(DateFormat('HH:mm').format(sessao.dataHora));
      }

      final List<String> sortedTimesToDisplay = timesToDisplay.toList()..sort();

      for (String timeSlot in sortedTimesToDisplay) {
        final sessaoExistente = sessionsForSelectedDay.firstWhereOrNull(
          (sessao) => DateFormat('HH:mm').format(sessao.dataHora) == timeSlot,
        );

        if (sessaoExistente != null) {
          combinedSchedule[timeSlot] = sessaoExistente;
        } else {
          combinedSchedule[timeSlot] = null;
        }
      }
    }
    _horariosCompletosStreamController.add(combinedSchedule);
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
        totalSessoes: 0, observacoes: 'Bloqueado manualmente',
      );
      await _sessaoRepository.addSessao(blockedSession);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBlockedTimeSlot(String sessionId) async {
    _setLoading(true);
    try {
      await _sessaoRepository.deleteSessao(sessionId);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> blockEntireDay(DateTime date) async {
    _setLoading(true);
    try {
      await _sessaoRepository.setDayBlockedStatus(date, true);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> unblockEntireDay(DateTime date) async {
    _setLoading(true);
    try {
      await _sessaoRepository.setDayBlockedStatus(date, false);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSessaoStatus(Sessao sessao, String novoStatus, {bool? desmarcarTodasFuturas}) async {
    _setLoading(true);
    try {
      await _atualizarStatusSessaoUseCase.call(
        sessao: sessao, novoStatus: novoStatus, desmarcarTodasFuturas: desmarcarTodasFuturas,
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

  @override
  void dispose() {
    _agendaSubscription?.cancel();
    _sessoesSubscription?.cancel();
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