import 'package:agendanova/core/constants/firestore_collections.dart';
import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/models/sessao_model.dart';
import 'package:agendanova/domain/entities/sessao.dart';
import 'package:agendanova/domain/repositories/sessao_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SessaoRepositoryImpl implements SessaoRepository {
  final FirebaseDatasource _firebaseDatasource;

  SessaoRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<Sessao>> getSessoes() {
    return _firebaseDatasource.getCollectionStream(FirestoreCollections.sessoes).map((snapshot) {
      List<Sessao> sessoes = [];
      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          final docId = doc.id;
          data.forEach((horarioKey, sessaoMap) {
            if (sessaoMap is Map<String, dynamic>) {
               try {
                sessoes.add(SessaoModel.fromMap(docId, sessaoMap, horarioKey));
              } catch (e) {
                // Ignore parsing errors for fields like 'isDayBlocked'
              }
            }
          });
        }
      }
      return sessoes;
    });
  }
  
  @override
  Stream<List<Sessao>> getSessoesByTreinamentoId(String treinamentoId) {
     return _firebaseDatasource.getCollectionStream(FirestoreCollections.sessoes)
        .map((snapshot) {
      List<Sessao> sessoes = [];
      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          final docId = doc.id;
          data.forEach((horarioKey, sessaoMap) {
            if (sessaoMap is Map<String, dynamic> && sessaoMap['agendamentoId'] == treinamentoId) {
              try {
                sessoes.add(SessaoModel.fromMap(docId, sessaoMap, horarioKey));
              } catch (e) {
                // Silently ignore parsing errors
              }
            }
          });
        }
      }
      return sessoes;
    });
  }

  @override
  Future<List<Sessao>> getSessoesByTreinamentoIdOnce(String treinamentoId) {
    return getSessoesByTreinamentoId(treinamentoId).first;
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

      final bool isDayBlockedFlag = data['isDayBlocked'] as bool? ?? false;

      if (isDayBlockedFlag) {
        sessoesDoDia.add(Sessao(
          id: '$docId-dia-bloqueado',
          treinamentoId: 'dia_bloqueado_completo',
          pacienteId: 'dia_bloqueado_completo',
          pacienteNome: 'Dia Bloqueado',
          dataHora: DateTime(date.year, date.month, date.day, 0, 0),
          numeroSessao: 0,
          status: 'Bloqueada',
          statusPagamento: 'N/A',
          formaPagamento: 'N/A',
          agendamentoStartDate: date,
          totalSessoes: 0,
        ));
      } else {
        data.forEach((horarioKey, sessaoMap) {
          if (horarioKey != 'isDayBlocked' && sessaoMap is Map<String, dynamic>) {
            try {
              sessoesDoDia.add(SessaoModel.fromMap(docId, sessaoMap, horarioKey));
            } catch (e) {
              // Silently ignore
            }
          }
        });
      }

      sessoesDoDia.sort((a, b) => a.dataHora.compareTo(b.dataHora));
      return sessoesDoDia;
    });
  }

  @override
  Stream<List<Sessao>> getSessoesByMonth(DateTime monthDate) {
    final startOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final endOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
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
          final docId = docSnapshot.id;

          final bool isDayBlockedFlag = data['isDayBlocked'] as bool? ?? false;
          if (isDayBlockedFlag) {
            final date = DateTime.parse(docId);
            sessoesDoMes.add(Sessao(
              id: '$docId-dia-bloqueado',
              treinamentoId: 'dia_bloqueado_completo',
              pacienteId: 'dia_bloqueado_completo',
              pacienteNome: 'Dia Bloqueado',
              dataHora: date,
              numeroSessao: 0,
              status: 'Bloqueada',
              statusPagamento: 'N/A',
              formaPagamento: 'N/A',
              agendamentoStartDate: date,
              totalSessoes: 0,
            ));
          }

          data.forEach((horarioKey, sessaoMap) {
            if (horarioKey != 'isDayBlocked' && sessaoMap is Map<String, dynamic>) {
              try {
                sessoesDoMes.add(SessaoModel.fromMap(docId, sessaoMap, horarioKey));
              } catch (e) {
                 // Silently ignore
              }
            }
          });
        }
      }
      return sessoesDoMes;
    });
  }

  @override
  Future<void> setDayBlockedStatus(DateTime date, bool isBlocked) async {
    final docId = DateFormat('yyyy-MM-dd').format(date);
    await _firebaseDatasource.setDocument(
      FirestoreCollections.sessoes,
      docId,
      {'isDayBlocked': isBlocked},
      SetOptions(merge: true),
    );
  }


  @override
  Future<String> addSessao(Sessao sessao) async {
    final docId = DateFormat('yyyy-MM-dd').format(sessao.dataHora);
    // --- CORREÇÃO AQUI ---
    // Garantindo que a chave seja sempre no formato HH:mm
    final horarioKey = DateFormat('HH:mm').format(sessao.dataHora);
    final sessaoModel = SessaoModel.fromEntity(sessao);
    await _firebaseDatasource.setDocument(
      FirestoreCollections.sessoes,
      docId,
      {horarioKey: sessaoModel.toFirestore()},
      SetOptions(merge: true),
    );
    return '$docId-$horarioKey';
  }

  @override
  Future<void> addMultipleSessoes(List<Sessao> sessoes) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var sessao in sessoes) {
       addSessaoInBatch(batch, sessao);
    }
    await batch.commit();
  }


  @override
  Future<void> updateSessao(Sessao sessao) async {
    if (sessao.id == null) return;
    final batch = FirebaseFirestore.instance.batch();
    updateSessaoInBatch(batch, sessao);
    await batch.commit();
  }

  @override
  Future<void> deleteSessao(String id) async {
     final batch = FirebaseFirestore.instance.batch();
    deleteSessaoInBatch(batch, id);
    await batch.commit();
  }

  @override
  Future<void> deleteMultipleSessoes(List<String> sessaoIds) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var id in sessaoIds) {
      deleteSessaoInBatch(batch, id);
    }
    await batch.commit();
  }

  @override
  void addSessaoInBatch(WriteBatch batch, Sessao sessao) {
    final docId = DateFormat('yyyy-MM-dd').format(sessao.dataHora);
    // --- CORREÇÃO AQUI ---
    final horarioKey = DateFormat('HH:mm').format(sessao.dataHora);
    final sessaoModel = SessaoModel.fromEntity(sessao);
    final docRef = _firebaseDatasource.getDocumentRef(FirestoreCollections.sessoes, docId);
    batch.set(docRef, {horarioKey: sessaoModel.toFirestore()}, SetOptions(merge: true));
  }

  @override
  void updateSessaoInBatch(WriteBatch batch, Sessao sessao) {
    if (sessao.id == null) return;

    // --- CORREÇÃO APLICADA AQUI (LÓGICA MAIS ROBUSTA) ---
    final int lastHyphenIndex = sessao.id!.lastIndexOf('-');
    if (lastHyphenIndex == -1) return; // ID em formato inesperado

    final String docId = sessao.id!.substring(0, lastHyphenIndex);
    final String horarioKey = sessao.id!.substring(lastHyphenIndex + 1);
    // --- FIM DA CORREÇÃO ---

    final sessaoModel = SessaoModel.fromEntity(sessao);
    final docRef = _firebaseDatasource.getDocumentRef(FirestoreCollections.sessoes, docId);
    batch.update(docRef, {horarioKey: sessaoModel.toFirestore()});
  }

  @override
  void deleteSessaoInBatch(WriteBatch batch, String sessaoId) {
  // --- CORREÇÃO APLICADA AQUI (LÓGICA MAIS ROBUSTA) ---
  final int lastHyphenIndex = sessaoId.lastIndexOf('-');
  if (lastHyphenIndex == -1) return; // ID em formato inesperado

  final String docId = sessaoId.substring(0, lastHyphenIndex);
  final String horarioKey = sessaoId.substring(lastHyphenIndex + 1);
  // --- FIM DA CORREÇÃO ---

  final docRef = _firebaseDatasource.getDocumentRef(FirestoreCollections.sessoes, docId);
  batch.update(docRef, {horarioKey: FieldValue.delete()});
  }
}