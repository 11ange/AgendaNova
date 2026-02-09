import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';

class CancelarTreinamentoUseCase {
  final TreinamentoRepository _treinamentoRepository;
  final SessaoRepository _sessaoRepository;
  final PacienteRepository _pacienteRepository;

  CancelarTreinamentoUseCase(
    this._treinamentoRepository,
    this._sessaoRepository,
    this._pacienteRepository,
  );

  Future<void> call(String treinamentoId, String pacienteId) async {
    // 1. Busca todas as sessões vinculadas a este treinamento
    final sessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(treinamentoId);
    
    // 2. Apaga cada sessão encontrada
    for (var sessao in sessoes) {
      if (sessao.id != null) {
        await _sessaoRepository.deleteSessao(sessao.id!);
      }
    }

    // 3. Apaga o registro do treinamento
    await _treinamentoRepository.deleteTreinamento(treinamentoId);

    // 4. Garante que o paciente volte ao status 'ativo' (livre para novos agendamentos)
    final paciente = await _pacienteRepository.getPacienteById(pacienteId);
    if (paciente != null) {
      final pacienteAtualizado = paciente.copyWith(status: 'ativo');
      await _pacienteRepository.updatePaciente(pacienteAtualizado);
    }
  }
}