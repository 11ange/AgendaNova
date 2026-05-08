import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_treinamento/data/datasources/firebase_datasource.dart';
import 'package:agenda_treinamento/data/models/paciente_model.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/core/constants/firestore_collections.dart';

// Implementação concreta do PacienteRepository que usa o FirebaseDatasource
class PacienteRepositoryImpl implements PacienteRepository {
  final FirebaseDatasource _firebaseDatasource;

  PacienteRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<Paciente>> getPacientes() {
    return _firebaseDatasource
        .getCollectionStream(FirestoreCollections.pacientes)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PacienteModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<Paciente>> getPacientesAtivos() {
    return _firebaseDatasource
        .queryCollectionStream(
          FirestoreCollections.pacientes,
          field: 'status',
          isEqualTo: 'ativo',
        )
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PacienteModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<Paciente>> getPacientesInativos() {
    return _firebaseDatasource
        .queryCollectionStream(
          FirestoreCollections.pacientes,
          field: 'status',
          isEqualTo: 'inativo',
        )
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PacienteModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<Paciente>> getPacientesArquivados() {
    return _firebaseDatasource
        .queryCollectionStream(
          FirestoreCollections.pacientes,
          field: 'status',
          isEqualTo: 'arquivado',
        )
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PacienteModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<Paciente?> getPacienteById(String id) async {
    final doc = await _firebaseDatasource.getDocumentById(
      FirestoreCollections.pacientes,
      id,
    );
    if (doc.exists) {
      return PacienteModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> addPaciente(Paciente paciente) async {
    final currentUserId = _firebaseDatasource.currentUserId;
    final pacienteModel = PacienteModel.fromEntity(paciente.copyWith(ownerId: currentUserId));
    await _firebaseDatasource.addDocument(
      FirestoreCollections.pacientes,
      pacienteModel.toFirestore(),
    );
  }

  @override
  Future<void> updatePaciente(Paciente paciente) async {
    if (paciente.id == null) {
      throw Exception('ID do paciente é obrigatório para atualização.');
    }
    final currentUserId = _firebaseDatasource.currentUserId;
    final pacienteModel = PacienteModel.fromEntity(paciente.copyWith(ownerId: currentUserId));
    await _firebaseDatasource.updateDocument(
      FirestoreCollections.pacientes,
      paciente.id!,
      pacienteModel.toFirestore(),
    );
  }

  @override
  Future<void> inativarPaciente(String id) async {
    await _firebaseDatasource.updateDocument(
      FirestoreCollections.pacientes,
      id,
      {
        'status': 'inativo',
        'ownerId': _firebaseDatasource.currentUserId,
      },
    );
  }

  @override
  Future<void> reativarPaciente(String id) async {
    await _firebaseDatasource.updateDocument(
      FirestoreCollections.pacientes,
      id,
      {
        'status': 'ativo',
        'dataArquivamento': null,
        'ownerId': _firebaseDatasource.currentUserId,
      },
    );
  }

  @override
  Future<void> arquivarPaciente(String id) async {
    await _firebaseDatasource.updateDocument(
      FirestoreCollections.pacientes,
      id,
      {
        'status': 'arquivado',
        'dataArquivamento': Timestamp.now(),
        'ownerId': _firebaseDatasource.currentUserId,
      },
    );
  }

  @override
  Future<bool> pacienteExistsByName(String nome, {String? excludeId}) async {
    final querySnapshot = await _firebaseDatasource.queryCollectionOnce(
      FirestoreCollections.pacientes,
      field: 'nome',
      isEqualTo: nome,
    );
    // Verifica se existe algum documento com o nome, excluindo o próprio ID se estiver editando
    return querySnapshot.docs.any((doc) => doc.id != excludeId);
  }

  @override
  Future<Paciente?> getPacienteByName(String nome) async {
    // Busca exata pelo nome na coleção de pacientes do usuário atual
    final querySnapshot = await _firebaseDatasource.queryCollectionOnce(
      FirestoreCollections.pacientes,
      field: 'nome',
      isEqualTo: nome,
    );
    
    if (querySnapshot.docs.isNotEmpty) {
      // Retorna o primeiro encontrado (independente do status)
      return PacienteModel.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  @override
  Future<Paciente?> getPacienteByNormalizedName(String nomeNormalizado) async {
    final querySnapshot = await _firebaseDatasource.queryCollectionOnce(
      FirestoreCollections.pacientes,
      field: 'nomeBusca',
      isEqualTo: nomeNormalizado,
    );
    
    if (querySnapshot.docs.isNotEmpty) {
      return PacienteModel.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }
}
