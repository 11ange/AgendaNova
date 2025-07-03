import 'package:flutter_agenda_fono/core/constants/firestore_collections.dart';
import 'package:flutter_agenda_fono/data/datasources/firebase_datasource.dart';
import 'package:flutter_agenda_fono/data/models/sessao_model.dart';
import 'package:flutter_agenda_fono/domain/entities/sessao.dart';
import 'package:flutter_agenda_fono/domain/repositories/sessao_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para usar Timestamp e WriteBatch

// Implementação concreta do SessaoRepository que usa o FirebaseDatasource
class SessaoRepositoryImpl implements SessaoRepository {
  final FirebaseDatasource _firebaseDatasource;

  SessaoRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<Sessao>> getSessoes() {
    return _firebaseDatasource.getCollectionStream(FirestoreCollections.sessoes).map(
          (snapshot) => snapshot.docs
              .map((doc) => SessaoModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<Sessao>> getSessoesByTreinamentoId(String treinamentoId) {
    return _firebaseDatasource.queryCollectionStream(
      FirestoreCollections.sessoes,
      field: 'treinamentoId',
      isEqualTo: treinamentoId,
    ).map(
          (snapshot) => snapshot.docs
              .map((doc) => SessaoModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<Sessao>> getSessoesByDate(DateTime date) {
    // Para filtrar por data, precisamos de um range de timestamps.
    // Firestore não permite query direta por apenas data (sem hora) facilmente sem índices.
    // A melhor abordagem é filtrar por um range de início e fim do dia.
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firebaseDatasource.queryCollectionStreamWithRange(
      FirestoreCollections.sessoes,
      field: 'dataHora',
      startValue: Timestamp.fromDate(startOfDay),
      endValue: Timestamp.fromDate(endOfDay),
    ).map(
          (snapshot) => snapshot.docs
              .map((doc) => SessaoModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<String> addSessao(Sessao sessao) async {
    final sessaoModel = SessaoModel.fromEntity(sessao);
    final docRef = await _firebaseDatasource.addDocument(FirestoreCollections.sessoes, sessaoModel.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> addMultipleSessoes(List<Sessao> sessoes) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var sessao in sessoes) {
      final sessaoModel = SessaoModel.fromEntity(sessao);
      final docRef = _firebaseDatasource.getCollectionRef(FirestoreCollections.sessoes).doc();
      batch.set(docRef, sessaoModel.toFirestore());
    }
    await batch.commit();
  }

  @override
  Future<void> updateSessao(Sessao sessao) async {
    if (sessao.id == null) {
      throw Exception('ID da sessão é obrigatório para atualização.');
    }
    final sessaoModel = SessaoModel.fromEntity(sessao);
    await _firebaseDatasource.updateDocument(FirestoreCollections.sessoes, sessao.id!, sessaoModel.toFirestore());
  }

  @override
  Future<void> deleteSessao(String id) async {
    await _firebaseDatasource.deleteDocument(FirestoreCollections.sessoes, id);
  }

  @override
  Future<void> deleteMultipleSessoes(List<String> sessaoIds) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var id in sessaoIds) {
      final docRef = _firebaseDatasource.getDocumentRef(FirestoreCollections.sessoes, id);
      batch.delete(docRef);
    }
    await batch.commit();
  }
}

