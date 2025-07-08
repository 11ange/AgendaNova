//import 'package:agendanova/domain/entities/treinamento.dart'; // Agendamento pode se referir a Treinamento

// Contrato (interface) para o repositório de Agendamentos
abstract class AgendamentoRepository {
  // TODO: Definir métodos específicos para o gerenciamento de agendamentos.
  // Por exemplo:
  // Future<List<Treinamento>> getAgendamentosAtivos();
  // Future<bool> checkConflictsWithAgenda(AgendaDisponibilidade agenda);
  // Future<bool> hasActiveAppointments(String pacienteId);

  // Exemplo de um método que pode ser necessário:
  Future<bool> hasActiveAppointments(String pacienteId);
}
