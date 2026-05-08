import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/core/utils/date_formatter.dart';

// Exceção personalizada para quando um paciente duplicado é encontrado (Nome + Data)
class DuplicatePacienteException implements Exception {
  final Paciente existingPaciente;
  DuplicatePacienteException(this.existingPaciente);

  @override
  String toString() => 'Já existe um paciente com este nome e data de nascimento.';
}

// Exceção personalizada para quando um homônimo é encontrado (Apenas Nome)
class HomonymPacienteException implements Exception {
  final Paciente existingPaciente;
  HomonymPacienteException(this.existingPaciente);

  @override
  String toString() => 'Já existe um paciente cadastrado com este nome.';
}

// Use case para cadastrar um novo paciente
class CadastrarPacienteUseCase {
  final PacienteRepository _pacienteRepository;

  CadastrarPacienteUseCase(this._pacienteRepository);

  Future<void> call(Paciente paciente, {bool ignoreHomonym = false}) async {
    // 1. Normalização do nome para busca insensível
    final nomeNormalizado = Paciente.normalizeName(paciente.nome);

    // 2. Busca por nome normalizado
    final existing = await _pacienteRepository.getPacienteByNormalizedName(nomeNormalizado);
    
    if (existing != null) {
      final sameBirthDate = DateFormatter.formatDate(existing.dataNascimento) == 
                            DateFormatter.formatDate(paciente.dataNascimento);

      if (sameBirthDate) {
        // DUPLICADO CRÍTICO: Nome e Data iguais
        throw DuplicatePacienteException(existing);
      } else if (!ignoreHomonym) {
        // HOMÔNIMO: Mesmo nome, mas data diferente (lança exceção para confirmação no UI)
        throw HomonymPacienteException(existing);
      }
    }

    await _pacienteRepository.addPaciente(paciente);
  }
}
