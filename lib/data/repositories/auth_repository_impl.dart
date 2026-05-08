import 'package:firebase_auth/firebase_auth.dart';
import 'package:agenda_treinamento/core/services/firebase_service.dart';
import 'package:agenda_treinamento/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService;

  AuthRepositoryImpl(this._firebaseService);

  @override
  Future<UserCredential> signIn(String email, String password) {
    return _firebaseService.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<UserCredential> signUp(String email, String password) {
    return _firebaseService.createUserWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _firebaseService.signOut();
  }

  @override
  User? getCurrentUser() {
    return _firebaseService.getCurrentUser();
  }

  @override
  Stream<User?> get authStateChanges => _firebaseService.authStateChanges;
}
