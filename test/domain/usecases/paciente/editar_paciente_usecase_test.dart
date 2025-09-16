// test/domain/usecases/paciente/editar_paciente_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/editar_paciente_usecase.dart';

// Gera o mock do repositório
@GenerateMocks([PacienteRepository])
import 'editar_paciente_usecase_test.mocks.dart';

void main() {
  late EditarPacienteUseCase usecase;
  late MockPacienteRepository mockPacienteRepository;

  setUp(() {
    mockPacienteRepository = MockPacienteRepository();
    usecase = EditarPacienteUseCase(mockPacienteRepository);
  });

  group('EditarPacienteUseCase', () {
    final pacienteExistente = Paciente(
      id: 'paciente-id-1',
      nome: 'João da Silva',
      dataNascimento: DateTime(2010, 5, 15),
      nomeResponsavel: 'Maria da Silva',
      dataCadastro: DateTime.now(),
      status: 'ativo',
    );

    test('deve editar o paciente com sucesso se o nome não existir em outro paciente', () async {
      // ARRANGE
      when(mockPacienteRepository.pacienteExistsByName(
        pacienteExistente.nome,
        excludeId: pacienteExistente.id,
      )).thenAnswer((_) async => false);
      when(mockPacienteRepository.updatePaciente(any)).thenAnswer((_) async => Future.value());

      // ACT
      await usecase.call(pacienteExistente);

      // ASSERT
      verify(mockPacienteRepository.pacienteExistsByName(
        pacienteExistente.nome,
        excludeId: pacienteExistente.id,
      )).called(1);
      verify(mockPacienteRepository.updatePaciente(pacienteExistente)).called(1);
    });

    test('deve lançar uma exceção se um outro paciente com o mesmo nome já existir', () async {
      // ARRANGE
      when(mockPacienteRepository.pacienteExistsByName(
        pacienteExistente.nome,
        excludeId: pacienteExistente.id,
      )).thenAnswer((_) async => true);

      // ACT
      final call = usecase.call(pacienteExistente);

      // ASSERT
      expect(() => call, throwsA(isA<Exception>()));
      verify(mockPacienteRepository.pacienteExistsByName(
        pacienteExistente.nome,
        excludeId: pacienteExistente.id,
      )).called(1);
      verifyNever(mockPacienteRepository.updatePaciente(any));
    });
  });
}