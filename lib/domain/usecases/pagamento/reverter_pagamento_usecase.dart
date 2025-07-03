import 'package:agendanova/domain/entities/pagamento.dart';
import 'package:agendanova/domain/repositories/pagamento_repository.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:agendanova/domain/repositories/treinamento_repository.dart';

// Use case para reverter um pagamento
class ReverterPagamentoUseCase {
  final PagamentoRepository _pagamentoRepository;
  final SessaoRepository _sessaoRepository;
  final TreinamentoRepository _treinamentoRepository;

  ReverterPagamentoUseCase(
    this._pagamentoRepository,
    this._sessaoRepository,
    this._treinamentoRepository,
  );

  Future<void> call(String pagamentoId) async {
    final pagamento = await _pagamentoRepository.getPagamentos().firstWhere(
          (list) => list.any((p) => p.id == pagamentoId),
          orElse: () => throw Exception('Pagamento não encontrado.'),
        ).then((list) => list.firstWhere((p) => p.id == pagamentoId));

    if (pagamento.formaPagamento == 'Convenio') {
      // Reverter pagamento de convênio:
      // 1. Marcar o pagamento como "Pendente" ou excluí-lo.
      // 2. Marcar as sessões associadas de volta para "Pendente" (se não tiverem sido pagas individualmente).
      await _pagamentoRepository.updatePagamento(
        pagamento.copyWith(status: 'Pendente', dataPagamento: DateTime.now()), // Ou simplesmente deletePagamento
      );

      final sessoes = await _sessaoRepository.getSessoesByTreinamentoId(pagamento.treinamentoId).first;
      for (var sessao in sessoes) {
        // Reverte o status de pagamento da sessão para "Pendente"
        await _sessaoRepository.updateSessao(
          sessao.copyWith(statusPagamento: 'Pendente', dataPagamento: null),
        );
      }
    } else {
      // Para Pix/Dinheiro (parcelamento 3x ou avulso), simplesmente reverte o status
      await _pagamentoRepository.updatePagamento(
        pagamento.copyWith(status: 'Pendente', dataPagamento: null),
      );
    }
  }
}

