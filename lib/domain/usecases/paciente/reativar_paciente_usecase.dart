import 'package:agendanova/domain/repositories/paciente_repository.dart';

// Use case para reativar um paciente
class ReativarPacienteUseCase {
  final PacienteRepository _pacienteRepository;

  ReativarPacienteUseCase(this._pacienteRepository);

  Future<void> call(String pacienteId) async {
    // Não há regras de negócio complexas para reativação além de mudar o status.
    // A validação de ID existente é feita no repositório.
    await _pacienteRepository.reativarPaciente(pacienteId);
  }
}

