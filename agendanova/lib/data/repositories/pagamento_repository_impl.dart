import 'package:flutter_agenda_fono/core/constants/firestore_collections.dart';
import 'package:flutter_agenda_fono/data/datasources/firebase_datasource.dart';
import 'package:flutter_agenda_fono/data/models/pagamento_model.dart';
import 'package:flutter_agenda_fono/domain/entities/pagamento.dart';
import 'package:flutter_agenda_fono/domain/repositories/pagamento_repository.dart';

// Implementação concreta do PagamentoRepository que usa o FirebaseDatasource
class PagamentoRepositoryImpl implements PagamentoRepository {
  final FirebaseDatasource _firebaseDatasource;

  PagamentoRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<Pagamento>> getPagamentos() {
    return _firebaseDatasource.getCollectionStream(FirestoreCollections.pagamentos).map(
          (snapshot) => snapshot.docs
              .map((doc) => PagamentoModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<Pagamento>> getPagamentosByTreinamentoId(String treinamentoId) {
    return _firebaseDatasource.queryCollectionStream(
      FirestoreCollections.pagamentos,
      field: 'treinamentoId',
      isEqualTo: treinamentoId,
    ).map(
          (snapshot) => snapshot.docs
              .map((doc) => PagamentoModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<String> addPagamento(Pagamento pagamento) async {
    final pagamentoModel = PagamentoModel.fromEntity(pagamento);
    final docRef = await _firebaseDatasource.addDocument(FirestoreCollections.pagamentos, pagamentoModel.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updatePagamento(Pagamento pagamento) async {
    if (pagamento.id == null) {
      throw Exception('ID do pagamento é obrigatório para atualização.');
    }
    final pagamentoModel = PagamentoModel.fromEntity(pagamento);
    await _firebaseDatasource.updateDocument(FirestoreCollections.pagamentos, pagamento.id!, pagamentoModel.toFirestore());
  }

  @override
  Future<void> deletePagamento(String id) async {
    await _firebaseDatasource.deleteDocument(FirestoreCollections.pagamentos, id);
  }
}

