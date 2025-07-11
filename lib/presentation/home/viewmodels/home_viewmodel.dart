import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/entities/agenda_disponibilidade.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:agendanova/domain/repositories/agenda_disponibilidade_repository.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:agendanova/core/utils/logger.dart'; // Importa o logger

class HomeViewModel extends ChangeNotifier {
  final SessaoRepository _sessaoRepository = GetIt.instance<SessaoRepository>();
  final AgendaDisponibilidadeRepository _agendaRepository = GetIt.instance<AgendaDisponibilidadeRepository>();

  List<Sessao> _proximosAgendamentos = [];
  List<DateTime> _proximosHorariosDisponiveis = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Sessao> get proximosAgendamentos => _proximosAgendamentos;
  List<DateTime> get proximosHorariosDisponiveis => _proximosHorariosDisponiveis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HomeViewModel() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _sessaoRepository.getSessoes().first,
        _agendaRepository.getAgendaDisponibilidade().first,
      ]);

      final allSessoes = results[0] as List<Sessao>;
      final agenda = results[1] as AgendaDisponibilidade?;

      _processarProximosAgendamentos(allSessoes);
      if (agenda != null) {
        _processarProximosHorarios(allSessoes, agenda);
      }

    } catch (e, stackTrace) { // Captura o erro e o stack trace
      _errorMessage = "Erro ao carregar dados da tela inicial.";
      // CORREÇÃO: Usa o logger para registrar o erro
      logger.e("Erro em HomeViewModel", error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
