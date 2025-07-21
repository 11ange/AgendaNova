// lib/core/services/firebase_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Serviço para encapsular todas as interações com Firebase Firestore e Authentication
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Construtor privado para Singleton
  FirebaseService._internal();

  // Instância única do FirebaseService
  static final FirebaseService _instance = FirebaseService._internal();

  // Getter para a instância única
  static FirebaseService get instance => _instance;

  // Inicializa o Firebase (chamado em main.dart)
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // --- Métodos de Autenticação ---

  // Realiza o login com e-mail e senha
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Trate as exceções específicas do Firebase Auth
      throw Exception('Erro de autenticação: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido ao fazer login: $e');
    }
  }
  
  // NOVO MÉTODO: Cria um novo usuário com e-mail e senha
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Trata erros comuns como e-mail já em uso ou senha fraca
      throw Exception('Erro ao criar usuário: ${e.message}');
    } catch (e) {
      throw Exception('Erro desconhecido ao criar usuário: $e');
    }
  }


  // Realiza o logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtém o usuário atualmente logado
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream para observar mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Métodos do Firestore ---
  // ... (o resto do arquivo continua igual)
  // Obtém uma referência para uma coleção
  CollectionReference<Map<String, dynamic>> getCollectionRef(String collectionPath) {
    return _firestore.collection(collectionPath);
  }

  // Obtém uma referência para um documento
  DocumentReference<Map<String, dynamic>> getDocumentRef(String collectionPath, String docId) {
    return _firestore.collection(collectionPath).doc(docId);
  }

  // Adiciona um novo documento a uma coleção
  Future<DocumentReference> addDocument(String collectionPath, Map<String, dynamic> data) async {
    try {
      return await _firestore.collection(collectionPath).add(data);
    } catch (e) {
      throw Exception('Erro ao adicionar documento à coleção $collectionPath: $e');
    }
  }

  // Define (cria ou sobrescreve) um documento com um ID específico
  // CORREÇÃO: Adicionado optional SetOptions para permitir merge
  Future<void> setDocument(String collectionPath, String docId, Map<String, dynamic> data, [SetOptions? options]) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).set(data, options);
    } catch (e) {
      throw Exception('Erro ao definir documento $docId na coleção $collectionPath: $e');
    }
  }

  // Atualiza campos específicos de um documento
  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar documento $docId na coleção $collectionPath: $e');
    }
  }

  // Exclui um documento
  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      throw Exception('Erro ao excluir documento $docId da coleção $collectionPath: $e');
    }
  }

  // Obtém um documento por ID
  Future<DocumentSnapshot> getDocumentById(String collectionPath, String docId) async {
    try {
      return await _firestore.collection(collectionPath).doc(docId).get();
    } catch (e) {
      throw Exception('Erro ao obter documento $docId da coleção $collectionPath: $e');
    }
  }

  // Obtém todos os documentos de uma coleção (Stream para atualizações em tempo real)
  Stream<QuerySnapshot> getCollectionStream(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  // Obtém documentos de uma coleção com uma query (Stream para atualizações em tempo real)
  Stream<QuerySnapshot> queryCollectionStream(String collectionPath,
      {String? field, dynamic isEqualTo, dynamic arrayContains}) {
    Query query = _firestore.collection(collectionPath);
    if (field != null) {
      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      } else if (arrayContains != null) {
        query = query.where(field, arrayContains: arrayContains);
      }
    }
    return query.snapshots();
  }

  // Obtém documentos de uma coleção com uma query (Future para uma única busca)
  Future<QuerySnapshot> queryCollectionOnce(String collectionPath,
      {String? field, dynamic isEqualTo, dynamic arrayContains}) async {
    Query query = _firestore.collection(collectionPath);
    if (field != null) {
      if (isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      } else if (arrayContains != null) {
        query = query.where(field, arrayContains: arrayContains);
      }
    }
    return await query.get();
  }
}