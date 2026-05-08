import 'package:firebase_auth/firebase_auth.dart';
import 'package:agenda_treinamento/domain/repositories/auth_repository.dart';
import 'package:agenda_treinamento/core/utils/input_validators.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserCredential> call(String email, String password) {
    final passwordError = InputValidators.passwordComplexity(password);
    if (passwordError != null) {
      throw Exception(passwordError);
    }
    return repository.signUp(email, password);
  }
}
