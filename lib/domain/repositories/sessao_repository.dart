import 'package:agendanova/domain/entities/sessao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SessaoRepository {
  Stream<List<Sessao>> getSessoes();
  Stream<List<Sessao>> getSessoesByTreinamentoId(String treinamentoId);
  // --- NOVO MÉTODO ---
  Future<List<Sessao>> getSessoesByTreinamentoIdOnce(String treinamentoId);
  Stream<List<Sessao>> getSessoesByDate(DateTime date);
  Stream<List<Sessao>> getSessoesByMonth(DateTime monthDate);
  Future<void> setDayBlockedStatus(DateTime date, bool isBlocked);
  Future<String> addSessao(Sessao sessao);
  Future<void> addMultipleSessoes(List<Sessao> sessoes);
  Future<void> updateSessao(Sessao sessao);
  Future<void> deleteSessao(String id);
  Future<void> deleteMultipleSessoes(List<String> sessaoIds);
  void addSessaoInBatch(WriteBatch batch, Sessao sessao);
  void updateSessaoInBatch(WriteBatch batch, Sessao sessao);
  void deleteSessaoInBatch(WriteBatch batch, String sessaoId);
}