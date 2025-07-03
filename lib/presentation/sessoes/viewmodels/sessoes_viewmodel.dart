import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agendanova/core/services/firebase_service.dart';
import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/repositories/sessao_repository_impl.dart';
import 'package:agendanova/data/repositories/treinamento_repository_impl.dart';
import 'package:agendanova/data/repositories/agenda_disponibilidade_repository_impl.dart';
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

  List<Sessao> _sessoesDoMes = [];
  AgendaDisponibilidade? _agendaDisponibilidade;

  final _horariosCompletosStreamController = StreamController<Map<String, Sessao?>>.broadcast();
  Stream<Map<String, Sessao?>> get horariosCompletosStream => _horariosCompletosStreamController.stream;

  final _dailyStatusMapStreamController = StreamController<Map<DateTime, String>>.broadcast();
  Stream<Map<DateTime, String>> get dailyStatusMapStream => _dailyStatusMapStreamController.stream;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _currentSelectedDate;
  DateTime? _currentFocusedMonth;

  // Getters públicos para as datas
  DateTime? get currentSelectedDate => _currentSelectedDate;
  DateTime? get currentFocusedMonth => _currentFocusedMonth;


  SessoesViewModel()
      : _atualizarStatusSessaoUseCase = AtualizarStatusSessaoUseCase(
          GetIt.instance<SessaoRepository>(),
          GetIt.instance<TreinamentoRepository>(),
          GetIt.instance<AgendaDisponibilidadeRepository>(),
          GetIt.instance<PacienteRepository>(),
        ) {
    _listenToAgendaDisponibilidade();
    _horariosCompletosStreamController.add({});
    _dailyStatusMapStreamController.add({});
  }

  void _listenToAgendaDisponibilidade() {
    _agendaDisponibilidadeRepository.getAgendaDisponibilidade().listen(
      (agenda) {
        _agendaDisponibilidade = agenda;
        print('DEBUG: Agenda de disponibilidade carregada: ${_agendaDisponibilidade?.agenda}');
        if (_currentFocusedMonth != null) {
          _calculateAndEmitDailyStatus(_currentFocusedMonth!);
        }
        if (_currentSelectedDate != null) {
          _combineAndEmitSchedule(_currentSelectedDate!);
        }
      },
      onError: (error) {
        print('ERRO: ao carregar agenda de disponibilidade: $error');
      },
    );
  }

  void loadSessoesForMonth(DateTime focusedMonth) {
    _currentFocusedMonth = focusedMonth;
    _setLoading(true);
    print('DEBUG: Carregando sessões para o mês: $focusedMonth');

    _sessaoRepository.getSessoesByMonth(focusedMonth).listen(
      (sessoesList) {
        _sessoesDoMes = sessoesList;
        print('DEBUG: Sessões do mês carregadas: ${_sessoesDoMes.length} sessões');
        _calculateAndEmitDailyStatus(focusedMonth);
        if (_currentSelectedDate != null && _currentSelectedDate!.month == focusedMonth.month) {
          _combineAndEmitSchedule(_currentSelectedDate!);
        }
        _setLoading(false);
      },
      onError: (error) {
        _dailyStatusMapStreamController.addError(error);
        _setLoading(false);
        print('ERRO: ao carregar sessões para o mês: $error');
      },
    );
  }

  void loadSessoesForDay(DateTime date) {
    _currentSelectedDate = date;
    _combineAndEmitSchedule(date);
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

      if (availableTimesForDay.isEmpty) {
        dailyStatus[currentDay] = 'indisponivel';
      } else if (sessionsForCurrentDay.isEmpty) {
        dailyStatus[currentDay] = 'livre';
      } else if (sessionsForCurrentDay.length < availableTimesForDay.length) {
        dailyStatus[currentDay] = 'parcial';
      } else {
        dailyStatus[currentDay] = 'cheio';
      }
    }
    print('DEBUG: Daily status calculated: $dailyStatus');
    _dailyStatusMapStreamController.add(dailyStatus);
  }

  void _combineAndEmitSchedule(DateTime date) {
    final Map<String, Sessao?> combinedSchedule = {};
    final String weekdayName = _capitalizeFirstLetter(DateFormat('EEEE', 'pt_BR').format(date));
    print('DEBUG: Combinando agenda para $weekdayName ($date)');

    final List<String> availableTimesForDay = _agendaDisponibilidade?.agenda[weekdayName] ?? [];
    print('DEBUG: Horários disponíveis da agenda para $weekdayName: $availableTimesForDay');

    final List<Sessao> sessionsForSelectedDay = _sessoesDoMes
        .where((sessao) =>
            sessao.dataHora.year == date.year &&
            sessao.dataHora.month == date.month &&
            sessao.dataHora.day == date.day)
        .toList();

    Set<String> timesToDisplay = availableTimesForDay.toSet();
    for (var sessao in sessionsForSelectedDay) {
      timesToDisplay.add(DateFormat('HH:mm').format(sessao.dataHora));
    }

    for (String timeSlot in timesToDisplay.toList()..sort()) {
      final sessaoExistente = sessionsForSelectedDay.firstWhereOrNull(
        (sessao) => DateFormat('HH:mm').format(sessao.dataHora) == timeSlot,
      );

      if (sessaoExistente != null) {
        combinedSchedule[timeSlot] = sessaoExistente;
      } else if (availableTimesForDay.contains(timeSlot)) {
        combinedSchedule[timeSlot] = null;
      } else {
        combinedSchedule[timeSlot] = null;
      }
    }

    print('DEBUG: Final combinedSchedule being added: $combinedSchedule');
    _horariosCompletosStreamController.add(combinedSchedule);
    notifyListeners();
  }

  Future<void> updateSessaoStatus(Sessao sessao, String novoStatus, {bool? desmarcarTodasFuturas}) async {
    _setLoading(true);
    try {
      await _atualizarStatusSessaoUseCase.call(
        sessao: sessao,
        novoStatus: novoStatus,
        desmarcarTodasFuturas: desmarcarTodasFuturas,
      );
      if (_currentFocusedMonth != null) {
        loadSessoesForMonth(_currentFocusedMonth!);
      }
      if (_currentSelectedDate != null) {
        _combineAndEmitSchedule(_currentSelectedDate!);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markPaymentAsRealizado(String sessaoId) async {
    _setLoading(true);
    try {
      final sessao = _sessoesDoMes.firstWhere((s) => s.id == sessaoId);
      await _sessaoRepository.updateSessao(
        sessao.copyWith(statusPagamento: 'Realizado', dataPagamento: DateTime.now()),
      );
      if (_currentFocusedMonth != null) {
        loadSessoesForMonth(_currentFocusedMonth!);
      }
      if (_currentSelectedDate != null) {
        _combineAndEmitSchedule(_currentSelectedDate!);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> undoPayment(String sessaoId) async {
    _setLoading(true);
    try {
      final sessao = _sessoesDoMes.firstWhere((s) => s.id == sessaoId);
      await _sessaoRepository.updateSessao(
        sessao.copyWith(statusPagamento: 'Pendente', dataPagamento: null),
      );
      if (_currentFocusedMonth != null) {
        loadSessoesForMonth(_currentFocusedMonth!);
      }
      if (_currentSelectedDate != null) {
        _combineAndEmitSchedule(_currentSelectedDate!);
      }
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
