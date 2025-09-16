// test/domain/usecases/paciente/reativar_paciente_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/reativar_paciente_usecase.dart';

// Gera o mock do repositório
@GenerateMocks([PacienteRepository])
import 'reativar_paciente_usecase_test.mocks.dart';

void main() {
  late ReativarPacienteUseCase usecase;
  late MockPacienteRepository mockPacienteRepository;

  setUp(() {
    mockPacienteRepository = MockPacienteRepository();
    usecase = ReativarPacienteUseCase(mockPacienteRepository);
  });

  group('ReativarPacienteUseCase', () {
    const pacienteId = 'paciente-id-1';

    test('deve reativar o paciente com sucesso', () async {
      // ARRANGE
      when(mockPacienteRepository.reativarPaciente(pacienteId)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call(pacienteId);

      // ASSERT
      verify(mockPacienteRepository.reativarPaciente(pacienteId)).called(1);
    });
  });
}