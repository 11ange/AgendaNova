import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';

// Use case para editar um paciente existente
class EditarPacienteUseCase {
  final PacienteRepository _pacienteRepository;

  EditarPacienteUseCase(this._pacienteRepository);

  Future<void> call(Paciente paciente) async {
    // Regra de negócio: verificar se o nome do paciente já existe, excluindo o próprio paciente que está sendo editado
    final exists = await _pacienteRepository.pacienteExistsByName(paciente.nome, excludeId: paciente.id);
    if (exists) {
      throw Exception('Já existe outro paciente com este nome cadastrado.');
    }

    // A idade é recalculada automaticamente na entidade Paciente.
    await _pacienteRepository.updatePaciente(paciente);
  }
}

