import 'package:agenda_treinamento/domain/entities/treinamento.dart';

// Contrato (interface) para o repositório de Treinamentos
abstract class TreinamentoRepository {
  // Obtém um stream de todos os treinamentos
  Stream<List<Treinamento>> getTreinamentos();

  // Obtém um treinamento pelo ID
  Future<Treinamento?> getTreinamentoById(String id);

  // Obtém treinamentos por ID do paciente
  Stream<List<Treinamento>> getTreinamentosByPacienteId(String pacienteId);

  // Adiciona um novo treinamento
  Future<String> addTreinamento(Treinamento treinamento); // Retorna o ID do novo treinamento

  // Atualiza um treinamento existente
  Future<void> updateTreinamento(Treinamento treinamento);

  // Exclui um treinamento pelo ID (MÉTODO ADICIONADO)
  Future<void> deleteTreinamento(String id);

  // Verifica se um paciente já possui um treinamento em andamento
  Future<bool> hasActiveTreinamento(String pacienteId);

  // Verifica se há sobreposição de treinamentos para um dado dia e horário
  Future<bool> hasOverlap(String diaSemana, String horario, {String? excludeTreinamentoId});
}