import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_agenda_fono/core/services/firebase_service.dart';

// DataSource que interage diretamente com o Firebase Firestore
class FirebaseDatasource {
  final FirebaseService _firebaseService;

  FirebaseDatasource(this._firebaseService);

  // Obtém um stream de todos os documentos de uma coleção
  Stream<QuerySnapshot> getCollectionStream(String collectionPath) {
    return _firebaseService.getCollectionRef(collectionPath).snapshots();
  }

  // Obtém um stream de documentos de uma coleção com uma query
  Stream<QuerySnapshot> queryCollectionStream(
    String collectionPath, {
    required String field,
    required dynamic isEqualTo,
  }) {
    return _firebaseService.getCollectionRef(collectionPath).where(field, isEqualTo: isEqualTo).snapshots();
  }

  // Obtém um documento por ID
  Future<DocumentSnapshot> getDocumentById(String collectionPath, String docId) {
    return _firebaseService.getDocumentById(collectionPath, docId);
  }

  // Obtém um stream de um documento por ID (para atualizações em tempo real de um único documento)
  Stream<DocumentSnapshot> getDocumentByIdStream(String collectionPath, String docId) {
    return _firebaseService.getDocumentRef(collectionPath, docId).snapshots();
  }

  // Adiciona um novo documento a uma coleção
  Future<DocumentReference> addDocument(String collectionPath, Map<String, dynamic> data) {
    return _firebaseService.addDocument(collectionPath, data);
  }

  // Atualiza campos específicos de um documento
  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) {
    return _firebaseService.updateDocument(collectionPath, docId, data);
  }

  // Define (cria ou sobrescreve) um documento com um ID específico
  Future<void> setDocument(String collectionPath, String docId, Map<String, dynamic> data) {
    return _firebaseService.setDocument(collectionPath, docId, data);
  }

  // Exclui um documento
  Future<void> deleteDocument(String collectionPath, String docId) {
    return _firebaseService.deleteDocument(collectionPath, docId);
  }

  // Realiza uma busca única em uma coleção com uma query
  Future<QuerySnapshot> queryCollectionOnce(
    String collectionPath, {
    required String field,
    required dynamic isEqualTo,
  }) {
    return _firebaseService.getCollectionRef(collectionPath).where(field, isEqualTo: isEqualTo).get();
  }
}

