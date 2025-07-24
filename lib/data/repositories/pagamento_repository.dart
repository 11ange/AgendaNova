import 'package:agenda_treinamento/domain/entities/pagamento.dart';

// Contrato (interface) para o repositório de Pagamentos
abstract class PagamentoRepository {
  // Obtém um stream de todos os pagamentos
  Stream<List<Pagamento>> getPagamentos();

  // Obtém pagamentos por ID do treinamento
  Stream<List<Pagamento>> getPagamentosByTreinamentoId(String treinamentoId);

  // Adiciona um novo pagamento
  Future<String> addPagamento(
    Pagamento pagamento,
  ); // Retorna o ID do novo pagamento

  // Atualiza um pagamento existente
  Future<void> updatePagamento(Pagamento pagamento);

  // Exclui um pagamento
  Future<void> deletePagamento(String id);
}
