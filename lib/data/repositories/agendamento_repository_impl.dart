import 'package:agendanova/data/datasources/firebase_datasource.dart';
import 'package:agendanova/data/models/paciente_model.dart';
import 'package:agendanova/domain/entities/paciente.dart';
import 'package:agendanova/domain/repositories/paciente_repository.dart';
import 'package:agendanova/core/constants/firestore_collections.dart';

// Implementação concreta do PacienteRepository que usa o FirebaseDatasource
class PacienteRepositoryImpl implements PacienteRepository {
  final FirebaseDatasource _firebaseDatasource;

  PacienteRepositoryImpl(this._firebaseDatasource);

  @override
  Stream<List<Paciente>> getPacientes() {
    return _firebaseDatasource.getCollectionStream(FirestoreCollections.pacientes).map(
          (snapshot) => snapshot.docs
              .map((doc) => PacienteModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<Paciente>> getPacientesAtivos() {
    return _firebaseDatasource.queryCollectionStream(
      FirestoreCollections.pacientes,
      field: 'status',
      isEqualTo: 'ativo',
    ).map(
          (snapshot) => snapshot.docs
              .map((doc) => PacienteModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<Paciente>> getPacientesInativos() {
    return _firebaseDatasource.queryCollectionStream(
      FirestoreCollections.pacientes,
      field: 'status',
      isEqualTo: 'inativo',
    ).map(
          (snapshot) => snapshot.docs
              .map((doc) => PacienteModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<Paciente?> getPacienteById(String id) async {
    final doc = await _firebaseDatasource.getDocumentById(FirestoreCollections.pacientes, id);
    if (doc.exists) {
      return PacienteModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> addPaciente(Paciente paciente) async {
    final pacienteModel = PacienteModel.fromEntity(paciente);
    await _firebaseDatasource.addDocument(FirestoreCollections.pacientes, pacienteModel.toFirestore());
  }

  @override
  Future<void> updatePaciente(Paciente paciente) async {
    if (paciente.id == null) {
      throw Exception('ID do paciente é obrigatório para atualização.');
    }
    final pacienteModel = PacienteModel.fromEntity(paciente);
    await _firebaseDatasource.updateDocument(FirestoreCollections.pacientes, paciente.id!, pacienteModel.toFirestore());
  }

  @override
  Future<void> inativarPaciente(String id) async {
    await _firebaseDatasource.updateDocument(FirestoreCollections.pacientes, id, {'status': 'inativo'});
  }

  @override
  Future<void> reativarPaciente(String id) async {
    await _firebaseDatasource.updateDocument(FirestoreCollections.pacientes, id, {'status': 'ativo'});
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
}

