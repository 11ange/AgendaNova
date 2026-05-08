import 'package:flutter/material.dart';
import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';
import 'package:agenda_treinamento/domain/entities/pagamento.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/pagamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:agenda_treinamento/core/utils/logger.dart';
import 'package:agenda_treinamento/domain/usecases/auth/sign_out_usecase.dart';
import 'package:agenda_treinamento/core/services/firebase_service.dart';
import 'package:agenda_treinamento/domain/usecases/sessao/atualizar_status_sessao_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final SessaoRepository _sessaoRepository;
  final AgendaDisponibilidadeRepository _agendaRepository;
  final PagamentoRepository _pagamentoRepository;
  final PacienteRepository _pacienteRepository;
  final SignOutUseCase _signOutUseCase;
  final AtualizarStatusSessaoUseCase _atualizarStatusSessaoUseCase;

  List<Sessao> _proximosAgendamentos = [];
  List<DateTime> _proximosHorariosDisponiveis = [];
  int _sessoesHojeCount = 0;
  int _pagamentosPendentesCount = 0;
  int _aniversariantesMesCount = 0;
  Sessao? _proximaSessao;
  
  bool _isLoading = true;
  String? _errorMessage;

  List<Sessao> get proximosAgendamentos => _proximosAgendamentos;
  List<DateTime> get proximosHorariosDisponiveis => _proximosHorariosDisponiveis;
  int get sessoesHojeCount => _sessoesHojeCount;
  int get pagamentosPendentesCount => _pagamentosPendentesCount;
  int get aniversariantesMesCount => _aniversariantesMesCount;
  Sessao? get proximaSessao => _proximaSessao;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HomeViewModel(
    this._sessaoRepository,
    this._agendaRepository,
    this._pagamentoRepository,
    this._pacienteRepository,
    this._signOutUseCase,
    this._atualizarStatusSessaoUseCase,
  ) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseService.instance.migrarRegistrosAntigos();

      final results = await Future.wait([
        _sessaoRepository.getSessoes().first,
        _agendaRepository.getAgendaDisponibilidade().first,
        _pagamentoRepository.getPagamentos().first,
        _pacienteRepository.getPacientesAtivos().first,
      ]);

      final allSessoes = results[0] as List<Sessao>;
      final agenda = results[1] as AgendaDisponibilidade?;
      final allPagamentos = results[2] as List<Pagamento>;
      final pacientesAtivos = results[3] as List<Paciente>;

      _processarMetricas(allSessoes, allPagamentos, pacientesAtivos);
      _processarProximosAgendamentos(allSessoes);
      if (agenda != null) {
        _processarProximosHorarios(allSessoes, agenda);
      }

    } catch (e, stackTrace) {
      _errorMessage = "Erro ao carregar dados da tela inicial.";
      logger.e("Erro em HomeViewModel", error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processarMetricas(List<Sessao> sessoes, List<Pagamento> pagamentos, List<Paciente> pacientes) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    // Sessões de hoje
    _sessoesHojeCount = sessoes.where((s) {
      final dataSessao = DateTime(s.dataHora.year, s.dataHora.month, s.dataHora.day);
      return dataSessao.isAtSameMomentAs(hoje) && s.status == 'Agendada';
    }).length;

    // Próxima sessão (agora ou no futuro próximo hoje)
    final sessoesFuturasHoje = sessoes.where((s) => 
      s.status == 'Agendada' && 
      s.dataHora.isAfter(agora) &&
      s.dataHora.isBefore(hoje.add(const Duration(days: 1)))
    ).toList();
    
    if (sessoesFuturasHoje.isNotEmpty) {
      sessoesFuturasHoje.sort((a, b) => a.dataHora.compareTo(b.dataHora));
      _proximaSessao = sessoesFuturasHoje.first;
    } else {
      _proximaSessao = null;
    }

    // Pagamentos pendentes
    _pagamentosPendentesCount = pagamentos.where((p) => p.status == 'Pendente').length;

    // Aniversariantes do mês
    _aniversariantesMesCount = pacientes.where((p) => p.dataNascimento.month == agora.month).length;
  }

  Future<void> marcarComoRealizada(Sessao sessao) async {
    try {
      await _atualizarStatusSessaoUseCase.call(
        sessao: sessao,
        novoStatus: 'Realizada',
      );
      await loadInitialData(); // Atualiza as métricas
    } catch (e) {
      logger.e("Erro ao marcar sessão como realizada na Home", error: e);
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase.call();
  }

  void _processarProximosAgendamentos(List<Sessao> sessoes) {
    final agora = DateTime.now();
    _proximosAgendamentos = sessoes
        .where((s) => s.status == 'Agendada' && s.dataHora.isAfter(agora))
        .toList();
    _proximosAgendamentos.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    
    if (_proximosAgendamentos.length > 3) {
      _proximosAgendamentos = _proximosAgendamentos.sublist(0, 3);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void _processarProximosHorarios(List<Sessao> sessoes, AgendaDisponibilidade agenda) {
    List<DateTime> vagas = [];
    DateTime diaAtual = DateTime.now();

    for (int i = 0; i < 30 && vagas.length < 3; i++) {
      DateTime diaParaVerificar = DateUtils.addDaysToDate(diaAtual, i);
      
      final diaDaSemana = _capitalize(DateFormat('EEEE', 'pt_BR').format(diaParaVerificar));
      final horariosDoDia = agenda.agenda[diaDaSemana];

      if (horariosDoDia != null && horariosDoDia.isNotEmpty) {
        horariosDoDia.sort();
        
        for (var horario in horariosDoDia) {
          final hora = int.parse(horario.split(':')[0]);
          final minuto = int.parse(horario.split(':')[1]);
          final dataHoraVaga = DateTime(diaParaVerificar.year, diaParaVerificar.month, diaParaVerificar.day, hora, minuto);

          if (dataHoraVaga.isAfter(DateTime.now())) {
            bool ocupado = sessoes.any((s) => s.dataHora.isAtSameMomentAs(dataHoraVaga) && s.status != 'Cancelada');
            if (!ocupado) {
              vagas.add(dataHoraVaga);
              if (vagas.length >= 3) break;
            }
          }
        }
      }
    }
    _proximosHorariosDisponiveis = vagas;
  }
}
