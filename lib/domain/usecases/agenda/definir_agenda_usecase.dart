// lib/domain/usecases/agenda/definir_agenda_usecase.dart

import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';
//import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:intl/intl.dart';

class DefinirAgendaUseCase {
  final AgendaDisponibilidadeRepository agendaRepository;
  final SessaoRepository sessaoRepository;

  DefinirAgendaUseCase(this.agendaRepository, this.sessaoRepository);

  Future<void> call(AgendaDisponibilidade novaAgenda) async {
    // Obtém a agenda atual
    //final agendaAtual = await agendaRepository.getAgendaDisponibilidade().first;

    // Obtém todas as sessões futuras
    final sessoesFuturas = await sessaoRepository.getSessoes().first;

    for (final sessao in sessoesFuturas) {
      final dia = DateFormat('EEEE', 'pt_BR').format(sessao.dataHora).toLowerCase();
      final hora = DateFormat('HH:mm').format(sessao.dataHora);

      // Checa se o horário da sessão futura foi removido na nova agenda
      if (!novaAgenda.temHorario(dia, hora)) {
        throw Exception('Não é possível remover um horário com sessões futuras');
      }
    }

    // Se não houver conflitos, salva a nova agenda
    await agendaRepository.setAgendaDisponibilidade(novaAgenda);
  }
}

// extensão de utilidade para verificar se a agenda possui um horário
extension AgendaDisponibilidadeExt on AgendaDisponibilidade {
  bool temHorario(String dia, String hora) {
    final horarios = agenda[dia];
    return horarios != null && horarios.contains(hora);
  }
}