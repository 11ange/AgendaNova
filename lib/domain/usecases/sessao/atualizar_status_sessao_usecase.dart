import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/entities/treinamento.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';
import 'package:agendanova/domain/repositories/agenda_disponibilidade_repository.dart'; // Para verificar bloqueios
import 'package:agendanova/core/utils/date_time_helper.dart';

// Use case para atualizar o status de uma sessão
class AtualizarStatusSessaoUseCase {
  final SessaoRepository _sessaoRepository;
  final TreinamentoRepository _treinamentoRepository;
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository;

  AtualizarStatusSessaoUseCase(
    this._sessaoRepository,
    this._treinamentoRepository,
    this._agendaDisponibilidadeRepository,
  );

  Future<void> call({
    required Sessao sessao,
    required String novoStatus,
    bool? desmarcarTodasFuturas, // Apenas para status "Cancelada"
  }) async {
    // Regra de Negócio: Qualquer sessão com status de "Agendada" pode ser marcada como "Realizada", "Falta", "Cancelada" ou "Bloqueada".
    if (sessao.status == 'Agendada') {
      if (!['Realizada', 'Falta', 'Cancelada', 'Bloqueada'].contains(novoStatus)) {
        throw Exception('Status inválido para sessão agendada.');
      }
    }
    // Regra de Negócio: Qualquer sessão com status de "Realizada", "Falta", "Cancelada" ou "Bloqueada" somente pode ser revertida para "Agendada".
    else {
      if (novoStatus != 'Agendada') {
        throw Exception('Sessão só pode ser revertida para "Agendada" a partir do status atual.');
      }
    }

    final originalStatus = sessao.status;
    Sessao sessaoAtualizada = sessao.copyWith(status: novoStatus);

    // Lógica para "Cancelada" ou "Bloqueada" (cria sessão extra)
    if ((novoStatus == 'Cancelada' || novoStatus == 'Bloqueada') && originalStatus == 'Agendada') {
      // Se desmarcarTodasFuturas for true, encerra o treinamento
      if (novoStatus == 'Cancelada' && desmarcarTodasFuturas == true) {
        // Obter todas as sessões futuras deste treinamento a partir da sessão atual
        final allSessions = await _sessaoRepository.getSessoesByTreinamentoId(sessao.treinamentoId).first;
        final sessionsToCancel = allSessions
            .where((s) => s.numeroSessao >= sessao.numeroSessao && s.status == 'Agendada')
            .toList();

        // Atualizar o status de todas as sessões futuras para "Cancelada"
        for (var s in sessionsToCancel) {
          await _sessaoRepository.updateSessao(s.copyWith(status: 'Cancelada'));
        }
        // TODO: Marcar treinamento como "cancelado" ou "encerrado" se todas as sessões foram canceladas
        // Isso exigiria um use case de "EncerrarTreinamento" ou lógica no TreinamentoRepository.
      } else {
        // Cria uma sessão extra ao final do ciclo e ajusta numeração
        await _gerarSessaoExtraEReajustarNumeracao(sessao.treinamentoId, sessao.pacienteId, sessao.numeroSessao);
      }
    }
    // Lógica para reverter para "Agendada" (remove sessão extra e reajusta numeração)
    else if (novoStatus == 'Agendada' && (originalStatus == 'Cancelada' || originalStatus == 'Bloqueada')) {
      await _removerSessaoExtraEReajustarNumeracao(sessao.treinamentoId, sessao.numeroSessao);
    }

    // Lógica para "Falta" com pagamento diferente de convênio
    if (novoStatus == 'Falta' &&
        originalStatus == 'Agendada' &&
        sessao.statusPagamento != 'Convenio') { // Assumindo que o statusPagamento da sessão reflete o do treinamento
      sessaoAtualizada = sessaoAtualizada.copyWith(statusPagamento: 'Pendente', dataPagamento: null);
      // Cria uma sessão extra e ajusta numeração (já tratado acima)
      await _gerarSessaoExtraEReajustarNumeracao(sessao.treinamentoId, sessao.pacienteId, sessao.numeroSessao);
    }

    // Não é permitido marcar uma sessão como "Realizada" sem o pagamento correspondente.
    if (novoStatus == 'Realizada' && sessao.statusPagamento == 'Pendente') {
      throw Exception('Não é possível marcar a sessão como "Realizada" sem o pagamento correspondente.');
    }

    await _sessaoRepository.updateSessao(sessaoAtualizada);
  }

  // Lógica para gerar sessão extra e reajustar numeração
  Future<void> _gerarSessaoExtraEReajustarNumeracao(String treinamentoId, String pacienteId, int sessaoOriginalNumero) async {
    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null) return;

    final todasSessoes = await _sessaoRepository.getSessoesByTreinamentoId(treinamentoId).first;
    final ultimaSessao = todasSessoes.reduce((a, b) => a.numeroSessao > b.numeroSessao ? a : b);

    // Ajustar numeração das sessões posteriores
    for (var sessao in todasSessoes) {
      if (sessao.numeroSessao > sessaoOriginalNumero) {
        await _sessaoRepository.updateSessao(sessao.copyWith(numeroSessao: sessao.numeroSessao - 1));
      }
    }

    // Encontrar o próximo dia disponível para a sessão extra
    DateTime nextDate = ultimaSessao.dataHora.add(const Duration(days: 7)); // Começa na próxima semana
    final agendaDisponibilidade = await _agendaDisponibilidadeRepository.getAgendaDisponibilidade().first;
    final horariosDisponiveisNoDia = agendaDisponibilidade?.agenda[treinamento.diaSemana] ?? [];

    while (true) {
      final potentialDate = DateTimeHelper.getNextWeekday(nextDate, treinamento.diaSemana);
      final potentialDateTime = DateTime(
        potentialDate.year,
        potentialDate.month,
        potentialDate.day,
        int.parse(treinamento.horario.split(':')[0]),
        int.parse(treinamento.horario.split(':')[1]),
      );

      // TODO: Verificar se o horário não está bloqueado para a data potencial
      // Isso exigiria uma coleção de "Bloqueios" ou um campo em "Disponibilidade" para datas específicas.
      // Por enquanto, assumimos que se o horário está na agenda, ele está disponível.

      // Verifica se já existe uma sessão agendada para este horário (evitar sobreposição)
      final sessoesNoDia = await _sessaoRepository.getSessoesByDate(potentialDate).first;
      final isOverlapping = sessoesNoDia.any((s) =>
          s.dataHora.hour == potentialDateTime.hour &&
          s.dataHora.minute == potentialDateTime.minute &&
          s.status != 'Cancelada' && s.status != 'Bloqueada'); // Não considera sessões canceladas/bloqueadas como sobreposição

      if (!isOverlapping && horariosDisponiveisNoDia.contains(treinamento.horario)) {
        nextDate = potentialDateTime;
        break;
      }
      nextDate = potentialDate.add(const Duration(days: 7)); // Tenta a próxima semana
    }

    final novaSessaoExtra = Sessao(
      treinamentoId: treinamentoId,
      pacienteId: pacienteId,
      dataHora: nextDate,
      numeroSessao: treinamento.numeroSessoesTotal, // Recebe o número total de sessões
      status: 'Agendada',
      statusPagamento: 'Pendente', // Por padrão, pagamento pendente
      dataPagamento: null,
      observacoes: null,
    );
    await _sessaoRepository.addSessao(novaSessaoExtra);
  }

  // Lógica para remover sessão extra e reajustar numeração
  Future<void> _removerSessaoExtraEReajustarNumeracao(String treinamentoId, int sessaoRevertidaNumero) async {
    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null) return;

    final todasSessoes = await _sessaoRepository.getSessoesByTreinamentoId(treinamentoId).first;

    // Encontrar a sessão extra (a última sessão com o número total de sessões)
    final sessaoExtra = todasSessoes.firstWhere(
      (s) => s.numeroSessao == treinamento.numeroSessoesTotal,
      orElse: () => throw Exception('Sessão extra não encontrada para remoção.'),
    );

    await _sessaoRepository.deleteSessao(sessaoExtra.id!);

    // Reajustar numeração das sessões posteriores
    for (var sessao in todasSessoes) {
      if (sessao.numeroSessao >= sessaoRevertidaNumero && sessao.id != sessaoExtra.id) {
        await _sessaoRepository.updateSessao(sessao.copyWith(numeroSessao: sessao.numeroSessao + 1));
      }
    }
  }
}

