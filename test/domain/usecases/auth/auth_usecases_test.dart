import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agenda_treinamento/domain/repositories/auth_repository.dart';
import 'package:agenda_treinamento/domain/usecases/auth/sign_in_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/auth/sign_up_usecase.dart';
import 'package:agenda_treinamento/domain/usecases/auth/sign_out_usecase.dart';

import 'auth_usecases_test.mocks.dart';

@GenerateMocks([AuthRepository, UserCredential])
void main() {
  late AuthRepository mockAuthRepository;
  late UserCredential mockUserCredential;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserCredential = MockUserCredential();
  });

  group('Auth UseCases', () {
    test('SignInUseCase deve chamar o repositório corretamente', () async {
      final usecase = SignInUseCase(mockAuthRepository);
      const email = 'test@test.com';
      const password = 'password123';

      when(mockAuthRepository.signIn(email, password))
          .thenAnswer((_) async => mockUserCredential);

      final result = await usecase.call(email, password);

      expect(result, mockUserCredential);
      verify(mockAuthRepository.signIn(email, password)).called(1);
    });

    test('SignUpUseCase deve chamar o repositório corretamente', () async {
      final usecase = SignUpUseCase(mockAuthRepository);
      const email = 'test@test.com';
      const password = 'Password123';

      when(mockAuthRepository.signUp(email, password))
          .thenAnswer((_) async => mockUserCredential);

      final result = await usecase.call(email, password);

      expect(result, mockUserCredential);
      verify(mockAuthRepository.signUp(email, password)).called(1);
    });

    test('SignOutUseCase deve chamar o repositório corretamente', () async {
      final usecase = SignOutUseCase(mockAuthRepository);

      when(mockAuthRepository.signOut()).thenAnswer((_) async => {});

      await usecase.call();

      verify(mockAuthRepository.signOut()).called(1);
    });
  });
}
