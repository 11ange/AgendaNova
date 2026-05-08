import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';

// Use Case para arquivar um paciente (Soft Delete)
class ArquivarPacienteUseCase {
  final PacienteRepository repository;

  ArquivarPacienteUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.arquivarPaciente(id);
  }
}
