import 'package:agendanova/domain/entities/sessao.dart';

// Contrato (interface) para o repositório de Sessões
abstract class SessaoRepository {
  // Obtém um stream de todas as sessões
  Stream<List<Sessao>> getSessoes();

  // Obtém sessões por ID do treinamento
  Stream<List<Sessao>> getSessoesByTreinamentoId(String treinamentoId);

  // Obtém sessões para um dia específico
  Stream<List<Sessao>> getSessoesByDate(DateTime date);

  // NOVO MÉTODO: Obtém sessões para um determinado mês
  Stream<List<Sessao>> getSessoesByMonth(DateTime monthDate);

  // Adiciona uma nova sessão
  Future<String> addSessao(Sessao sessao);

  // Adiciona múltiplas sessões (usado na criação de treinamento)
  Future<void> addMultipleSessoes(List<Sessao> sessoes);

  // Atualiza uma sessão existente
  Future<void> updateSessao(Sessao sessao);

  // Exclui uma sessão
  Future<void> deleteSessao(String id);

  // Exclui múltiplas sessões
  Future<void> deleteMultipleSessoes(List<String> sessaoIds);
}

