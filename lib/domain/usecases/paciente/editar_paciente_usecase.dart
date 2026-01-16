import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';

class EditarPacienteUseCase {
  final PacienteRepository _pacienteRepository;
  final TreinamentoRepository _treinamentoRepository;
  final SessaoRepository _sessaoRepository;

  EditarPacienteUseCase(
    this._pacienteRepository,
    this._treinamentoRepository,
    this._sessaoRepository,
  );

  Future<void> call(Paciente paciente) async {
    // Verificação de segurança: Não é possível editar um paciente sem ID
    if (paciente.id == null) {
      throw Exception('Não é possível editar um paciente sem ID.');
    }

    // 1. Atualiza o cadastro do paciente (operação original)
    await _pacienteRepository.updatePaciente(paciente);

    // 2. Inicia o processo de atualização em cascata das sessões
    // Busca todos os treinamentos deste paciente usando o ID garantido (paciente.id!)
    final treinamentos = await _treinamentoRepository.getTreinamentosByPacienteId(paciente.id!).first;

    for (var treino in treinamentos) {
      if (treino.id == null) continue;

      // Busca todas as sessões vinculadas a este treinamento
      final sessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(treino.id!);

      for (var sessao in sessoes) {
        // Verifica se o nome na sessão está desatualizado
        if (sessao.pacienteNome != paciente.nome) {
          // Cria uma cópia da sessão com o novo nome
          final sessaoAtualizada = sessao.copyWith(pacienteNome: paciente.nome);
          
          // Salva a alteração no banco
          await _sessaoRepository.updateSessao(sessaoAtualizada);
        }
      }
    }
  }
}