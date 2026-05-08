// test/domain/usecases/paciente/arquivar_paciente_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/arquivar_paciente_usecase.dart';

import 'arquivar_paciente_usecase_test.mocks.dart';

@GenerateMocks([PacienteRepository])
void main() {
  late ArquivarPacienteUseCase usecase;
  late MockPacienteRepository mockPacienteRepository;

  setUp(() {
    mockPacienteRepository = MockPacienteRepository();
    usecase = ArquivarPacienteUseCase(mockPacienteRepository);
  });

  group('ArquivarPacienteUseCase', () {
    const pacienteId = 'paciente-id-1';

    test('deve arquivar o paciente chamando o repositório', () async {
      // ARRANGE
      when(mockPacienteRepository.arquivarPaciente(pacienteId)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call(pacienteId);

      // ASSERT
      verify(mockPacienteRepository.arquivarPaciente(pacienteId)).called(1);
    });
  });
}
