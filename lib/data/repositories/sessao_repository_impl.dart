import 'package:agendanova/core/constants/firestore_collections.dart';
import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/models/sessao_model.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Implementação concreta do SessaoRepository que usa o FirebaseDatasource
class SessaoRepositoryImpl implements SessaoRepository {
  final FirebaseDatasource _firebaseDatasource;

  SessaoRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<Sessao>> getSessoes() {
    return Stream.value([]);
  }

  @override
  Stream<List<Sessao>> getSessoesByTreinamentoId(String treinamentoId) {
    return Stream.value([]);
  }

  @override
  Stream<List<Sessao>> getSessoesByDate(DateTime date) {
    final docId = DateFormat('yyyy-MM-dd').format(date);

    return _firebaseDatasource.getDocumentByIdStream(FirestoreCollections.sessoes, docId)
        .map((docSnapshot) {
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return [];
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      List<Sessao> sessoesDoDia = [];

      data.forEach((horarioKey, sessaoMap) {
        if (sessaoMap is Map<String, dynamic>) {
          try {
            sessoesDoDia.add(SessaoModel.fromMap(docId, sessaoMap, horarioKey));
          } catch (e) {
            print('Erro ao parsear sessão para $horarioKey em $docId: $e');
          }
        }
      });

      sessoesDoDia.sort((a, b) => a.dataHora.compareTo(b.dataHora));
      return sessoesDoDia;
    });
  }

  // NOVO MÉTODO: Obtém todas as sessões para um determinado mês
  @override
  Stream<List<Sessao>> getSessoesByMonth(DateTime monthDate) {
    final startOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final endOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0); // Último dia do mês
    final startDocId = DateFormat('yyyy-MM-dd').format(startOfMonth);
    final endDocId = DateFormat('yyyy-MM-dd').format(endOfMonth);

    return _firebaseDatasource.queryCollectionStreamByDocIdRange(
      FirestoreCollections.sessoes,
      startDocId: startDocId,
      endDocId: endDocId,
    ).map((querySnapshot) {
      List<Sessao> sessoesDoMes = [];
      for (var docSnapshot in querySnapshot.docs) {
        if (docSnapshot.exists && docSnapshot.data() != null) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final docId = docSnapshot.id; // A data é o ID do documento

          data.forEach((horarioKey, sessaoMap) {
            if (sessaoMap is Map<String, dynamic>) {
              try {
                sessoesDoMes.add(SessaoModel.fromMap(docId, sessaoMap, horarioKey));
              } catch (e) {
                print('Erro ao parsear sessão para $horarioKey em $docId: $e');
              }
            }
          });
        }
      }
      return sessoesDoMes;
    });
  }


  @override
  Future<String> addSessao(Sessao sessao) async {
    final docId = DateFormat('yyyy-MM-dd').format(sessao.dataHora);
    final horarioKey = DateFormat('HH:mm').format(sessao.dataHora);

    final sessaoModel = SessaoModel.fromEntity(sessao);
    await _firebaseDatasource.setDocument(
      FirestoreCollections.sessoes,
      docId,
      {horarioKey: sessaoModel.toFirestore()},
    );
    return '$docId-$horarioKey';
  }

  @override
  Future<void> addMultipleSessoes(List<Sessao> sessoes) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var sessao in sessoes) {
      final docId = DateFormat('yyyy-MM-dd').format(sessao.dataHora);
      final horarioKey = DateFormat('HH:mm').format(sessao.dataHora);
      final sessaoModel = SessaoModel.fromEntity(sessao);

      final docRef = _firebaseDatasource.getCollectionRef(FirestoreCollections.sessoes).doc(docId);

      batch.set(docRef, {horarioKey: sessaoModel.toFirestore()}, SetOptions(merge: true));
    }
    await batch.commit();
  }


  @override
  Future<void> updateSessao(Sessao sessao) async {
    if (sessao.id == null) {
      throw Exception('ID da sessão é obrigatório para atualização.');
    }
    final parts = sessao.id!.split('-');
    final docId = '${parts[0]}-${parts[1]}-${parts[2]}';
    final horarioKey = parts[3];

    final sessaoModel = SessaoModel.fromEntity(sessao);
    await _firebaseDatasource.updateDocument(
      FirestoreCollections.sessoes,
      docId,
      {horarioKey: sessaoModel.toFirestore()},
    );
  }

  @override
  Future<void> deleteSessao(String id) async {
    final parts = id.split('-');
    final docId = '${parts[0]}-${parts[1]}-${parts[2]}';
    final horarioKey = parts[3];

    await _firebaseDatasource.updateDocument(
      FirestoreCollections.sessoes,
      docId,
      {horarioKey: FieldValue.delete()},
    );
  }

  @override
  Future<void> deleteMultipleSessoes(List<String> sessaoIds) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var id in sessaoIds) {
      final parts = id.split('-');
      final docId = '${parts[0]}-${parts[1]}-${parts[2]}';
      final horarioKey = parts[3];

      final docRef = _firebaseDatasource.getDocumentRef(FirestoreCollections.sessoes, docId);
      batch.update(docRef, {horarioKey: FieldValue.delete()});
    }
    await batch.commit();
  }
}
