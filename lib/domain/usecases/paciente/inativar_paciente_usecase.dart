import 'package:agendanova/domain/repositories/paciente_repository.dart';
// Importe o repositório de agendamento quando ele for criado
// import 'package:agendanova/domain/repositories/agendamento_repository.dart';

// Use case para inativar um paciente
class InativarPacienteUseCase {
  final PacienteRepository _pacienteRepository;
  // final AgendamentoRepository _agendamentoRepository; // Descomentar quando AgendamentoRepository for criado

  InativarPacienteUseCase(
    this._pacienteRepository /*, this._agendamentoRepository*/,
  );

  Future<void> call(String pacienteId) async {
    // Regra de negócio: verificar se o paciente está vinculado a agendamentos ativos
    // Por enquanto, esta verificação será simulada ou deixada para implementação futura.
    // final hasActiveAppointments = await _agendamentoRepository.hasActiveAppointments(pacienteId);
    // if (hasActiveAppointments) {
    //   throw Exception('Não é possível inativar o paciente, pois ele possui agendamentos ativos.');
    // }

    await _pacienteRepository.inativarPaciente(pacienteId);
  }
}
