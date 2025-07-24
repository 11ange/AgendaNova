import 'package:agenda_treinamento/domain/entities/agenda_disponibilidade.dart';

// Contrato (interface) para o repositório de AgendaDisponibilidade
abstract class AgendaDisponibilidadeRepository {
  // Obtém um stream da disponibilidade de horários
  Stream<AgendaDisponibilidade?> getAgendaDisponibilidade();

  // Define ou atualiza a disponibilidade de horários
  Future<void> setAgendaDisponibilidade(AgendaDisponibilidade agenda);
}

