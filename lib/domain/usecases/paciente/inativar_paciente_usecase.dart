import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart'; // Import necessário

// Use case para inativar um paciente
class InativarPacienteUseCase {
  final PacienteRepository _pacienteRepository;
  final TreinamentoRepository _treinamentoRepository; // Repositório adicionado

  InativarPacienteUseCase(
    this._pacienteRepository,
    this._treinamentoRepository, // Dependência adicionada
  );

  Future<void> call(String pacienteId) async {
    // --- CORREÇÃO AQUI: VALIDAÇÃO DE TREINAMENTO ATIVO ---
    // Regra de negócio: verificar se o paciente está vinculado a treinamentos ativos.
    final hasActiveTreinamento = await _treinamentoRepository.hasActiveTreinamento(pacienteId);
    if (hasActiveTreinamento) {
      throw Exception('Não é possível inativar, pois o paciente possui um treinamento ativo.');
    }

    await _pacienteRepository.inativarPaciente(pacienteId);
  }
}