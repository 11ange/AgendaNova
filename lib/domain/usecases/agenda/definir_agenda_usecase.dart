// lib/domain/usecases/agenda/definir_agenda_usecase.dart
import 'package:agendanova/domain/entities/agenda_disponibilidade.dart';
import 'package:agendanova/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:intl/intl.dart';

// Use case para definir a agenda de horários de atendimento
class DefinirAgendaUseCase {
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository;
  final SessaoRepository _sessaoRepository;

  DefinirAgendaUseCase(
    this._agendaDisponibilidadeRepository,
    this._sessaoRepository,
  );

  Future<void> call(AgendaDisponibilidade novaAgenda) async {
    // Busca a agenda atual para comparar com a nova
    final agendaAtual = await _agendaDisponibilidadeRepository.getAgendaDisponibilidade().first;
    final agendaAntigaMap = agendaAtual?.agenda ?? {};
    final novaAgendaMap = novaAgenda.agenda;

    List<String> horariosRemovidos = [];

    // Itera sobre a agenda antiga para encontrar horários que foram removidos na nova
    agendaAntigaMap.forEach((dia, horariosAntigos) {
      List<String> horariosNovos = novaAgendaMap[dia] ?? [];
      for (var horario in horariosAntigos) {
        if (!horariosNovos.contains(horario)) {
          horariosRemovidos.add('$dia-$horario');
        }
      }
    });

    if (horariosRemovidos.isNotEmpty) {
      // Busca todas as sessões futuras que estão agendadas
      final todasSessoes = await _sessaoRepository.getSessoes().first;
      final hoje = DateTime.now();
      final sessoesFuturasAgendadas = todasSessoes.where((s) => s.dataHora.isAfter(hoje) && s.status == 'Agendada').toList();
      
      List<String> conflitos = [];

      // Para cada horário removido, verifica se existe uma sessão futura agendada
      for (var horarioRemovido in horariosRemovidos) {
        final partes = horarioRemovido.split('-');
        final dia = partes[0];
        final horario = partes[1];

        bool temConflito = sessoesFuturasAgendadas.any((sessao) {
          final diaDaSemanaSessao = DateFormat('EEEE', 'pt_BR').format(sessao.dataHora);
          final horarioSessao = DateFormat('HH:mm').format(sessao.dataHora);
          
          return diaDaSemanaSessao.toLowerCase() == dia.toLowerCase() && horarioSessao == horario;
        });

        if (temConflito) {
          conflitos.add('$dia às $horario');
        }
      }

      // Se encontrar qualquer conflito, lança um erro e não salva a nova agenda
      if (conflitos.isNotEmpty) {
        throw Exception('Não é possível remover horários com sessões já agendadas. Conflito(s) em: ${conflitos.join(', ')}');
      }
    }

    // Se não houver conflitos, salva a nova agenda de disponibilidade
    await _agendaDisponibilidadeRepository.setAgendaDisponibilidade(novaAgenda);
  }
}