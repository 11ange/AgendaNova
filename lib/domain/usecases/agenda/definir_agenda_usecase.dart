// lib/domain/usecases/agenda/definir_agenda_usecase.dart

import 'package:agenda_treinamento/core/utils/date_formatter.dart'; // Importe o helper
import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:intl/intl.dart';

class DefinirAgendaUseCase {
  final AgendaDisponibilidadeRepository agendaRepository;
  final SessaoRepository sessaoRepository;

  DefinirAgendaUseCase(this.agendaRepository, this.sessaoRepository);

  Future<void> call(AgendaDisponibilidade novaAgenda) async {
    // 1. Obter a agenda como ela está salva no banco ANTES da alteração.
    final agendaAtual = await agendaRepository.getAgendaDisponibilidade().first ??
        AgendaDisponibilidade(agenda: {});

    // 2. Identificar quais horários foram efetivamente REMOVIDOS pelo usuário.
    final Set<String> horariosRemovidos = {};
    agendaAtual.agenda.forEach((dia, horarios) {
      for (final hora in horarios) {
        // Se um horário que existia na agenda antiga NÃO existe na nova, ele foi removido.
        if (!(novaAgenda.agenda[dia]?.contains(hora) ?? false)) {
          // Usa a chave capitalizada, que é o padrão do app. Ex: "Segunda-feira@10:00"
          horariosRemovidos.add('$dia@$hora');
        }
      }
    });

    // Se nenhum horário foi removido, não há necessidade de verificar as sessões.
    if (horariosRemovidos.isNotEmpty) {
      // 3. Obter todas as sessões futuras que estão agendadas.
      final sessoesFuturas = (await sessaoRepository.getSessoes().first)
          .where((s) => s.dataHora.isAfter(DateTime.now()) && s.status == 'Agendada')
          .toList();

      // 4. Verificar se alguma sessão futura existe em um dos horários que foram REMOVIDOS.
      for (final sessao in sessoesFuturas) {
        // --- CORREÇÃO AQUI: Usa o novo helper para garantir a formatação correta ---
        final diaSessao = DateFormatter.getCapitalizedWeekdayName(sessao.dataHora);
        final horaSessao = DateFormat('HH:mm').format(sessao.dataHora);
        final chaveSessao = '$diaSessao@$horaSessao';

        if (horariosRemovidos.contains(chaveSessao)) {
          // Se houver conflito, lança a exceção.
          throw Exception(
              'Não é possível remover o horário de $diaSessao às $horaSessao, pois existem sessões futuras agendadas.');
        }
      }
    }

    // Se não houver conflitos, salva a nova agenda.
    await agendaRepository.setAgendaDisponibilidade(novaAgenda);
  }
}