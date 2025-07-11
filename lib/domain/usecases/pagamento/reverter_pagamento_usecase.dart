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

    // Reverte o pagamento
    await _pagamentoRepository.updatePagamento(
      pagamento.copyWith(status: 'Pendente', dataPagamento: null),
    );

    // Se o pagamento for de convênio, reverte todas as sessões associadas
    if (pagamento.formaPagamento == 'Convenio') {
      final sessoes = await _sessaoRepository.getSessoesByTreinamentoId(pagamento.treinamentoId).first;
      for (var sessao in sessoes) {
        await _sessaoRepository.updateSessao(
          sessao.copyWith(statusPagamento: 'Pendente', dataPagamento: null),
        );
      }
    }

    // --- LÓGICA DE ATUALIZAÇÃO DE STATUS DO TREINAMENTO ---
    // Após reverter o pagamento, verifica o status do treinamento
    final treinamento = await _treinamentoRepository.getTreinamentoById(pagamento.treinamentoId);
    if (treinamento != null && treinamento.status == 'Finalizado') {
      // Se o treinamento estava finalizado, ele agora tem um pagamento pendente.
      await _treinamentoRepository.updateTreinamento(
        treinamento.copyWith(status: 'Pendente Pagamento'),
      );
    }
  }
}
