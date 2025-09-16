// test/domain/usecases/paciente/inativar_paciente_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/inativar_paciente_usecase.dart';

// Gera o mock dos repositórios que são dependências
@GenerateMocks([PacienteRepository, TreinamentoRepository])
import 'inativar_paciente_usecase_test.mocks.dart';

void main() {
  late InativarPacienteUseCase usecase;
  late MockPacienteRepository mockPacienteRepository;
  late MockTreinamentoRepository mockTreinamentoRepository;

  setUp(() {
    mockPacienteRepository = MockPacienteRepository();
    mockTreinamentoRepository = MockTreinamentoRepository();
    usecase = InativarPacienteUseCase(
      mockPacienteRepository,
      mockTreinamentoRepository,
    );
  });

  group('InativarPacienteUseCase', () {
    const pacienteId = 'paciente-id-1';

    test('deve inativar o paciente com sucesso se não houver treinamento ativo', () async {
      // ARRANGE
      when(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).thenAnswer((_) async => false);
      when(mockPacienteRepository.inativarPaciente(pacienteId)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call(pacienteId);

      // ASSERT
      verify(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).called(1);
      verify(mockPacienteRepository.inativarPaciente(pacienteId)).called(1);
    });

    test('deve lançar uma exceção se o paciente tiver um treinamento ativo', () async {
      // ARRANGE
      when(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).thenAnswer((_) async => true);

      // ACT
      final call = usecase.call(pacienteId);

      // ASSERT
      expect(() => call, throwsA(isA<Exception>()));
      verify(mockTreinamentoRepository.hasActiveTreinamento(pacienteId)).called(1);
      verifyNever(mockPacienteRepository.inativarPaciente(any));
    });
  });
}