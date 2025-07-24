import 'package:agenda_treinamento/domain/entities/paciente.dart'; // Importação corrigida
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart'; // Importação corrigida

// Use case para cadastrar um novo paciente
class CadastrarPacienteUseCase {
  final PacienteRepository _pacienteRepository;

  CadastrarPacienteUseCase(this._pacienteRepository);

  Future<void> call(Paciente paciente) async {
    // Regra de negócio: verificar se já existe paciente com o nome fornecido
    final exists = await _pacienteRepository.pacienteExistsByName(
      paciente.nome,
    );
    if (exists) {
      throw Exception('Já existe um paciente com este nome cadastrado.');
    }

    // A idade é calculada na entidade Paciente, não precisa ser passada aqui.
    // O status 'ativo' é definido na criação do paciente.

    await _pacienteRepository.addPaciente(paciente);
  }
}
