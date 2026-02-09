// lib/presentation/sessoes/viewmodels/sessoes_viewmodel.dart
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
import 'package:agenda_treinamento/core/utils/date_formatter.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:collection/collection.dart'; // Pacote correto para firstWhereOrNull

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

  Map<DateTime, String> dailyStatus = {};
  Map<String, Sessao?> horariosCompletos = {};

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  List<Treinamento> get treinamentosDoPacienteSelecionado => _treinamentosDoPacienteSelecionado;
  AgendaDisponibilidade? get agendaDisponibilidade => _agendaDisponibilidade;

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
      debugPrint('Erro init: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _processDataAndNotify() {
    if (!_isInitialized) return;
    if (_currentFocusedMonth != null) _calculateAndEmitDailyStatus(_currentFocusedMonth!);
    if (_currentSelectedDate != null) _combineAndEmitSchedule(_currentSelectedDate!);
  }

  void loadSessoesForDay(DateTime date) {
    _currentSelectedDate = date;
    if (_isInitialized) _combineAndEmitSchedule(date);
  }
  
  Future<void> onPageChanged(DateTime focusedMonth) async {
    _currentFocusedMonth = focusedMonth;
    _setLoading(true);
    try {
       _sessoesDoMes = await _sessaoRepository.getSessoesByMonth(focusedMonth).first;
       _processDataAndNotify();
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
        // Uso correto do firstWhereOrNull do pacote collection
        final sessaoExistente = sessionsForSelectedDay.firstWhereOrNull(
          (sessao) => DateFormat('HH:mm').format(sessao.dataHora) == timeSlot,
        );
        scheduleMap[timeSlot] = sessaoExistente;
      }
    }
    horariosCompletos = scheduleMap;
    
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
      
      final blockedSessionInicial = Sessao(
        id: null, 
        treinamentoId: 'bloqueio_manual', 
        pacienteId: 'bloqueio_manual',
        pacienteNome: 'Horário Bloqueado', 
        dataHora: blockedDateTime, 
        numeroSessao: 0, 
        status: 'Bloqueada',
        statusPagamento: 'N/A', 
        formaPagamento: 'N/A', 
        agendamentoStartDate: blockedDateTime,
        totalSessoes: 0, 
        observacoes: 'Bloqueado manualmente', 
        reagendada: false
      );

      final newId = await _sessaoRepository.addSessao(blockedSessionInicial);
      final blockedSessionComId = blockedSessionInicial.copyWith(id: newId);
      _sessoesDoMes.add(blockedSessionComId);
      _processDataAndNotify();
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
    _setLoading(true); 
    try {
      final sessoesDoDia = await _sessaoRepository.getSessoesByDate(date).first;
      final sessoesParaBloquear = sessoesDoDia.where((s) => 
        s.status == 'Agendada' && s.treinamentoId != 'dia_bloqueado_completo' && s.treinamentoId != 'bloqueio_manual'
      ).toList();

      for (var sessao in sessoesParaBloquear) {
        await _atualizarStatusSessaoUseCase.call(sessao: sessao, novoStatus: 'Bloqueada');
      }

      await _sessaoRepository.setDayBlockedStatus(date, true);
      await onPageChanged(date);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> unblockEntireDay(DateTime date) async {
    _setLoading(true);
    try {
      await _sessaoRepository.setDayBlockedStatus(date, false);
      await _reajustarSessoesFuturas(date);
      await onPageChanged(date);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _reajustarSessoesFuturas(DateTime dataDesbloqueada) async {
    final weekdayName = DateFormatter.getCapitalizedWeekdayName(dataDesbloqueada);
    final allTreinamentos = await _treinamentoRepository.getTreinamentos().first;
    final treinamentosAfetados = allTreinamentos.where((t) => 
      (t.status == 'ativo' || t.status == 'Pendente Pagamento') && t.diaSemana == weekdayName
    ).toList();

    final Map<String, bool> blockedDaysCache = {DateFormat('yyyy-MM-dd').format(dataDesbloqueada): false};

    for (var treinamento in treinamentosAfetados) {
      if (treinamento.id == null) continue;
      final todasSessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(treinamento.id!);
      final sessoesFuturas = todasSessoes.where((s) => 
        (DateUtils.isSameDay(s.dataHora, dataDesbloqueada) || s.dataHora.isAfter(dataDesbloqueada)) && s.status == 'Agendada'
      ).toList();

      if (sessoesFuturas.isEmpty) continue;
      sessoesFuturas.sort((a, b) => a.dataHora.compareTo(b.dataHora));

      final horaParts = treinamento.horario.split(':');
      final horaTreino = int.parse(horaParts[0]);
      final minutoTreino = int.parse(horaParts[1]);
      DateTime dataCandidata = DateTime(dataDesbloqueada.year, dataDesbloqueada.month, dataDesbloqueada.day, horaTreino, minutoTreino);

      for (var sessao in sessoesFuturas) {
        bool diaValido = false;
        while (!diaValido) {
          final dataKey = DateFormat('yyyy-MM-dd').format(dataCandidata);
          if (!blockedDaysCache.containsKey(dataKey)) {
             final sessoesDoDia = await _sessaoRepository.getSessoesByDate(dataCandidata).first;
             final isBlocked = sessoesDoDia.any((s) => s.status == 'Bloqueada');
             blockedDaysCache[dataKey] = isBlocked;
          }
          if (blockedDaysCache[dataKey] == true) {
             dataCandidata = dataCandidata.add(const Duration(days: 7));
          } else {
             diaValido = true;
          }
        }

        if (!DateUtils.isSameDay(sessao.dataHora, dataCandidata)) {
          if (sessao.id != null) await _sessaoRepository.deleteSessao(sessao.id!);
          final novaSessao = sessao.copyWith(id: null, dataHora: dataCandidata);
          await _sessaoRepository.addSessao(novaSessao);
        }
        dataCandidata = dataCandidata.add(const Duration(days: 7));
      }
    }
  }

  Future<void> updateSessaoStatus(Sessao sessao, String novoStatus, {bool? desmarcarTodasFuturas}) async {
    await _atualizarStatusSessaoUseCase.call(
      sessao: sessao, novoStatus: novoStatus, desmarcarTodasFuturas: desmarcarTodasFuturas,
    );
    if(_currentFocusedMonth != null) await onPageChanged(_currentFocusedMonth!);
  }

  Future<void> trocarHorarioSessoesRestantes({
    required Sessao sessaoBase,
    required DateTime novaDataInicio,
    required String novoHorario,
    bool ignorarBloqueios = false,
  }) async {
    _setLoading(true);
    try {
      final todasSessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(sessaoBase.treinamentoId);
      final sessoesParaMover = todasSessoes
          .where((s) => s.numeroSessao >= sessaoBase.numeroSessao && s.status == 'Agendada')
          .toList();
      
      sessoesParaMover.sort((a, b) => a.numeroSessao.compareTo(b.numeroSessao));

      final horaParts = novoHorario.split(':');
      final h = int.parse(horaParts[0]);
      final m = int.parse(horaParts[1]);

      List<DateTime> novasDatasCalculadas = [];
      DateTime dataCandidata = novaDataInicio;

      for (int i = 0; i < sessoesParaMover.length; i++) {
        bool dataValida = false;
        
        while (!dataValida) {
          final sessoesNoDia = await _sessaoRepository.getSessoesByDate(dataCandidata).first;
          
          final temBloqueio = sessoesNoDia.any((s) => 
            (s.status == 'Bloqueada') && 
            (s.treinamentoId == 'dia_bloqueado_completo' || (s.dataHora.hour == h && s.dataHora.minute == m))
          );

          if (temBloqueio) {
            if (!ignorarBloqueios) {
              throw 'BLOQUEIO_DETECTADO'; 
            }
            dataCandidata = dataCandidata.add(const Duration(days: 7));
            continue; 
          }

          final temConflitoPaciente = sessoesNoDia.any((s) => 
            s.dataHora.hour == h && s.dataHora.minute == m && 
            s.status != 'Cancelada' && s.status != 'Bloqueada'
          );

          if (temConflitoPaciente) {
            throw 'Conflito em ${DateFormat('dd/MM').format(dataCandidata)}: Horário já ocupado.';
          }

          dataValida = true;
        }
        
        novasDatasCalculadas.add(DateTime(dataCandidata.year, dataCandidata.month, dataCandidata.day, h, m));
        dataCandidata = dataCandidata.add(const Duration(days: 7));
      }

      for (int i = 0; i < sessoesParaMover.length; i++) {
        final sOld = sessoesParaMover[i];
        if (sOld.id != null) await _sessaoRepository.deleteSessao(sOld.id!);
        
        final novaSessao = sOld.copyWith(id: null, dataHora: novasDatasCalculadas[i], reagendada: true);
        await _sessaoRepository.addSessao(novaSessao);
      }
      
      if (_currentFocusedMonth != null) await onPageChanged(_currentFocusedMonth!);

    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> confirmarPagamentoSessao(Sessao sessao, DateTime dataPagamento) async {
    _setLoading(true);
    try {
      final sessaoAtualizada = sessao.copyWith(statusPagamento: 'Realizado', dataPagamento: dataPagamento);
      await _sessaoRepository.updateSessao(sessaoAtualizada);
      await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(sessao.treinamentoId);
      if (_currentFocusedMonth != null) await onPageChanged(_currentFocusedMonth!);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reverterPagamentoSessao(Sessao sessao) async {
    _setLoading(true);
    try {
      final sessaoAtualizada = sessao.copyWith(statusPagamento: 'Pendente', dataPagamento: null);
      await _sessaoRepository.updateSessao(sessaoAtualizada);
      await _atualizarStatusSessaoUseCase.verificarEAtualizarStatusTreinamento(sessao.treinamentoId);
      if (_currentFocusedMonth != null) await onPageChanged(_currentFocusedMonth!);
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