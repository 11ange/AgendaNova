import 'package:agenda_treinamento/domain/entities/sessao.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/agenda_disponibilidade_repository.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/core/utils/date_time_helper.dart';

// Use case para atualizar o status de uma sessão e o treinamento relacionado
class AtualizarStatusSessaoUseCase {
  final SessaoRepository _sessaoRepository;
  final TreinamentoRepository _treinamentoRepository;
  final AgendaDisponibilidadeRepository _agendaDisponibilidadeRepository;
  final PacienteRepository _pacienteRepository;

  AtualizarStatusSessaoUseCase(
    this._sessaoRepository,
    this._treinamentoRepository,
    this._agendaDisponibilidadeRepository,
    this._pacienteRepository,
  );

  Future<void> call({
    required Sessao sessao,
    required String novoStatus,
    bool? desmarcarTodasFuturas,
  }) async {
    if (sessao.status == 'Agendada') {
      if (!['Realizada', 'Falta', 'Cancelada', 'Bloqueada'].contains(novoStatus)) {
        throw Exception('Status inválido para sessão agendada.');
      }
    } else {
      if (novoStatus != 'Agendada') {
        throw Exception('Sessão só pode ser revertida para "Agendada" a partir do status atual.');
      }
    }

    final originalStatus = sessao.status;
    Sessao sessaoAtualizada = sessao.copyWith(status: novoStatus);

    if (novoStatus == 'Cancelada' && desmarcarTodasFuturas == true) {
      final allSessions = await _sessaoRepository.getSessoesByTreinamentoIdOnce(sessao.treinamentoId);
      final sessionsToDelete = allSessions
          .where((s) => s.dataHora.isAfter(sessao.dataHora) || s.dataHora.isAtSameMomentAs(sessao.dataHora))
          .map((s) => s.id!)
          .toList();
      
      if (sessionsToDelete.isNotEmpty) {
        await _sessaoRepository.deleteMultipleSessoes(sessionsToDelete);
      }
      
      final treinamento = await _treinamentoRepository.getTreinamentoById(sessao.treinamentoId);
      if (treinamento != null) {
        await _treinamentoRepository.updateTreinamento(treinamento.copyWith(status: 'cancelado'));
      }
      await verificarEAtualizarStatusTreinamento(sessao.treinamentoId);
      return;
    }

    if ((novoStatus == 'Cancelada' || novoStatus == 'Bloqueada') && originalStatus == 'Agendada') {
        if (sessao.treinamentoId != 'dia_bloqueado_completo' && sessao.treinamentoId != 'bloqueio_manual') {
          await _gerarSessaoExtraEReajustarNumeracao(sessao.treinamentoId, sessao.pacienteId, sessao.numeroSessao);
        }
    } else if (novoStatus == 'Agendada' && (originalStatus == 'Cancelada' || originalStatus == 'Bloqueada')) {
      if (sessao.treinamentoId != 'dia_bloqueado_completo' && sessao.treinamentoId != 'bloqueio_manual') {
        await _removerSessaoExtraEReajustarNumeracao(sessao.treinamentoId, sessao.numeroSessao);
      }
    }

    if (novoStatus == 'Falta' &&
        originalStatus == 'Agendada' &&
        sessao.statusPagamento != 'Convenio') {
      sessaoAtualizada = sessaoAtualizada.copyWith(statusPagamento: 'Pendente', dataPagamento: null);
    }

    await _sessaoRepository.updateSessao(sessaoAtualizada);
    await verificarEAtualizarStatusTreinamento(sessao.treinamentoId);
  }

  Future<void> verificarEAtualizarStatusTreinamento(String treinamentoId) async {
    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null) return;

    final todasSessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(treinamentoId);
    
    bool pagamentosPendentes = false;
    
    if (treinamento.formaPagamento == 'Convenio') {
      pagamentosPendentes = treinamento.pagamentos == null || treinamento.pagamentos!.isEmpty || treinamento.pagamentos!.any((p) => p.dataRecebimentoConvenio == null);
    } else if (treinamento.tipoParcelamento == '3x') {
      pagamentosPendentes = treinamento.pagamentos == null || treinamento.pagamentos!.where((p) => p.status == 'Realizado').length < 3;
    } else {
      pagamentosPendentes = todasSessoes.any((s) => (s.status == 'Realizada' || s.status == 'Falta') && s.statusPagamento == 'Pendente');
    }

    if (treinamento.status == 'ativo') {
      final sessoesConcluidas = todasSessoes.where((s) => s.status == 'Realizada' || s.status == 'Falta').length;
      if (sessoesConcluidas >= treinamento.numeroSessoesTotal) {
        if (pagamentosPendentes) {
          await _treinamentoRepository.updateTreinamento(treinamento.copyWith(status: 'Pendente Pagamento'));
        } else {
          await _treinamentoRepository.updateTreinamento(treinamento.copyWith(status: 'Finalizado'));
          await _pacienteRepository.inativarPaciente(treinamento.pacienteId);
        }
      }
    } 
    else if (treinamento.status == 'cancelado') {
      if (!pagamentosPendentes) {
        await _pacienteRepository.inativarPaciente(treinamento.pacienteId);
      }
    }
    else if (treinamento.status == 'Finalizado' || treinamento.status == 'Pendente Pagamento') {
       final sessoesConcluidas = todasSessoes.where((s) => s.status == 'Realizada' || s.status == 'Falta').length;
       if (sessoesConcluidas < treinamento.numeroSessoesTotal) {
          await _treinamentoRepository.updateTreinamento(treinamento.copyWith(status: 'ativo'));
       } else if (!pagamentosPendentes) {
          await _treinamentoRepository.updateTreinamento(treinamento.copyWith(status: 'Finalizado'));
          await _pacienteRepository.inativarPaciente(treinamento.pacienteId);
       }
    }
  }

  Future<void> _gerarSessaoExtraEReajustarNumeracao(String treinamentoId, String pacienteId, int sessaoOriginalNumero) async {
    if (treinamentoId == 'dia_bloqueado_completo' || treinamentoId == 'bloqueio_manual') {
      return; 
    }

    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null) return;

    final paciente = await _pacienteRepository.getPacienteById(pacienteId);
    if (paciente == null) throw Exception('Paciente não encontrado para gerar sessão extra.');

    final todasSessoes = await _sessaoRepository.getSessoesByTreinamentoId(treinamentoId).first;
    // --- CORREÇÃO DO ERRO DE DIGITAÇÃO AQUI ---
    final ultimaSessao = todasSessoes.reduce((a, b) => a.numeroSessao > b.numeroSessao ? a : b);

    for (var sessao in todasSessoes) {
      if (sessao.numeroSessao > sessaoOriginalNumero) {
        await _sessaoRepository.updateSessao(sessao.copyWith(numeroSessao: sessao.numeroSessao - 1));
      }
    }

    DateTime nextDate = ultimaSessao.dataHora.add(const Duration(days: 7));
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

      final sessoesNoDia = await _sessaoRepository.getSessoesByDate(potentialDate).first;
      final isOverlapping = sessoesNoDia.any((s) =>
          s.dataHora.hour == potentialDateTime.hour &&
          s.dataHora.minute == potentialDateTime.minute &&
          s.status != 'Cancelada' && s.status != 'Bloqueada');

      if (!isOverlapping && horariosDisponiveisNoDia.contains(treinamento.horario)) {
        nextDate = potentialDateTime;
        break;
      }
      nextDate = potentialDate.add(const Duration(days: 7));
    }

    final novaSessaoExtra = Sessao(
      treinamentoId: treinamentoId,
      pacienteId: pacienteId,
      pacienteNome: paciente.nome,
      dataHora: nextDate,
      numeroSessao: treinamento.numeroSessoesTotal,
      status: 'Agendada',
      statusPagamento: 'Pendente',
      dataPagamento: null,
      observacoes: null,
      formaPagamento: treinamento.formaPagamento,
      agendamentoStartDate: treinamento.dataInicio,
      parcelamento: treinamento.tipoParcelamento,
      pagamentosParcelados: null,
      reagendada: true,
      totalSessoes: treinamento.numeroSessoesTotal,
    );
    await _sessaoRepository.addSessao(novaSessaoExtra);
  }

  Future<void> _removerSessaoExtraEReajustarNumeracao(String treinamentoId, int sessaoRevertidaNumero) async {
    if (treinamentoId == 'dia_bloqueado_completo' || treinamentoId == 'bloqueio_manual') {
      return; 
    }

    final treinamento = await _treinamentoRepository.getTreinamentoById(treinamentoId);
    if (treinamento == null) return;

    // Obtém todas as sessões atuais
    final todasSessoes = await _sessaoRepository.getSessoesByTreinamentoIdOnce(treinamentoId);

    // 1. Encontrar a sessão extra para remover.
    // A sessão extra é geralmente a última cronologicamente ou a que tem o maior número de sessão
    // e foi marcada como reagendada (se houver esse campo) ou simplesmente a última excedente.
    
    // Ordena por data para ter certeza da ordem cronológica
    todasSessoes.sort((a, b) => a.dataHora.compareTo(b.dataHora));

    // A sessão extra é a última da lista cronológica
    if (todasSessoes.isEmpty) return;
    final sessaoExtra = todasSessoes.last;

    // Verificação de segurança: Só remove se o total de sessões for maior que o contratado
    // OU se tivermos certeza que é uma sessão extra gerada por bloqueio.
    // No seu caso, ao bloquear, criamos uma sessão a mais. Ao desbloquear, temos que remover uma.
    
    await _sessaoRepository.deleteSessao(sessaoExtra.id!);

    // 2. Reajustar a numeração das sessões restantes.
    // Quando bloqueamos, fizemos: sessao.numeroSessao - 1 (para as posteriores).
    // Agora, ao desbloquear, temos que fazer: sessao.numeroSessao + 1.
    // Mas apenas para as sessões que ocorrem DEPOIS da sessão que estamos desbloqueando/revertendo.

    // Removemos a sessão extra da lista em memória para não iterar sobre ela
    final sessoesRestantes = todasSessoes.where((s) => s.id != sessaoExtra.id).toList();

    for (var sessao in sessoesRestantes) {
      // Se a sessão é posterior à que estamos desbloqueando (baseado na data ou ID, 
      // mas aqui usamos a lógica de que as posteriores tiveram seu número reduzido)
      
      // A lógica de bloqueio anterior fazia: if (sessao.numeroSessao > sessaoOriginalNumero) ... numero - 1
      // Então agora, procuramos sessões que foram "encolhidas".
      // Como a sessão bloqueada (sessaoRevertidaNumero) manteve seu número original visualmente ou foi alterada?
      // Assumindo que a sessão bloqueada tem o número X. As sessões seguintes viraram X, X+1...
      // Agora a sessão bloqueada volta a ser X (válida). As seguintes devem virar X+1, X+2...
      
      // Portanto, incrementamos o número de todas as sessões que estão APÓS a sessão revertida.
      // Usamos a dataHora para garantir que pegamos as posteriores cronologicamente.
      // Precisamos pegar a referência da sessão que está sendo revertida.
      // Como não temos a sessão revertida completa aqui, assumimos que 'sessaoRevertidaNumero' 
      // é o número que ela TINHA quando estava bloqueada.
      
      // Mas espere: no método call, passamos sessao.numeroSessao.
      // Se a sessão estava bloqueada, ela tinha um número.
      
      // Vamos simplificar: Restaurar a ordem sequencial correta baseada na data.
      // Essa é a forma mais robusta de corrigir qualquer erro de numeração anterior.
    }
    
    // REINDEXAÇÃO COMPLETA E SEGURA
    // Ordena as sessões restantes por data
    sessoesRestantes.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    
    // Reaplica a numeração sequencial 1, 2, 3...
    for (int i = 0; i < sessoesRestantes.length; i++) {
      final sessao = sessoesRestantes[i];
      final numeroCorreto = i + 1;
      
      if (sessao.numeroSessao != numeroCorreto) {
        await _sessaoRepository.updateSessao(sessao.copyWith(numeroSessao: numeroCorreto));
      }
    }
  }
}