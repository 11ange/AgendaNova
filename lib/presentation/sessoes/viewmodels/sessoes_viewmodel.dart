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
      
      // Cria o objeto inicial (ainda sem ID)
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

      // 1. Envia para o banco e CAPTURA o ID retornado
      final newId = await _sessaoRepository.addSessao(blockedSessionInicial);
      
      // 2. Cria uma cópia da sessão agora com o ID correto
      final blockedSessionComId = blockedSessionInicial.copyWith(id: newId);

      // 3. Adiciona a sessão COM ID à lista local
      _sessoesDoMes.add(blockedSessionComId);
      
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
    _setLoading(true); // Indica processamento na UI
    try {
      // 1. Busca as sessões que já existem nesse dia (antes de bloquear o dia)
      final sessoesDoDia = await _sessaoRepository.getSessoesByDate(date).first;

      // 2. Filtra apenas as sessões 'Agendada' que são de treinamentos reais
      // (Ignora bloqueios manuais ou placeholders)
      final sessoesParaBloquear = sessoesDoDia.where((s) => 
        s.status == 'Agendada' && 
        s.treinamentoId != 'dia_bloqueado_completo' && 
        s.treinamentoId != 'bloqueio_manual'
      ).toList();

      // 3. Aplica a lógica de bloqueio individual para cada sessão encontrada.
      // Isso aciona o AtualizarStatusSessaoUseCase, que faz:
      // - Muda status para 'Bloqueada'
      // - Renumera as sessões futuras (n -> n-1)
      // - Gera uma sessão extra no final do treinamento
      for (var sessao in sessoesParaBloquear) {
        await _atualizarStatusSessaoUseCase.call(
          sessao: sessao, 
          novoStatus: 'Bloqueada'
        );
      }

      // 4. Por fim, define o dia como bloqueado globalmente no repositório.
      // Isso fará com que o dia apareça cinza/bloqueado na UI.
      await _sessaoRepository.setDayBlockedStatus(date, true);
      
      await onPageChanged(date);
    } catch (e) {
      debugPrint('Erro ao bloquear dia inteiro: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

 // Substitua o método unblockEntireDay existente por este:
  Future<void> unblockEntireDay(DateTime date) async {
    _setLoading(true);
    try {
      // 1. Desbloqueia o dia no repositório (Banco de Dados)
      await _sessaoRepository.setDayBlockedStatus(date, false);

      // 2. Realoca as sessões futuras para ocupar o espaço que abriu
      await _reajustarSessoesFuturas(date);

      // 3. Atualiza a tela
      await onPageChanged(date);
    } catch (e) {
      debugPrint('Erro ao desbloquear dia: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Adicione este novo método privado na classe:
  Future<void> _reajustarSessoesFuturas(DateTime dataDesbloqueada) async {
    final weekdayName = DateFormatter.getCapitalizedWeekdayName(dataDesbloqueada);

    // 1. Busca treinamentos ativos do dia
    final allTreinamentos = await _treinamentoRepository.getTreinamentos().first;
    final treinamentosAfetados = allTreinamentos.where((t) => 
      (t.status == 'ativo' || t.status == 'Pendente Pagamento') && 
      t.diaSemana == weekdayName
    ).toList();

    // Cache para evitar consultas repetidas (já marcamos o dia atual como livre)
    final Map<String, bool> blockedDaysCache = {
      DateFormat('yyyy-MM-dd').format(dataDesbloqueada): false
    };

    for (var treinamento in treinamentosAfetados) {
      if (treinamento.id == null) continue;

      final todasSessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(treinamento.id!);
      
      // Filtra sessões futuras agendadas
      final sessoesFuturas = todasSessoes.where((s) => 
        (DateUtils.isSameDay(s.dataHora, dataDesbloqueada) || s.dataHora.isAfter(dataDesbloqueada)) &&
        s.status == 'Agendada'
      ).toList();

      if (sessoesFuturas.isEmpty) continue;

      sessoesFuturas.sort((a, b) => a.dataHora.compareTo(b.dataHora));

      // Configura a data inicial para o dia que acabou de ser desbloqueado
      final horaParts = treinamento.horario.split(':');
      final horaTreino = int.parse(horaParts[0]);
      final minutoTreino = int.parse(horaParts[1]);

      DateTime dataCandidata = DateTime(
        dataDesbloqueada.year, 
        dataDesbloqueada.month, 
        dataDesbloqueada.day, 
        horaTreino, 
        minutoTreino
      );

      for (var sessao in sessoesFuturas) {
        bool diaValido = false;

        // Encontra o próximo dia livre
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

        // Se a data mudou, precisamos MOVER a sessão (Delete + Add)
        if (!DateUtils.isSameDay(sessao.dataHora, dataCandidata)) {
          // 1. Remove a sessão do dia antigo (Documento antigo)
          if (sessao.id != null) {
            await _sessaoRepository.deleteSessao(sessao.id!);
          }

          // 2. Cria a nova sessão com a nova data
          final novaSessao = sessao.copyWith(
            id: null, // Limpa o ID para gerar um novo baseado na nova data
            dataHora: dataCandidata,
          );

          // 3. Adiciona a sessão no novo dia (Documento novo)
          await _sessaoRepository.addSessao(novaSessao);
        }

        // Avança para a próxima semana para a próxima sessão da lista
        dataCandidata = dataCandidata.add(const Duration(days: 7));
      }
    }
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

  Future<void> trocarHorarioSessoesRestantes({
    required Sessao sessaoBase,
    required DateTime novaDataInicio,
    required String novoHorario,
  }) async {
    _setLoading(true);
    try {
      // 1. Verificar se o novo horário está disponível na agenda para aquele dia da semana
      final diaSemana = DateFormatter.getCapitalizedWeekdayName(novaDataInicio);
      final agenda = await _agendaDisponibilidadeRepository.getAgendaDisponibilidade().first;
      final horariosDisponiveis = agenda?.agenda[diaSemana] ?? [];

      if (!horariosDisponiveis.contains(novoHorario)) {
        throw Exception('Este horário não está disponível na agenda para $diaSemana.');
      }

      // 2. Buscar todas as sessões do treinamento que ainda são "Agendadas" 
      // a partir da sessão selecionada (inclusive ela)
      final todasSessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(sessaoBase.treinamentoId);
      final sessoesParaMover = todasSessoes.where((s) => 
        (s.numeroSessao >= sessaoBase.numeroSessao) && s.status == 'Agendada'
      ).toList();

      // 3. Verificar conflitos no novo horário/data para as novas datas previstas
      DateTime dataCandidata = novaDataInicio;
      final horaParts = novoHorario.split(':');
      final h = int.parse(horaParts[0]);
      final m = int.parse(horaParts[1]);

      for (int i = 0; i < sessoesParaMover.length; i++) {
        final dataVerificacao = dataCandidata.add(Duration(days: 7 * i));
        final sessoesNoDia = await _sessaoRepository.getSessoesByDate(dataVerificacao).first;
        
        final conflito = sessoesNoDia.any((s) => 
          s.dataHora.hour == h && 
          s.dataHora.minute == m && 
          s.status != 'Cancelada'
        );

        if (conflito) {
          throw Exception('Conflito no dia ${DateFormat('dd/MM').format(dataVerificacao)}: Horário já ocupado.');
        }
      }

      // 4. Executar a troca: Apagar as antigas e criar as novas
      for (var s in sessoesParaMover) {
        if (s.id != null) await _sessaoRepository.deleteSessao(s.id!);
      }

      List<Sessao> novasSessoes = [];
      for (int i = 0; i < sessoesParaMover.length; i++) {
        final novaDataHora = DateTime(
          dataCandidata.year, dataCandidata.month, dataCandidata.day, h, m
        ).add(Duration(days: 7 * i));

        novasSessoes.add(sessoesParaMover[i].copyWith(
          id: null, // Novo ID será gerado
          dataHora: novaDataHora,
          reagendada: true,
        ));
      }

      await _sessaoRepository.addMultipleSessoes(novasSessoes);
      
      // 5. Atualizar o treinamento (opcional: atualizar diaSemana e horario no TreinamentoRepository)
      final treinamento = await _treinamentoRepository.getTreinamentoById(sessaoBase.treinamentoId);
      if (treinamento != null) {
        await _treinamentoRepository.updateTreinamento(treinamento.copyWith(
          diaSemana: diaSemana,
          horario: novoHorario,
        ));
      }

      await onPageChanged(_currentFocusedMonth ?? novaDataInicio);
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
