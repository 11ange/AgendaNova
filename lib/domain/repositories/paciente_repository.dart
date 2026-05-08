import 'package:agenda_treinamento/domain/entities/paciente.dart'; // Importação adicionada/corrigida

// Contrato (interface) para o repositório de Pacientes
abstract class PacienteRepository {
  // Obtém um stream de todos os pacientes (ativos e inativos)
  Stream<List<Paciente>> getPacientes();

  // Obtém um stream de pacientes ativos
  Stream<List<Paciente>> getPacientesAtivos();

  // Obtém um stream de pacientes inativos
  Stream<List<Paciente>> getPacientesInativos();

  // Obtém um stream de pacientes arquivados (Soft Deleted)
  Stream<List<Paciente>> getPacientesArquivados();

  // Obtém um paciente pelo ID
  Future<Paciente?> getPacienteById(String id);

  // Adiciona um novo paciente
  Future<void> addPaciente(Paciente paciente);

  // Atualiza um paciente existente
  Future<void> updatePaciente(Paciente paciente);

  // Inativa um paciente (muda o status para 'inativo')
  Future<void> inativarPaciente(String id);

  // Reativa um paciente (muda o status para 'ativo')
  Future<void> reativarPaciente(String id);

  // Arquiva um paciente (Soft Delete) definindo a data de arquivamento
  Future<void> arquivarPaciente(String id);

  // Verifica se um paciente com o nome fornecido já existe (incluindo inativos)
  Future<bool> pacienteExistsByName(String nome, {String? excludeId});

  // Obtém um paciente pelo nome (exato)
  Future<Paciente?> getPacienteByName(String nome);

  // Obtém um paciente pelo nome normalizado (busca insensível a maiúsculas/minúsculas)
  Future<Paciente?> getPacienteByNormalizedName(String nomeNormalizado);
}
