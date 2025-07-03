import 'package:agendanova/domain/entities/agenda_disponibilidade.dart';
import 'package:agendanova/domain/repositories/agenda_disponibilidade_repository.dart';
// Importe o repositório de agendamento quando ele for criado
// import 'package:agendanova/domain/repositories/agendamento_repository.dart';

// Use case para definir a agenda de horários de atendimento
class DefinirAgendaUseCase {
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository;
  // final AgendamentoRepository _agendamentoRepository; // Descomentar quando AgendamentoRepository for criado

  DefinirAgendaUseCase(
    this._agendaDisponibilidadeRepository /*, this._agendamentoRepository*/,
  );

  Future<void> call(AgendaDisponibilidade novaAgenda) async {
    // Regra de negócio: Inclusão e exclusão de horários deve validar se do dia atual para frente
    // existe algum agendamento nele.

    // TODO: Implementar a validação de conflito com agendamentos existentes
    // Por enquanto, esta validação será simulada ou deixada para implementação futura.
    // var conflitos = await _agendamentoRepository.checkConflictsWithAgenda(novaAgenda);
    // if (conflitos.isNotEmpty) {
    //   throw Exception('Conflito de horários com agendamentos existentes: ${conflitos.join(', ')}');
    // }

    await _agendaDisponibilidadeRepository.setAgendaDisponibilidade(novaAgenda);
  }
}
