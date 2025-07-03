import 'package:flutter_agenda_fono/core/constants/firestore_collections.dart';
import 'package:flutter_agenda_fono/data/datasources/firebase_datasource.dart';
import 'package:flutter_agenda_fono/data/models/treinamento_model.dart';
import 'package:flutter_agenda_fono/domain/entities/treinamento.dart';
import 'package:flutter_agenda_fono/domain/repositories/treinamento_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para usar Timestamp

// Implementação concreta do TreinamentoRepository que usa o FirebaseDatasource
class TreinamentoRepositoryImpl implements TreinamentoRepository {
  final FirebaseDatasource _firebaseDatasource;

  TreinamentoRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<Treinamento>> getTreinamentos() {
    return _firebaseDatasource.getCollectionStream(FirestoreCollections.treinamentos).map(
          (snapshot) => snapshot.docs
              .map((doc) => TreinamentoModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<Treinamento?> getTreinamentoById(String id) async {
    final doc = await _firebaseDatasource.getDocumentById(FirestoreCollections.treinamentos, id);
    if (doc.exists) {
      return TreinamentoModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Stream<List<Treinamento>> getTreinamentosByPacienteId(String pacienteId) {
    return _firebaseDatasource.queryCollectionStream(
      FirestoreCollections.treinamentos,
      field: 'pacienteId',
      isEqualTo: pacienteId,
    ).map(
          (snapshot) => snapshot.docs
              .map((doc) => TreinamentoModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<String> addTreinamento(Treinamento treinamento) async {
    final treinamentoModel = TreinamentoModel.fromEntity(treinamento);
    final docRef = await _firebaseDatasource.addDocument(FirestoreCollections.treinamentos, treinamentoModel.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updateTreinamento(Treinamento treinamento) async {
    if (treinamento.id == null) {
      throw Exception('ID do treinamento é obrigatório para atualização.');
    }
    final treinamentoModel = TreinamentoModel.fromEntity(treinamento);
    await _firebaseDatasource.updateDocument(FirestoreCollections.treinamentos, treinamento.id!, treinamentoModel.toFirestore());
  }

  @override
  Future<bool> hasActiveTreinamento(String pacienteId) async {
    final querySnapshot = await _firebaseDatasource.queryCollectionOnce(
      FirestoreCollections.treinamentos,
      field: 'pacienteId',
      isEqualTo: pacienteId,
    );
    // Verifica se existe algum treinamento para o paciente com status "ativo"
    return querySnapshot.docs.any((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'ativo');
  }

  @override
  Future<bool> hasOverlap(String diaSemana, String horario, {String? excludeTreinamentoId}) async {
    // Esta verificação é um pouco mais complexa e pode exigir uma query composta
    // ou uma busca mais ampla e filtragem em memória, dependendo da necessidade de índices.
    // Por enquanto, faremos uma busca básica e filtraremos em memória.
    final querySnapshot = await _firebaseDatasource.queryCollectionOnce(
      FirestoreCollections.treinamentos,
      field: 'diaSemana', // Filtra pelo dia da semana
      isEqualTo: diaSemana,
    );

    // Filtra em memória para o horário e exclui o treinamento atual se for uma edição
    return querySnapshot.docs.any((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final currentTreinamentoId = doc.id;
      final currentHorario = data['horario'] as String;
      final status = data['status'] as String;

      // Considera sobreposição apenas para treinamentos ativos e no mesmo horário
      return status == 'ativo' &&
             currentHorario == horario &&
             (excludeTreinamentoId == null || currentTreinamentoId != excludeTreinamentoId);
    });
  }
}

