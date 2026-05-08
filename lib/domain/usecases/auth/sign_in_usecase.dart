import 'package:firebase_auth/firebase_auth.dart';
import 'package:agenda_treinamento/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<UserCredential> call(String email, String password) {
    return repository.signIn(email, password);
  }
}
