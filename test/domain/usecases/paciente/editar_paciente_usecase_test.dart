import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_treinamento/domain/entities/paciente.dart';
import 'package:agenda_treinamento/domain/repositories/paciente_repository.dart';
import 'package:agenda_treinamento/domain/repositories/treinamento_repository.dart';
import 'package:agenda_treinamento/domain/repositories/sessao_repository.dart';
import 'package:agenda_treinamento/domain/usecases/paciente/editar_paciente_usecase.dart';

// Importante: Este arquivo é gerado pelo comando do build_runner
import 'editar_paciente_usecase_test.mocks.dart';

@GenerateMocks([PacienteRepository, TreinamentoRepository, SessaoRepository])
void main() {
  late EditarPacienteUseCase usecase;
  late MockPacienteRepository mockPacienteRepository;
  // --- DECLARAÇÃO DAS VARIÁVEIS (Verifique se copiou estas linhas) ---
  late MockTreinamentoRepository mockTreinamentoRepository;
  late MockSessaoRepository mockSessaoRepository;

  setUp(() {
    mockPacienteRepository = MockPacienteRepository();
    // --- INICIALIZAÇÃO DOS MOCKS ---
    mockTreinamentoRepository = MockTreinamentoRepository();
    mockSessaoRepository = MockSessaoRepository();
    
    usecase = EditarPacienteUseCase(
      mockPacienteRepository, 
      mockTreinamentoRepository, 
      mockSessaoRepository
    );
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

    test('deve editar o paciente com sucesso e tentar atualizar sessões', () async {
      // ARRANGE
      when(mockPacienteRepository.pacienteExistsByName(
        pacienteExistente.nome,
        excludeId: pacienteExistente.id,
      )).thenAnswer((_) async => false);
      
      when(mockPacienteRepository.updatePaciente(any)).thenAnswer((_) async => Future.value());

      // Mock para a busca de treinamentos (retorna lista vazia para simplificar)
      when(mockTreinamentoRepository.getTreinamentosByPacienteId(any))
          .thenAnswer((_) => Stream.value([]));

      // ACT
      await usecase.call(pacienteExistente);

      // ASSERT
      verify(mockPacienteRepository.pacienteExistsByName(
        pacienteExistente.nome,
        excludeId: pacienteExistente.id,
      )).called(1);
      verify(mockPacienteRepository.updatePaciente(pacienteExistente)).called(1);
      
      // Verifica se a atualização em cascata foi acionada
      verify(mockTreinamentoRepository.getTreinamentosByPacienteId(pacienteExistente.id!)).called(1);
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
      
      // Garante que NÃO tentou atualizar nada em caso de erro
      verifyNever(mockPacienteRepository.updatePaciente(any));
      verifyNever(mockTreinamentoRepository.getTreinamentosByPacienteId(any));
    });
  });
}